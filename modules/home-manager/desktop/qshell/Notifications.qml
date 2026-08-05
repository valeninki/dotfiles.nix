pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

Scope {
  id: root

  required property var runtimeConfig
  required property var anchorWindow

  readonly property var currentNotification: notificationServer.trackedNotifications.values.length > 0
    ? notificationServer.trackedNotifications.values[0]
    : null

  function notificationIconSource(notification) {
    if (!notification)
      return ""

    const icon = notification.image || notification.appIcon || ""
    if (!icon)
      return ""

    return icon.includes("://") || icon.startsWith("/")
      ? icon
      : "image://icon/" + icon
  }

  function invokeDefaultAction() {
    if (!currentNotification)
      return

    const actions = currentNotification.actions
    for (let i = 0; i < actions.length; i++) {
      if (actions[i].identifier === "default") {
        actions[i].invoke()
        return
      }
    }
  }

  onCurrentNotificationChanged: {
    if (currentNotification)
      notificationTimer.restart()
    else
      notificationTimer.stop()
  }

  NotificationServer {
    id: notificationServer
    keepOnReload: true
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    onNotification: notification => notification.tracked = true
  }

  Timer {
    id: notificationTimer
    interval: root.runtimeConfig.notificationTimeoutMs
    repeat: false
    onTriggered: {
      if (root.currentNotification)
        root.currentNotification.expire()
    }
  }

  PopupWindow {
    id: notificationPopup
    visible: root.currentNotification !== null
    color: "transparent"
    grabFocus: false
    implicitWidth: 360
    implicitHeight: notificationCard.implicitHeight

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow.width - implicitWidth - 10
    anchor.rect.y: root.anchorWindow.height + 10
    anchor.adjustment: PopupAdjustment.Slide

    Rectangle {
      id: notificationCard
      anchors.fill: parent
      implicitHeight: Math.max(
        notificationTextColumn.implicitHeight,
        notificationIconSlot.visible ? notificationIconSlot.height : 0
      ) + 32
      color: root.runtimeConfig.base00
      radius: 12
      border.color: root.runtimeConfig.base02
      border.width: 1

      MouseArea {
        anchors.fill: parent
        enabled: {
          const notification = root.currentNotification
          if (!notification)
            return false

          const actions = notification.actions
          for (let i = 0; i < actions.length; i++) {
            if (actions[i].identifier === "default")
              return true
          }
          return false
        }
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.invokeDefaultAction()
      }

      Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: parent.height - 16
        color: root.runtimeConfig.base0D
        radius: 2
      }

      Row {
        id: notificationContent
        anchors.fill: parent
        anchors.margins: 16
        spacing: notificationIconSlot.visible ? 12 : 0

        Item {
          id: notificationIconSlot
          width: 40
          height: 40
          visible: notificationIcon.source !== "" && notificationIcon.status === Image.Ready

          IconImage {
            id: notificationIcon
            anchors.fill: parent
            source: root.notificationIconSource(root.currentNotification)
            implicitSize: 40
            asynchronous: true
          }
        }

        Column {
          id: notificationTextColumn
          width: notificationPopup.implicitWidth
            - 32
            - (notificationIconSlot.visible ? notificationIconSlot.width + notificationContent.spacing : 0)
          spacing: 6

          Text {
            width: parent.width
            text: root.currentNotification
              ? (root.currentNotification.summary || root.currentNotification.appName || "Notification")
              : ""
            color: root.runtimeConfig.base05
            font.pixelSize: 14
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
          }

          Text {
            width: parent.width
            text: root.currentNotification ? root.currentNotification.body : ""
            visible: text !== ""
            color: root.runtimeConfig.base05
            font.pixelSize: 13
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
          }

          Flow {
            width: parent.width
            spacing: 6

            Repeater {
              model: root.currentNotification ? root.currentNotification.actions : []

              delegate: Rectangle {
                required property var modelData

                visible: modelData.identifier !== "default" && modelData.text !== ""
                width: visible ? actionText.implicitWidth + 20 : 0
                height: visible ? 28 : 0
                radius: 7
                color: actionMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
                border.width: 1
                border.color: root.runtimeConfig.base02

                Text {
                  id: actionText
                  anchors.centerIn: parent
                  text: modelData.text
                  color: root.runtimeConfig.base0D
                  font.pixelSize: 12
                  textFormat: Text.PlainText
                }

                MouseArea {
                  id: actionMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: modelData.invoke()
                }
              }
            }
          }
        }
      }
    }
  }
}
