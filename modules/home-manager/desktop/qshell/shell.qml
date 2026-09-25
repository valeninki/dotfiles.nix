//@ pragma UseQApplication

pragma ComponentBehavior: Bound

import Quickshell
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

  // One notification server, attached to the first available output.
  Notifications {
    runtimeConfig: runtimeConfig
    anchorWindow: bars.instances.length > 0 ? bars.instances[0] : null
  }
}
