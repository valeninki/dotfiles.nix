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
  property var expandedApps: ({})

  function toggleApp(app) {
    const updated = Object.assign({}, expandedApps)
    updated[app] = !updated[app]
    expandedApps = updated
  }

  function cleanBody(body) {
    return body.replace(/<https?:\/\/[^>\s]+>|https?:\/\/[^\s<>"']+/gi, function(url) {
      return /(?:cdn\.discordapp\.(?:com|net)|media\.discordapp\.net|\.(?:png|jpe?g|gif|webp)(?:[?#]|>?$))/i.test(url)
        ? "󰋩 Image" : url
    })
  }

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
          textFormat: Text.PlainText
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

    Flickable {
      id: list
      anchors.top: header.bottom
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 12
      clip: true
      contentWidth: width
      contentHeight: groupsColumn.implicitHeight

      Column {
        id: groupsColumn
        width: list.width
        spacing: 10

        Repeater {
          model: root.notifications.appGroups
          delegate: Rectangle {
            id: groupCard
            required property var modelData
            readonly property string appName: modelData.appName
            readonly property var items: modelData.items
            readonly property bool expanded: root.expandedApps[appName] === true
            width: groupsColumn.width
            height: groupContent.implicitHeight + 12
            radius: 9
            color: root.runtimeConfig.base00
            border.color: root.runtimeConfig.base02
            border.width: 1

            Column {
              id: groupContent
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.top: parent.top
              anchors.margins: 6
              spacing: 4

              Item {
                width: parent.width
                height: 36

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.toggleApp(groupCard.appName)
                }

                Row {
                  width: Math.max(0, parent.width - rightControls.width - 16)
                  anchors.left: parent.left
                  anchors.leftMargin: 8
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 8
                  Text {
                    width: Math.max(0, parent.width - countBadge.width - 8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: groupCard.appName || "Notification"
                    color: root.runtimeConfig.base0D
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                  }
                  Rectangle {
                    id: countBadge
                    width: countLabel.implicitWidth + 14
                    height: 20
                    radius: 10
                    color: root.runtimeConfig.base01
                    Text {
                      id: countLabel
                      anchors.centerIn: parent
                      text: String(groupCard.items.length)
                      color: root.runtimeConfig.base05
                      font.pixelSize: 11
                      textFormat: Text.PlainText
                    }
                  }
                }

                Row {
                  id: rightControls
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 4
                  Rectangle {
                    width: clearAppLabel.implicitWidth + 12
                    height: 28
                    radius: 5
                    color: clearAppMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
                    Text {
                      id: clearAppLabel
                      anchors.centerIn: parent
                      text: "Clear"
                      color: root.runtimeConfig.base05
                      font.pixelSize: 11
                      textFormat: Text.PlainText
                    }
                    MouseArea {
                      id: clearAppMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.notifications.clearApp(groupCard.appName)
                    }
                  }
                  Text {
                    width: 28
                    height: 28
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: groupCard.expanded ? "󰅂" : "󰅁"
                    color: root.runtimeConfig.base05
                    font.pixelSize: 16
                    textFormat: Text.PlainText
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.toggleApp(groupCard.appName)
                    }
                  }
                }
              }

              Repeater {
                model: groupCard.expanded ? groupCard.items : groupCard.items.slice(0, 2)
                delegate: Rectangle {
                  id: card
                  required property var modelData
                  readonly property int key: modelData.key
                  readonly property string summary: modelData.summary
                  readonly property string body: modelData.body
                  readonly property double receivedAtMs: modelData.receivedAtMs
                  readonly property int urgency: modelData.urgency
                  readonly property var actionLabels: modelData.actionLabels
                  readonly property bool isLive: modelData.isLive
                  width: groupContent.width
                  height: content.implicitHeight + 16
                  radius: 6
                  color: root.runtimeConfig.base01
                  border.color: urgency === 2 ? root.runtimeConfig.base08 : root.runtimeConfig.base02
                  border.width: 1

                  Column {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    spacing: 5

                    Row {
                      width: parent.width
                      spacing: 6
                      Text {
                        width: Math.max(0, parent.width - timeLabel.width - dismissButton.width - 12)
                        anchors.verticalCenter: parent.verticalCenter
                        text: card.summary || "Notification"
                        color: card.urgency === 2 ? root.runtimeConfig.base08 : root.runtimeConfig.base05
                        font.bold: true
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                      }
                      Text {
                        id: timeLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.relativeTime(card.receivedAtMs)
                        color: root.runtimeConfig.base03
                        font.pixelSize: 11
                        textFormat: Text.PlainText
                      }
                      Rectangle {
                        id: dismissButton
                        width: 22
                        height: 22
                        radius: 5
                        color: dismissMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
                        Text {
                          anchors.centerIn: parent
                          text: "×"
                          color: root.runtimeConfig.base05
                          font.pixelSize: 18
                          textFormat: Text.PlainText
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
                      text: root.cleanBody(card.body)
                      visible: text !== ""
                      color: root.runtimeConfig.base05
                      font.pixelSize: 12
                      wrapMode: Text.Wrap
                      maximumLineCount: 2
                      elide: Text.ElideRight
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
                          height: 26
                          radius: 6
                          color: actionMouse.containsMouse && card.isLive ? root.runtimeConfig.base02 : "transparent"
                          border.color: root.runtimeConfig.base02
                          border.width: 1
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
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !groupCard.expanded && groupCard.items.length > 2
                text: "+ " + (groupCard.items.length - 2) + " more..."
                color: root.runtimeConfig.base0D
                font.pixelSize: 12
                textFormat: Text.PlainText
                height: visible ? 28 : 0
                verticalAlignment: Text.AlignVCenter
                MouseArea {
                  anchors.fill: parent
                  enabled: parent.visible
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.toggleApp(groupCard.appName)
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
      textFormat: Text.PlainText
      font.pixelSize: 14
    }
  }
}
