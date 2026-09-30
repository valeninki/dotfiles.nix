pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

PanelWindow {
  id: root

  required property var runtimeConfig
  required property var notifications
  required property var outputScreen
  property bool drawerOpen: false
  property double nowMs: Date.now()

  function toggle() { drawerOpen = !drawerOpen }
  function close() { drawerOpen = false }
  function relativeTime(receivedAtMs) {
    const minutes = Math.max(0, Math.floor((nowMs - receivedAtMs) / 60000))
    if (minutes < 1) return "Just now"
    if (minutes < 60) return minutes + "m ago"
    const hours = Math.floor(minutes / 60)
    if (hours < 24) return hours + "h ago"
    return Math.floor(hours / 24) + "d ago"
  }

  screen: outputScreen
  anchors { top: true; bottom: true; left: true; right: true }
  exclusiveZone: 0
  color: "transparent"
  visible: drawerOpen && outputScreen !== null
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  onVisibleChanged: {
    if (visible) {
      nowMs = Date.now()
      sidebar.forceActiveFocus()
    }
  }

  Timer {
    interval: 60000
    running: root.drawerOpen
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.close()
  }

  FocusScope {
    id: sidebar
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: Math.min(400, root.width)
    Keys.onEscapePressed: root.close()

    Rectangle {
      anchors.fill: parent
      color: root.runtimeConfig.base00
      border.color: root.runtimeConfig.base02
      border.width: 1
    }
    MouseArea {
      anchors.fill: parent
      onClicked: function(mouse) { mouse.accepted = true }
    }

    Rectangle {
      id: header
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: 64
      color: "transparent"

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        text: "Notifications (" + root.notifications.historyModel.count + ")"
        color: root.runtimeConfig.base05
        font.pixelSize: 17
        font.bold: true
        textFormat: Text.PlainText
      }
      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: clearLabel.implicitWidth + 20
        height: 32
        radius: 6
        color: clearMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
        border.color: root.runtimeConfig.base02
        Text {
          id: clearLabel
          anchors.centerIn: parent
          text: "Clear All"
          color: root.runtimeConfig.base05
          font.pixelSize: 12
        }
        MouseArea {
          id: clearMouse
          anchors.fill: parent
          hoverEnabled: true
          enabled: root.notifications.historyModel.count > 0
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: root.notifications.clearAll()
        }
      }
    }

    ListView {
      id: list
      anchors.top: header.bottom
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 12
      spacing: 10
      clip: true
      model: root.notifications.historyModel
      section.property: "appName"
      section.criteria: ViewSection.FullString
      section.delegate: Component {
        Item {
          width: list.width
          height: 32

          Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: section || "Notification"
              font.pixelSize: 12
              font.bold: true
              color: root.runtimeConfig.base0D
              textFormat: Text.PlainText
            }
          }
        }
      }

      delegate: Rectangle {
        id: card
        required property int key
        required property string appName
        required property string iconSource
        required property string summary
        required property string body
        required property double receivedAtMs
        required property int urgency
        required property var actionLabels
        required property bool isLive
        width: list.width
        height: content.implicitHeight + 24
        radius: 9
        color: root.runtimeConfig.base00
        border.color: urgency === 2 ? root.runtimeConfig.base08 : root.runtimeConfig.base02
        border.width: 1

        Column {
          id: content
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 12
          spacing: 8

          Row {
            width: parent.width
            spacing: 8
            Item {
              width: 24
              height: 24
              visible: card.iconSource !== ""
              IconImage {
                anchors.fill: parent
                source: card.iconSource
                implicitSize: 24
                asynchronous: true
              }
            }
            Text {
              width: parent.width - (card.iconSource !== "" ? 32 : 0) - timeLabel.width - dismissButton.width - 16
              anchors.verticalCenter: parent.verticalCenter
              text: card.appName || "Notification"
              color: root.runtimeConfig.base05
              font.pixelSize: 12
              elide: Text.ElideRight
              textFormat: Text.PlainText
            }
            Text {
              id: timeLabel
              anchors.verticalCenter: parent.verticalCenter
              text: root.relativeTime(card.receivedAtMs)
              color: root.runtimeConfig.base03
              font.pixelSize: 11
            }
            Rectangle {
              id: dismissButton
              width: 24
              height: 24
              radius: 5
              color: dismissMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
              Text {
                anchors.centerIn: parent
                text: "×"
                color: root.runtimeConfig.base05
                font.pixelSize: 19
              }
              MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.notifications.dismissKey(card.key)
              }
            }
          }
          Text {
            width: parent.width
            text: card.summary
            visible: text !== ""
            color: card.urgency === 2 ? root.runtimeConfig.base08 : root.runtimeConfig.base05
            font.bold: true
            font.pixelSize: 14
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
          }
          Text {
            width: parent.width
            text: card.body
            visible: text !== ""
            color: root.runtimeConfig.base05
            font.pixelSize: 12
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
          }
          Flow {
            width: parent.width
            spacing: 6
            Repeater {
              model: card.actionLabels
              delegate: Rectangle {
                required property var modelData
                width: actionLabel.implicitWidth + 20
                height: 28
                radius: 6
                color: actionMouse.containsMouse && card.isLive ? root.runtimeConfig.base02 : "transparent"
                border.color: root.runtimeConfig.base02
                opacity: card.isLive ? 1 : 0.45
                Text {
                  id: actionLabel
                  anchors.centerIn: parent
                  text: modelData.label
                  color: root.runtimeConfig.base0D
                  font.pixelSize: 12
                  textFormat: Text.PlainText
                }
                MouseArea {
                  id: actionMouse
                  anchors.fill: parent
                  enabled: card.isLive
                  hoverEnabled: true
                  cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onClicked: root.notifications.invokeAction(card.key, modelData.identifier)
                }
              }
            }
          }
        }
      }
    }
    Text {
      anchors.centerIn: list
      visible: root.notifications.historyModel.count === 0
      text: "No notifications"
      color: root.runtimeConfig.base03
      font.pixelSize: 14
    }
  }
}
