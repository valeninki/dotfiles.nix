 Architectural breakdown

 Use Quickshell IPC, not a socket or FIFO. This setup already runs one Quickshell instance under Sway, and the installed Quickshell supports ipc call. An IpcHandler gives Sway one named
 command without adding a listener, protocol, or temporary file.

 1. Keep one notification server. Notifications.qml already owns the sole NotificationServer. It should remain the source of incoming notifications. ShellBackend.qml does not need to own
 notification data.
 2. Separate history from popups. On arrival, copy the app name, icon source, summary, body, arrival time, urgency, and action labels into a ListModel owned by Notifications.qml. Give each
 history entry a unique local key. Do not use trackedNotifications as the history model: a notification can leave that collection when its popup expires or the sender closes it.
 3. Keep actions safe. Maintain a separate key-to-live-notification lookup while the underlying notification is open. Render action buttons from the saved labels, but call action.invoke()
 only after checking that the live notification and matching action still exist. When its closed signal fires, remove the live reference and disable its historical action buttons. Never
 retain a closed notification or action object as the only copy of history.
 4. Make popup timeout visual. Change the existing timer so it hides and advances the toast rather than deleting its history entry. A live notification can still provide actions in the
 drawer until its sender closes it. A sender-closed or expired notification remains readable, with actions disabled. Use an explicit toast queue/current key so a hidden toast does not
 immediately reappear from trackedNotifications. Keep the present critical-first policy; do not automatically hide critical toasts.
 5. Define deletion separately. The drawer’s card dismissal removes that history entry and calls dismiss() if it is still live. Clear All does this for every entry. Guard close callbacks
 against entries already removed. Set a bounded history limit, for example 100 entries, and evict oldest entries deliberately. History is in memory for this Quickshell session; disk
 persistence after restart is outside this change.
 6. Route F9 to one drawer. Put IpcHandler { target: "notificationCenter" } in shell.qml. Its toggle() calls the single NotificationCenter instance, attached to the same first available
 output used by the existing notifications and OSD. No bar button or other shortcut opens it. F9 closes it on the next press; Escape and an outside click are close-only controls.

 Draft data and IPC structures

 These are design sketches, not applied or lint-validated code:

   // Notifications.qml: keep the existing NotificationServer here.
   readonly property alias historyModel: history
   property var liveByKey: ({})
   property int nextHistoryKey: 0

   ListModel { id: history }

   NotificationServer {
     id: notificationServer
     keepOnReload: true
     bodySupported: true
     imageSupported: true
     actionsSupported: true

     onNotification: function(notification) {
       notification.tracked = true
       root.recordNotification(notification)
     }
   }

 recordNotification() should append a plain-data row such as { key, appName, iconSource, summary, body, receivedAtMs, urgency, actionLabels, isLive }, register a guarded
 notification.closed callback, and enqueue a toast. Handle a sender updating an existing notification ID by updating its row rather than blindly duplicating it. dismissKey(key),
 clearAll(), and invokeAction(key, identifier) form the small API exposed to the drawer. A one-minute timer can refresh a nowMs property used to format relative time; store the absolute
 arrival time, not a permanently formatted “5 minutes ago” string.

   // shell.qml
   import Quickshell.Io

   ShellRoot {
     // Existing RuntimeConfig, ShellBackend, bars, OSD...

     Notifications {
       id: notifications
       runtimeConfig: runtimeConfig
       anchorWindow: bars.instances.length > 0 ? bars.instances[0] : null
     }

     NotificationCenter {
       id: notificationCenter
       runtimeConfig: runtimeConfig
       notifications: notifications
       outputScreen: bars.instances.length > 0 ? bars.instances[0].screen : null
     }

     IpcHandler {
       target: "notificationCenter"
       function toggle() { notificationCenter.toggle() }
     }
   }

 File-by-file changes

 ┌───────────────────────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 │ File                                                      │ Planned responsibility                                                                                                      │
 ├───────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ modules/home-manager/desktop/qshell/Notifications.qml     │ Own the history ListModel, live-action lookup, close handling, toast queue, individual dismissal, and Clear All. Preserve   │
 │                                                           │ the single notification server.                                                                                             │
 ├───────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ modules/home-manager/desktop/qshell/NotificationCenter.qm │ Render the history and empty state; own only drawer visibility and close interactions. Read data and call methods on        │
 │ l (new)                                                   │ Notifications.qml.                                                                                                          │
 ├───────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ modules/home-manager/desktop/qshell/shell.qml             │ Instantiate one drawer and one IpcHandler; route IPC toggle to that drawer.                                                 │
 ├───────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ modules/home-manager/desktop/qshell.nix                   │ Add "NotificationCenter.qml" to qmlFiles, so Home Manager installs it. No new package or runtime command is needed.         │
 ├───────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ modules/home-manager/desktop/sway.nix                     │ Add the unmodified F9 binding in the existing keybindings attrset.                                                          │
 └───────────────────────────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

 Drawer sketch: A transparent PanelWindow anchored on all four sides of the selected screen can hold a right-aligned, roughly 400px-wide sidebar. Give it exclusiveZone: 0 so it does not
 move tiled windows. Its transparent remainder is an outside-click close target; it will intercept clicks while the drawer is open. The sidebar contains a header with count and Clear All,
 a clipped ListView, and a centered “No notifications” state when historyModel.count === 0. Cards use base00 backgrounds, base02 borders/hover, base05 text, base0D accents, and base08 for
 critical items. Use Text.PlainText for notification-provided text.

   // NotificationCenter.qml: structural sketch
   import Quickshell
   import Quickshell.Wayland
   import QtQuick

   PanelWindow {
     id: root
     required property var runtimeConfig
     required property var notifications
     required property var outputScreen
     property bool drawerOpen: false

     function toggle() { drawerOpen = !drawerOpen }
     function close() { drawerOpen = false }

     screen: outputScreen
     anchors { top: true; bottom: true; left: true; right: true }
     exclusiveZone: 0
     color: "transparent"
     visible: drawerOpen && outputScreen !== null
     WlrLayershell.layer: WlrLayer.Overlay
     WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

     // Full-window MouseArea: close on an outside click.
     // Right-aligned FocusScope/sidebar above it: accept clicks inside,
     // handle Escape, and contain header, ListView and empty state.
     // Each delegate displays saved fields and calls
     // notifications.dismissKey(key) or invokeAction(key, identifier).
   }

 On opening, give the sidebar focus so Escape reaches it. Keep the outside-click area behind the sidebar rather than placing a catch-all MouseArea above its controls. Check layer and focus
 behavior in a live Sway session; qmllint alone cannot establish compositor behavior.

 Sway binding sketch: sway.nix currently takes { pkgs, ... }; add config and lib to its arguments, then add:

   "F9" =
     "exec ${lib.getExe config.programs.quickshell.package} ipc call notificationCenter toggle";

 This uses the configured Quickshell executable rather than assuming a PATH entry. The command shape is supported by the installed CLI: quickshell ipc call [target] [function]. No FIFO
 fallback is warranted unless the deployed Quickshell version lacks IPC.

 Safety and verification plan

 No files were changed. Do not run nixos-rebuild switch, and do not edit, stage, or touch map.md or quickmap.md.

 After approval and implementation:

 1. Check evaluation without building: nix flake check --no-build.
 2. Run the requested isolated check, without creating a result symlink or switching the system:
 nix build .#checks.x86_64-linux.quickshell-qml --no-link
 3. Inspect the check output for zero qmllint errors. check.nix substitutes test colors/config, lints source/*.qml, and also runs its shell checks. Existing Quickshell type-metadata
 warnings may remain; they are not errors.
 4. Validate behavior in a running Sway session after normal configuration deployment: quickshell ipc show, then quickshell ipc call notificationCenter toggle. Test F9 twice, Escape,
 outside click, empty state, a timeout, sender-closed actions, individual dismissal, and Clear All.
 5. Before relying on the flake check for a new QML file, ensure Nix’s Git-flake source includes it. An untracked file may be omitted from the check even if it exists locally. This does
 not require staging either protected map file.
