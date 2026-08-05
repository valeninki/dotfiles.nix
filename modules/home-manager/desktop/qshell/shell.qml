//@ pragma UseQApplication

pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

ShellRoot {
  RuntimeConfig {
    id: runtimeConfig
  }

  PopupCoordinator {
    id: popupCoordinator
  }

  ShellBackend {
    id: backend
    runtimeConfig: runtimeConfig
  }

  Bar {
    id: bar
    runtimeConfig: runtimeConfig
    backend: backend
    popupCoordinator: popupCoordinator
  }

  Notifications {
    runtimeConfig: runtimeConfig
    anchorWindow: bar
  }
}
