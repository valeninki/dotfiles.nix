import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

Scope {
  id: root

  required property var runtimeConfig

  property string networkTooltipString: "Disconnected"
  property string networkDevice: ""
  property bool networkEnabled: false
  property string volumeLevel: "--"
  property bool volumeMuted: false
  property bool volumeRefreshPending: false
  property string volumeTooltipString: "--"
  property string microphoneLevel: "--"
  property bool microphoneMuted: false
  property bool microphoneRefreshPending: false
  property var audioSinks: []
  property bool sinksRefreshPending: false
  property string brightnessLevel: "--"
  property string brightnessTooltipString: "--"
  property string ramUsage: "--"
  property string ramTooltipString: "--"
  property string batteryLevel: "--"
  property string batteryStatus: "Discharging"
  property bool acOnline: false
  property bool isCharging: batteryStatus === "Charging"
  property bool isLow: batteryStatus === "Discharging"
    && Number(batteryLevel) >= 0 && Number(batteryLevel) <= 15
  property string calendarTooltipString: ""
  property bool calendarYearly: false
  // Prefer a playing player, then a paused one. Stopped players have no active session.
  readonly property var activeMediaPlayer: {
    const players = Mpris.players.values
    let paused = null
    for (let i = 0; i < players.length; i++) {
      const player = players[i]
      if (player.playbackState === MprisPlaybackState.Playing)
        return player
      if (!paused && player.playbackState === MprisPlaybackState.Paused)
        paused = player
    }
    return paused
  }
  readonly property bool hasActiveMedia: activeMediaPlayer !== null
  readonly property string playbackStatus: !activeMediaPlayer ? ""
    : activeMediaPlayer.playbackState === MprisPlaybackState.Playing ? "Playing" : "Paused"
  readonly property string trackTitle: activeMediaPlayer ? activeMediaPlayer.trackTitle : ""
  readonly property string trackArtist: activeMediaPlayer ? activeMediaPlayer.trackArtist : ""
  readonly property bool canControl: activeMediaPlayer ? activeMediaPlayer.canControl : false
  readonly property bool canToggleMedia: canControl && activeMediaPlayer.canTogglePlaying
  readonly property bool canGoNext: canControl && activeMediaPlayer.canGoNext
  readonly property bool canGoPrevious: canControl && activeMediaPlayer.canGoPrevious
  property string focusedWindowTitle: ""
  property string focusedWindowAppId: ""
  property bool focusedWindowRefreshPending: false

  function toggleMedia() {
    if (canToggleMedia)
      activeMediaPlayer.togglePlaying()
  }

  function nextMedia() {
    if (canGoNext)
      activeMediaPlayer.next()
  }

  function previousMedia() {
    if (canGoPrevious)
      activeMediaPlayer.previous()
  }

  function formatCalendar(text, highlightToday) {
    const escaped = text.replace(/\s+$/, "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
    if (!highlightToday)
      return "<pre style=\"margin: 0\">" + escaped + "</pre>"

    const day = String(new Date().getDate())
    const dayPattern = new RegExp("(^|\\s)(" + day + ")(?=\\s|$)", "m")
    const highlighted = escaped.replace(
      dayPattern,
      "$1<font color=\"" + runtimeConfig.base0D + "\"><b>$2</b></font>"
    )

    return "<pre style=\"margin: 0\">" + highlighted + "</pre>"
  }

  function findFocusedWindow(node) {
    if (node.focused)
      return node

    const childLists = [ node.nodes || [], node.floating_nodes || [] ]
    for (let i = 0; i < childLists.length; i++) {
      for (let j = 0; j < childLists[i].length; j++) {
        const focused = findFocusedWindow(childLists[i][j])
        if (focused)
          return focused
      }
    }

    return null
  }

  function toggleCalendarView() {
    calendarYearly = !calendarYearly
    calendarTooltipProcess.running = false
    calendarTooltipProcess.running = true
  }

  function adjustVolume(step) {
    const current = Number(volumeLevel)
    if (!isNaN(current))
      volumeLevel = String(Math.max(0, Math.min(100, current + step)))

    if (step > 0)
      volumeUpProcess.startDetached()
    else
      volumeDownProcess.startDetached()
    refreshVolume()
    volumeSettleTimer.restart()
  }

  function toggleVolumeMute() {
    volumeMuted = !volumeMuted
    volumeMuteProcess.startDetached()
    refreshVolume()
    volumeSettleTimer.restart()
  }

  function refreshVolume() {
    if (volumeProcess.running)
      volumeRefreshPending = true
    else
      volumeProcess.running = true
  }

  function setVolume(percent) {
    const level = Math.max(0, Math.min(100, Math.round(percent)))
    volumeLevel = String(level)
    volumeSetProcess.command = [runtimeConfig.wpctl, "set-volume", "@DEFAULT_AUDIO_SINK@", level + "%"]
    volumeSetProcess.startDetached()
    volumeSettleTimer.restart()
  }

  function refreshMicrophone() {
    if (microphoneProcess.running)
      microphoneRefreshPending = true
    else
      microphoneProcess.running = true
  }

  function toggleMicrophoneMute() {
    microphoneMuted = !microphoneMuted
    microphoneMuteProcess.startDetached()
    microphoneSettleTimer.restart()
  }

  function refreshSinks() {
    if (sinksProcess.running)
      sinksRefreshPending = true
    else
      sinksProcess.running = true
  }

  function selectSink(id) {
    if (!audioSinks.some(sink => sink.id === id))
      return
    sinkSelectProcess.command = [runtimeConfig.wpctl, "set-default", String(id)]
    sinkSelectProcess.startDetached()
    sinkSettleTimer.restart()
  }

  function parseSinks(status) {
    const sinks = []
    let inSinks = false
    const lines = status.split("\n")
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (/\bSinks:\s*$/.test(line)) {
        inSinks = true
        continue
      }
      if (!inSinks)
        continue
      if (/\bSources:\s*$/.test(line) || /^Video\s*$/.test(line))
        break
      const match = /^\s*[│| ]*([*]?)\s*(\d+)\.\s+(.+?)\s*$/.exec(line)
      if (match) {
        const name = match[3].replace(/\s+\[vol:[^\]]*\]\s*$/, "")
        sinks.push({ id: Number(match[2]), name: name, isDefault: match[1] === "*" })
      }
    }
    return sinks
  }

  function adjustBrightness(step) {
    if (!runtimeConfig.backlightEnabled)
      return

    const current = Number(brightnessLevel)
    if (!isNaN(current))
      brightnessLevel = String(Math.max(1, Math.min(100, current + step)))

    if (step > 0)
      brightnessUpProcess.startDetached()
    else
      brightnessDownProcess.startDetached()
  }

  function toggleNetwork() {
    if (!runtimeConfig.iwdEnabled || !networkDevice)
      return

    networkEnabled = !networkEnabled
    networkTooltipString = networkEnabled ? "Connecting..." : "Wi-Fi off"
    networkToggleProcess.command = [
      runtimeConfig.iwctl,
      "device",
      networkDevice,
      "set-property",
      "Powered",
      networkEnabled ? "on" : "off"
    ]
    networkToggleProcess.startDetached()
    networkRefreshTimer.restart()
  }

  function refreshNetwork() {
    if (runtimeConfig.iwdEnabled && !networkDetailsProcess.running)
      networkDetailsProcess.running = true
  }

  function refreshVolumeTooltip() {
    if (!volumeTooltipProcess.running)
      volumeTooltipProcess.running = true
  }

  function refreshBrightness() {
    if (runtimeConfig.backlightEnabled && !brightnessProcess.running)
      brightnessProcess.running = true
  }

  function refreshRamTooltip() {
    if (!ramTooltipProcess.running)
      ramTooltipProcess.running = true
  }

  function refreshCalendar() {
    if (!calendarTooltipProcess.running)
      calendarTooltipProcess.running = true
  }

  function openVolumeControl() {
    volumeControlProcess.startDetached()
  }

  function poweroff() {
    shutdownProcess.startDetached()
  }

  function reboot() {
    restartProcess.startDetached()
  }

  Process {
    id: networkDetailsProcess
    command: [ root.runtimeConfig.networkStatus ]

    stdout: StdioCollector {
      onStreamFinished: {
        const details = text.trim().split("\n").map(line => line.trim())
        root.networkTooltipString = details[0] || "Disconnected"
        root.networkEnabled = details[1] === "on"
        root.networkDevice = details[2] || ""
      }
    }
  }

  Process {
    id: networkToggleProcess
  }

  Process {
    id: volumeProcess
    command: [ root.runtimeConfig.wpctl, "get-volume", "@DEFAULT_AUDIO_SINK@" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const match = /^Volume:\s*(\d+(?:\.\d+)?)\s*(\[MUTED\])?\s*$/.exec(text.trim())
        if (!match)
          return
        root.volumeLevel = String(Math.round(Number(match[1]) * 100))
        root.volumeMuted = !!match[2]
      }
    }

    onRunningChanged: {
      if (!running && root.volumeRefreshPending) {
        root.volumeRefreshPending = false
        volumePendingTimer.start()
      }
    }
  }

  Process {
    id: microphoneProcess
    command: [ root.runtimeConfig.wpctl, "get-volume", "@DEFAULT_AUDIO_SOURCE@" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const match = /^Volume:\s*(\d+(?:\.\d+)?)\s*(\[MUTED\])?\s*$/.exec(text.trim())
        if (!match)
          return
        root.microphoneLevel = String(Math.round(Number(match[1]) * 100))
        root.microphoneMuted = !!match[2]
      }
    }

    onRunningChanged: {
      if (!running && root.microphoneRefreshPending) {
        root.microphoneRefreshPending = false
        microphonePendingTimer.start()
      }
    }
  }

  Process {
    id: sinksProcess
    command: [ root.runtimeConfig.wpctl, "status" ]

    stdout: StdioCollector {
      onStreamFinished: root.audioSinks = root.parseSinks(text)
    }

    onRunningChanged: {
      if (!running && root.sinksRefreshPending) {
        root.sinksRefreshPending = false
        sinksPendingTimer.start()
      }
    }
  }

  Process {
    id: volumeTooltipProcess
    command: [ root.runtimeConfig.wpctl, "inspect", "@DEFAULT_AUDIO_SINK@" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
          if (!lines[i].includes("node.description"))
            continue

          const separator = lines[i].indexOf(" = ")
          if (separator >= 0) {
            root.volumeTooltipString = lines[i]
              .slice(separator + 3)
              .trim()
              .replace(/^\"|\"$/g, "") || "--"
            return
          }
        }
        root.volumeTooltipString = "--"
      }
    }
  }

  Process {
    id: volumeUpProcess
    command: [ root.runtimeConfig.wpctl, "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+" ]
  }

  Process {
    id: volumeDownProcess
    command: [ root.runtimeConfig.wpctl, "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-" ]
  }

  Process {
    id: volumeMuteProcess
    command: [ root.runtimeConfig.wpctl, "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle" ]
  }

  Process {
    id: volumeSetProcess
  }

  Process {
    id: microphoneMuteProcess
    command: [ root.runtimeConfig.wpctl, "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle" ]
  }

  Process {
    id: sinkSelectProcess
  }

  Process {
    id: brightnessProcess
    command: [ root.runtimeConfig.brightnessctl, "-m" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const fields = text.trim().split(",")
        root.brightnessLevel = fields.length > 3 ? fields[3].replace("%", "") : "--"
        root.brightnessTooltipString = fields.length > 4
          ? fields[0] + ": " + fields[2] + " / " + fields[4] + " (" + fields[3] + ")"
          : "--"
      }
    }
  }

  Process {
    id: brightnessUpProcess
    command: [ root.runtimeConfig.brightnessctl, "set", "+5%" ]
  }

  Process {
    id: brightnessDownProcess
    command: [ root.runtimeConfig.brightnessctl, "set", "5%-" ]
  }

  Process {
    id: ramProcess
    command: [
      root.runtimeConfig.shell,
      "-c",
      root.runtimeConfig.free
        + " | "
        + root.runtimeConfig.awk
        + " '/Mem:/ {printf(\"%.0f\", $3/$2 * 100.0)}'"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.ramUsage = text.trim() || "--"
    }
  }

  Process {
    id: ramTooltipProcess
    command: [
      root.runtimeConfig.shell,
      "-c",
      root.runtimeConfig.free
        + " -h | "
        + root.runtimeConfig.awk
        + " '/^Mem:/ {print $3 \" / \" $2}'"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.ramTooltipString = text.trim() || "--"
    }
  }

  Process {
    id: batteryProcess
    command: [
      root.runtimeConfig.shell, "-c",
      'battery_dir="/sys/class/power_supply/$1"; '
        + 'if [ ! -r "$battery_dir/capacity" ] || [ ! -r "$battery_dir/status" ]; then '
        + 'printf "%s\n" -- Unknown 0; exit 0; fi; '
        + 'IFS= read -r capacity < "$battery_dir/capacity" || capacity=--; '
        + 'IFS= read -r status < "$battery_dir/status" || status=Unknown; '
        + 'ac_found=0; ac_online=0; '
        + 'for ac in /sys/class/power_supply/AC*/online; do '
        + '[ -r "$ac" ] || continue; ac_found=1; '
        + 'IFS= read -r value < "$ac" || value=0; '
        + 'if [ "$value" = 1 ]; then ac_online=1; break; fi; done; '
        + 'if [ "$ac_found" = 0 ] && [ "$status" = Charging ]; then ac_online=1; fi; '
        + 'printf "%s\n" "$capacity" "$status" "$ac_online"',
      "battery-poll", root.runtimeConfig.batteryDevice
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")
        const level = Number(lines[0])
        root.batteryLevel = Number.isInteger(level) && level >= 0 && level <= 100
          ? String(level) : "--"
        root.batteryStatus = ["Charging", "Discharging", "Full", "Not charging"].includes(lines[1])
          ? lines[1] : "Unknown"
        root.acOnline = lines[2] === "1"
      }
    }
  }

  Process {
    id: calendarTooltipProcess
    command: [
      root.runtimeConfig.env,
      "LC_TIME=en_GB.UTF-8",
      root.runtimeConfig.cal,
      root.calendarYearly ? "-y" : "-m"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.calendarTooltipString = root.formatCalendar(text, !root.calendarYearly)
    }
  }

  Process {
    id: volumeControlProcess
    command: [ root.runtimeConfig.pavucontrol ]
  }

  Process {
    id: focusedWindowProcess
    command: [ root.runtimeConfig.swaymsg, "-t", "get_tree", "-r" ]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const focused = root.findFocusedWindow(JSON.parse(text))
          root.focusedWindowTitle = focused && focused.name ? focused.name : ""
          root.focusedWindowAppId = focused
            ? (focused.app_id || focused.window_properties?.class || "")
            : ""
        } catch (_) {
          root.focusedWindowTitle = ""
          root.focusedWindowAppId = ""
        }

        if (root.focusedWindowRefreshPending) {
          root.focusedWindowRefreshPending = false
          focusedWindowRefreshTimer.restart()
        }
      }
    }
  }

  Process {
    id: shutdownProcess
    command: [
      root.runtimeConfig.systemdRun,
      "--user",
      "--collect",
      "--quiet",
      "--unit=quickshell-poweroff",
      root.runtimeConfig.gracefulSystemAction,
      "poweroff"
    ]
  }

  Process {
    id: restartProcess
    command: [
      root.runtimeConfig.systemdRun,
      "--user",
      "--collect",
      "--quiet",
      "--unit=quickshell-reboot",
      root.runtimeConfig.gracefulSystemAction,
      "reboot"
    ]
  }

  I3IpcListener {
    id: focusedWindowListener
    onIpcEvent: function(event) {
      if (event.type === "window" || event.type === "workspace")
        focusedWindowRefreshTimer.restart()
    }
  }

  Timer {
    interval: 0
    running: true
    onTriggered: focusedWindowListener.subscriptions = [ "window", "workspace" ]
  }

  Timer {
    id: focusedWindowRefreshTimer
    interval: 50
    repeat: false
    onTriggered: {
      if (!focusedWindowProcess.running)
        focusedWindowProcess.running = true
      else
        root.focusedWindowRefreshPending = true
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refreshNetwork()
      root.refreshBrightness()
      if (!ramProcess.running)
        ramProcess.running = true
    }
  }

  // Frequent asynchronous queries also catch wpctl changes made by Sway media keys.
  Timer {
    interval: 750
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refreshVolume()
      root.refreshMicrophone()
    }
  }

  // The detached set command may still be running when the immediate query finishes.
  Timer {
    id: volumeSettleTimer
    interval: 200
    onTriggered: root.refreshVolume()
  }

  Timer {
    id: volumePendingTimer
    interval: 0
    onTriggered: root.refreshVolume()
  }

  Timer {
    id: microphoneSettleTimer
    interval: 200
    onTriggered: root.refreshMicrophone()
  }

  Timer {
    id: microphonePendingTimer
    interval: 0
    onTriggered: root.refreshMicrophone()
  }

  Timer {
    id: sinkSettleTimer
    interval: 400
    onTriggered: {
      root.refreshSinks()
      root.refreshVolumeTooltip()
      root.refreshVolume()
    }
  }

  Timer {
    id: sinksPendingTimer
    interval: 0
    onTriggered: root.refreshSinks()
  }

  Timer {
    id: networkRefreshTimer
    interval: 1000
    repeat: false
    onTriggered: root.refreshNetwork()
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refreshCalendar()
      if (root.runtimeConfig.batteryEnabled && !batteryProcess.running)
        batteryProcess.running = true
    }
  }

  Component.onCompleted: focusedWindowRefreshTimer.start()
}
