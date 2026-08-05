pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.I3
import QtQuick

PanelWindow {
  id: root

  required property var runtimeConfig
  required property var backend
  required property var popupCoordinator

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
            font: volumeText.font
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
    width: Math.min(titleRow.implicitWidth + 32, 300)
    radius: 12
    color: root.runtimeConfig.base00
    visible: windowTitle.text !== ""

    Row {
      id: titleRow
      anchors.centerIn: parent
      spacing: 12

      Text {
        id: windowIcon
        text: root.iconFor(root.backend.focusedWindowAppId)
        color: root.runtimeConfig.base05
        font: volumeIcon.font
      }

      Text {
        id: windowTitle
        width: Math.min(implicitWidth, 300 - windowIcon.implicitWidth - titleRow.spacing - 32)
        elide: Text.ElideRight
        text: root.backend.focusedWindowTitle
        color: root.runtimeConfig.base05
        font: volumeText.font
      }
    }
  }

  Rectangle {
    id: rightPill
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: 10
    width: controlsRow.implicitWidth + 32
    radius: 12
    color: root.runtimeConfig.base00

    Row {
      id: controlsRow
      anchors.centerIn: parent
      spacing: 16

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
        id: volumeItem
        anchors.verticalCenter: parent.verticalCenter
        width: volumeRow.implicitWidth
        height: volumeRow.implicitHeight

        Row {
          id: volumeRow
          anchors.centerIn: parent
          spacing: 6

          Text {
            id: volumeIcon
            text: root.backend.volumeMuted || Number(root.backend.volumeLevel) <= 0
              ? "󰝟"
              : Number(root.backend.volumeLevel) <= 50
                ? "󰖀"
                : "󰕾"
            color: root.runtimeConfig.base05
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            id: volumeText
            text: root.backend.volumeLevel + "%"
            color: root.runtimeConfig.base05
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: volumeMouse
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
              root.backend.toggleVolumeMute()
            else if (mouse.button === Qt.RightButton)
              root.backend.openVolumeControl()
          }
          onEntered: root.backend.refreshVolumeTooltip()
          onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
              root.backend.adjustVolume(5)
            else if (wheel.angleDelta.y < 0)
              root.backend.adjustVolume(-5)
            wheel.accepted = true
          }
        }

        PopupWindow {
          visible: volumeMouse.containsMouse
          color: "transparent"
          grabFocus: false
          implicitWidth: volumePopupBody.implicitWidth
          implicitHeight: volumePopupBody.implicitHeight

          anchor.item: volumeIcon
          anchor.rect.x: -(implicitWidth - volumeIcon.width) / 2
          anchor.rect.y: volumeIcon.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

          Rectangle {
            id: volumePopupBody
            anchors.fill: parent
            implicitWidth: volumePopupText.implicitWidth + 28
            implicitHeight: volumePopupText.implicitHeight + 20
            color: root.runtimeConfig.base00
            radius: 8

            Text {
              id: volumePopupText
              anchors.centerIn: parent
              text: root.backend.volumeTooltipString
              color: root.runtimeConfig.base05
              font.pixelSize: 13
            }
          }
        }
      }

      Item {
        id: brightnessItem
        visible: root.runtimeConfig.backlightEnabled
        anchors.verticalCenter: parent.verticalCenter
        width: brightnessRow.implicitWidth
        height: brightnessRow.implicitHeight

        Row {
          id: brightnessRow
          anchors.centerIn: parent
          spacing: 6

          Text {
            id: brightnessIcon
            text: "󰃠"
            color: root.runtimeConfig.base05
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: root.backend.brightnessLevel + "%"
            color: root.runtimeConfig.base05
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }
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
          text: "󰁹"
          font.pixelSize: 12
          color: root.runtimeConfig.base05
        }

        Text {
          text: root.backend.batteryLevel + "%"
          font.pixelSize: 12
          color: root.runtimeConfig.base05
        }
      }

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
              onTriggered: dateText.text = Qt.formatDate(new Date(), "dd MMM yyyy")
            }

            Component.onCompleted: dateText.text = Qt.formatDate(new Date(), "dd MMM yyyy")
          }
        }

        MouseArea {
          id: calendarMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.backend.toggleCalendarView()
          onEntered: root.backend.refreshCalendar()
        }

        PopupWindow {
          visible: calendarMouse.containsMouse
          color: "transparent"
          grabFocus: false
          implicitWidth: calendarPopupBody.implicitWidth
          implicitHeight: calendarPopupBody.implicitHeight

          anchor.item: dateRow
          anchor.rect.x: -(implicitWidth - dateRow.width) / 2
          anchor.rect.y: dateRow.height + 8
          anchor.edges: Edges.Top | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.adjustment: PopupAdjustment.SlideX

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

      Item {
        id: powerItem
        width: powerIcon.implicitWidth
        height: powerIcon.implicitHeight

        Text {
          id: powerIcon
          anchors.verticalCenter: parent.verticalCenter
          text: "󰐥"
          font.pixelSize: 12
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
