pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.I3
import QtQuick

PanelWindow {
  id: root

  required property var runtimeConfig
  required property var backend
  readonly property alias popupCoordinator: popupCoordinatorInstance
  required property var outputScreen

  screen: outputScreen

  PopupCoordinator {
    id: popupCoordinatorInstance
    owner: root
  }

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 50
  color: "transparent"

  function iconFor(appId) {
    const normalized = appId.toLowerCase()
    if (normalized.includes("firefox"))
      return "󰈹"
    if (normalized.includes("kitty"))
      return "󰄛"
    if (normalized.includes("zed"))
      return "󰨞"
    if (normalized.includes("discord"))
      return "󰙯"
    return "󰣆"
  }

  Rectangle {
    id: leftPill
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: 10
    width: workspaceRow.implicitWidth + 32
    radius: 12
    color: root.runtimeConfig.base00

    Row {
      id: workspaceRow
      anchors.centerIn: parent
      spacing: 8

      Repeater {
        model: I3.workspaces

        delegate: Rectangle {
          required property var modelData

          width: workspaceLabel.implicitWidth + 16
          height: 24
          radius: 8
          color: modelData.focused ? root.runtimeConfig.base0D : root.runtimeConfig.base05
          opacity: modelData.focused ? 1 : 0.5

          Text {
            id: workspaceLabel
            anchors.centerIn: parent
            text: modelData.name
            color: root.runtimeConfig.base00
            font.pixelSize: 12
          }

          MouseArea {
            anchors.fill: parent
            onClicked: modelData.activate()
          }
        }
      }
    }
  }

  Rectangle {
    id: centerPill
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: 10
    width: Math.max(0, Math.min(
      root.backend.hasActiveMedia
        ? mediaRow.implicitWidth + 32
        : Math.min(titleRow.implicitWidth + 32, 300),
      2 * Math.min(parent.width / 2 - leftPill.x - leftPill.width - 8,
                   rightIslands.x - parent.width / 2 - 8)))
    clip: true
    radius: 12
    color: root.runtimeConfig.base00
    visible: root.backend.hasActiveMedia || windowTitle.text !== ""

    Row {
      id: mediaRow
      visible: root.backend.hasActiveMedia
      anchors.centerIn: parent
      spacing: 8

      Text {
        text: root.backend.playbackStatus
        color: root.runtimeConfig.base0D
        font.pixelSize: 12
      }

      Text {
        width: Math.min(implicitWidth, 125)
        elide: Text.ElideRight
        text: root.backend.trackArtist && root.backend.trackTitle
          ? root.backend.trackArtist + " — " + root.backend.trackTitle
          : root.backend.trackTitle || root.backend.trackArtist || "Unknown track"
        color: root.runtimeConfig.base05
        font.pixelSize: 12
      }

      Text {
        text: "󰒮"
        color: root.backend.canGoPrevious ? root.runtimeConfig.base05 : root.runtimeConfig.base02
        font.pixelSize: 12

        MouseArea {
          anchors.fill: parent
          enabled: root.backend.canGoPrevious
          onClicked: root.backend.previousMedia()
        }
      }

      Text {
        text: root.backend.playbackStatus === "Playing" ? "󰏤" : "󰐊"
        color: root.backend.canToggleMedia ? root.runtimeConfig.base05 : root.runtimeConfig.base02
        font.pixelSize: 12

        MouseArea {
          anchors.fill: parent
          enabled: root.backend.canToggleMedia
          onClicked: root.backend.toggleMedia()
        }
      }

      Text {
        text: "󰒭"
        color: root.backend.canGoNext ? root.runtimeConfig.base05 : root.runtimeConfig.base02
        font.pixelSize: 12

        MouseArea {
          anchors.fill: parent
          enabled: root.backend.canGoNext
          onClicked: root.backend.nextMedia()
        }
      }
    }

    Row {
      id: titleRow
      visible: !root.backend.hasActiveMedia
      anchors.centerIn: parent
      spacing: 12

      Text {
        id: windowIcon
        text: root.iconFor(root.backend.focusedWindowAppId)
        color: root.runtimeConfig.base05
        font.pixelSize: 12
      }

      Text {
        id: windowTitle
        width: Math.min(implicitWidth, 300 - windowIcon.implicitWidth - titleRow.spacing - 32)
        elide: Text.ElideRight
        text: root.backend.focusedWindowTitle
        color: root.runtimeConfig.base05
        font.pixelSize: 12
      }
    }
  }

  Row {
    id: rightIslands
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.margins: 10
    spacing: 8
    height: parent.height - 20

    Rectangle {
      id: statusPill
      width: statusRow.implicitWidth + statusRow.leftPadding + statusRow.rightPadding
      height: parent.height
      radius: 12
      color: root.runtimeConfig.base00

      Row {
        id: statusRow
        anchors.centerIn: parent
        property int leftPadding: 12
        property int rightPadding: 12
        spacing: 10

      Tray {
        id: tray
        runtimeConfig: root.runtimeConfig
        popupCoordinator: root.popupCoordinator
        menuPopup: trayMenuPopup
      }

      Item {
        id: networkItem
        visible: root.runtimeConfig.iwdEnabled
        width: networkIcon.implicitWidth
        height: networkIcon.implicitHeight

        Text {
          id: networkIcon
          anchors.verticalCenter: parent.verticalCenter
          text: "󰤨"
          font.pixelSize: 14
          color: root.runtimeConfig.base05
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            root.popupCoordinator.togglePopup("network")
            if (root.popupCoordinator.activePopup === "network")
              root.backend.refreshNetwork()
          }
        }

        PopupWindow {
          id: networkPopup
          visible: false
          color: "transparent"
          grabFocus: true
          implicitWidth: networkPopupBody.implicitWidth
          implicitHeight: networkPopupBody.implicitHeight

          anchor.item: networkIcon
          anchor.rect.x: -(implicitWidth - networkIcon.width) / 2
          anchor.rect.y: networkIcon.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          onVisibleChanged: {
            if (!visible && root.popupCoordinator.activePopup === "network")
              root.popupCoordinator.closePopup("network")
          }

          Connections {
            target: root.popupCoordinator
            function onActivePopupChanged() {
              networkPopup.visible = root.popupCoordinator.activePopup === "network"
            }
          }

          Rectangle {
            id: networkPopupBody
            anchors.fill: parent
            implicitWidth: 240
            implicitHeight: networkPopupContent.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Row {
              id: networkPopupContent
              anchors.centerIn: parent
              width: parent.width - 28
              spacing: 12

              Text {
                width: parent.width - networkToggle.width - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: root.backend.networkTooltipString
                color: root.runtimeConfig.base05
                font.pixelSize: 13
                elide: Text.ElideRight
              }

              Rectangle {
                id: networkToggle
                anchors.verticalCenter: parent.verticalCenter
                width: 38
                height: 20
                radius: 10
                color: root.backend.networkEnabled
                  ? root.runtimeConfig.base0D
                  : root.runtimeConfig.base02

                Rectangle {
                  anchors.verticalCenter: parent.verticalCenter
                  x: root.backend.networkEnabled ? parent.width - width - 3 : 3
                  width: 14
                  height: 14
                  radius: 7
                  color: root.runtimeConfig.base00
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: root.backend.toggleNetwork()
                }
              }
            }
          }
        }
      }

      Item {
        id: brightnessItem
        visible: root.runtimeConfig.backlightEnabled
        anchors.verticalCenter: parent.verticalCenter
        width: brightnessIcon.implicitWidth
        height: brightnessIcon.implicitHeight

        Text {
          id: brightnessIcon
          anchors.centerIn: parent
          text: "󰃠"
          color: root.runtimeConfig.base05
          font.pixelSize: 12
        }

        MouseArea {
          id: brightnessMouse
          anchors.fill: parent
          hoverEnabled: true
          onEntered: root.backend.refreshBrightness()
          onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
              root.backend.adjustBrightness(5)
            else if (wheel.angleDelta.y < 0)
              root.backend.adjustBrightness(-5)
            wheel.accepted = true
          }
        }

        PopupWindow {
          visible: brightnessMouse.containsMouse
          color: "transparent"
          grabFocus: false
          implicitWidth: brightnessPopupBody.implicitWidth
          implicitHeight: brightnessPopupBody.implicitHeight

          anchor.item: brightnessIcon
          anchor.rect.x: -(implicitWidth - brightnessIcon.width) / 2
          anchor.rect.y: brightnessIcon.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          Rectangle {
            id: brightnessPopupBody
            anchors.fill: parent
            implicitWidth: brightnessPopupText.implicitWidth + 28
            implicitHeight: brightnessPopupText.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Text {
              id: brightnessPopupText
              anchors.centerIn: parent
              text: root.backend.brightnessTooltipString
              color: root.runtimeConfig.base05
              font.pixelSize: 13
            }
          }
        }
      }

      Item {
        id: ramItem
        anchors.verticalCenter: parent.verticalCenter
        width: ramRow.implicitWidth
        height: ramRow.implicitHeight

        Row {
          id: ramRow
          anchors.centerIn: parent
          spacing: 6

          Text {
            text: "󰍛"
            font.pixelSize: 12
            color: root.runtimeConfig.base05
          }

          Text {
            text: root.backend.ramUsage + "%"
            font.pixelSize: 12
            color: root.runtimeConfig.base05
          }
        }

        MouseArea {
          id: ramMouse
          anchors.fill: parent
          hoverEnabled: true
          onEntered: root.backend.refreshRamTooltip()
        }

        PopupWindow {
          visible: ramMouse.containsMouse
          color: "transparent"
          grabFocus: false
          implicitWidth: ramPopupBody.implicitWidth
          implicitHeight: ramPopupBody.implicitHeight

          anchor.item: ramRow
          anchor.rect.x: -(implicitWidth - ramRow.width) / 2
          anchor.rect.y: ramRow.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          Rectangle {
            id: ramPopupBody
            anchors.fill: parent
            implicitWidth: ramPopupText.implicitWidth + 28
            implicitHeight: ramPopupText.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Text {
              id: ramPopupText
              anchors.centerIn: parent
              text: root.backend.ramTooltipString
              color: root.runtimeConfig.base05
              font.family: "monospace"
              font.pixelSize: 13
            }
          }
        }
      }

      Row {
        visible: root.runtimeConfig.batteryEnabled
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          text: root.backend.isCharging ? "󰂄" : "󰁹"
          font.pixelSize: 12
          color: root.backend.isLow ? root.runtimeConfig.base08 : root.runtimeConfig.base05
        }

        Text {
          text: root.backend.batteryLevel === "--" ? "--" : root.backend.batteryLevel + "%"
          font.pixelSize: 12
          color: root.backend.isLow ? root.runtimeConfig.base08 : root.runtimeConfig.base05
        }
      }
      }
    }

    Rectangle {
      id: clockPill
      width: clockRow.implicitWidth + clockRow.leftPadding + clockRow.rightPadding
      height: parent.height
      radius: 12
      color: root.runtimeConfig.base00

      Row {
        id: clockRow
        anchors.centerIn: parent
        property int leftPadding: 12
        property int rightPadding: 12
        spacing: 6

      Item {
        id: calendarItem
        anchors.verticalCenter: parent.verticalCenter
        width: dateRow.implicitWidth
        height: dateRow.implicitHeight

        Row {
          id: dateRow
          anchors.centerIn: parent
          spacing: 6

          Text {
            text: "󰃭"
            font.pixelSize: 12
            color: root.runtimeConfig.base05
          }

          Text {
            id: dateText
            font.pixelSize: 12
            color: root.runtimeConfig.base05

            Timer {
              interval: 60000
              running: true
              repeat: true
              onTriggered: dateText.text = Qt.formatDate(new Date(), "dd MMM")
            }

            Component.onCompleted: dateText.text = Qt.formatDate(new Date(), "dd MMM")
          }
        }

        PopupWindow {
          id: calendarPopup
          visible: false
          color: "transparent"
          grabFocus: true
          implicitWidth: calendarPopupBody.implicitWidth
          implicitHeight: calendarPopupBody.implicitHeight

          anchor.item: dateRow
          anchor.rect.x: -(implicitWidth - dateRow.width) / 2
          anchor.rect.y: dateRow.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          onVisibleChanged: {
            if (!visible && root.popupCoordinator.activePopup === "calendar")
              root.popupCoordinator.closePopup("calendar")
          }

          Connections {
            target: root.popupCoordinator
            function onActivePopupChanged() {
              calendarPopup.visible = root.popupCoordinator.activePopup === "calendar"
            }
          }

          Rectangle {
            id: calendarPopupBody
            anchors.fill: parent
            implicitWidth: calendarPopupText.implicitWidth + 28
            implicitHeight: calendarPopupText.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Text {
              id: calendarPopupText
              anchors.centerIn: parent
              text: root.backend.calendarTooltipString
              textFormat: Text.RichText
              color: root.runtimeConfig.base05
              font.family: "monospace"
              font.pixelSize: 13
            }
          }
        }
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          text: "󰥔"
          font.pixelSize: 12
          color: root.runtimeConfig.base05
        }

        Text {
          id: timeText
          font.pixelSize: 12
          color: root.runtimeConfig.base05

          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
          }

          Component.onCompleted: timeText.text = Qt.formatTime(new Date(), "hh:mm")
        }
      }

      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
          if (mouse.button === Qt.RightButton) {
            root.backend.toggleCalendarView()
          } else {
            root.popupCoordinator.togglePopup("calendar")
            if (root.popupCoordinator.activePopup === "calendar")
              root.backend.refreshCalendar()
          }
        }
      }
    }

    Rectangle {
      id: powerPill
      width: 36
      height: parent.height
      radius: 12
      color: root.runtimeConfig.base00

      Item {
        id: powerItem
        anchors.centerIn: parent
        width: powerIcon.implicitWidth
        height: powerIcon.implicitHeight

        Text {
          id: powerIcon
          anchors.verticalCenter: parent.verticalCenter
          text: "⏻"
          font.pixelSize: 16
          color: root.runtimeConfig.base05
        }

        MouseArea {
          anchors.fill: parent
          onClicked: root.popupCoordinator.togglePopup("power")
        }

        PopupWindow {
          id: powerPopup
          visible: false
          color: "transparent"
          grabFocus: true
          implicitWidth: 180
          implicitHeight: powerPopupBody.implicitHeight

          anchor.item: powerIcon
          anchor.rect.x: -(implicitWidth - powerIcon.width) / 2
          anchor.rect.y: powerIcon.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          onVisibleChanged: {
            if (!visible && root.popupCoordinator.activePopup === "power")
              root.popupCoordinator.closePopup("power")
          }

          Connections {
            target: root.popupCoordinator
            function onActivePopupChanged() {
              powerPopup.visible = root.popupCoordinator.activePopup === "power"
            }
          }

          Rectangle {
            id: powerPopupBody
            anchors.fill: parent
            implicitHeight: powerOptions.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Column {
              id: powerOptions
              anchors.fill: parent
              anchors.margins: 10
              spacing: 4

              Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: shutdownMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"

                Row {
                  anchors.left: parent.left
                  anchors.leftMargin: 12
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 12

                  Text {
                    text: "󰐥"
                    color: root.runtimeConfig.base08
                    font.pixelSize: 16
                  }

                  Text {
                    text: "Shutdown"
                    color: root.runtimeConfig.base05
                    font.pixelSize: 13
                  }
                }

                MouseArea {
                  id: shutdownMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    root.popupCoordinator.closePopup("power")
                    root.backend.poweroff()
                  }
                }
              }

              Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: restartMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"

                Row {
                  anchors.left: parent.left
                  anchors.leftMargin: 12
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 12

                  Text {
                    text: "󰜉"
                    color: root.runtimeConfig.base0A
                    font.pixelSize: 16
                  }

                  Text {
                    text: "Restart"
                    color: root.runtimeConfig.base05
                    font.pixelSize: 13
                  }
                }

                MouseArea {
                  id: restartMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    root.popupCoordinator.closePopup("power")
                    root.backend.reboot()
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  TrayMenuPopup {
    id: trayMenuPopup
    runtimeConfig: root.runtimeConfig
    popupCoordinator: root.popupCoordinator
    anchorItem: tray
    maximumHeight: root.screen
      ? Math.max(120, root.screen.height - root.height - 20)
      : 600
  }
}
