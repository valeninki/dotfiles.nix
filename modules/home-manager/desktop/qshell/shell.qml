//@ pragma UseQApplication

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  RuntimeConfig {
    id: runtimeConfig
  }

  ShellBackend {
    id: backend
    runtimeConfig: runtimeConfig
  }

  Variants {
    id: bars
    model: Quickshell.screens

    delegate: Bar {
      required property var modelData
      outputScreen: modelData
      runtimeConfig: runtimeConfig
      backend: backend
    }
  }

  Osd {
    runtimeConfig: runtimeConfig
    backend: backend
    outputScreen: bars.instances.length > 0 ? bars.instances[0].screen : null
  }

  // One notification server, attached to the first available output.
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
