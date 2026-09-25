pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

Scope {
  id: root

  required property var runtimeConfig
  required property var anchorWindow

  readonly property var currentNotification: {
    const notifications = notificationServer.trackedNotifications.values
    // Keep arrival order within each urgency level, but show critical alerts first.
    for (let i = 0; i < notifications.length; i++) {
      if (notifications[i].urgency === 2)
        return notifications[i]
    }
    return notifications.length > 0 ? notifications[0] : null
  }
  readonly property bool currentIsCritical: currentNotification !== null && currentNotification.urgency === 2

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
    if (currentNotification && !currentIsCritical)
      notificationTimer.restart()
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
    running: root.currentNotification !== null && !root.currentIsCritical
    repeat: false
    onTriggered: {
      if (root.currentNotification && !root.currentIsCritical)
        root.currentNotification.expire()
    }
  }

  PopupWindow {
    id: notificationPopup
    visible: root.currentNotification !== null && root.anchorWindow !== null
    color: "transparent"
    grabFocus: false
    implicitWidth: 360
    implicitHeight: notificationCard.implicitHeight

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow ? root.anchorWindow.width - implicitWidth - 10 : 0
    anchor.rect.y: root.anchorWindow ? root.anchorWindow.height + 10 : 0
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
      border.color: root.currentIsCritical ? root.runtimeConfig.base08 : root.runtimeConfig.base02
      border.width: root.currentIsCritical ? 2 : 1

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
        color: root.currentIsCritical ? root.runtimeConfig.base08 : root.runtimeConfig.base0D
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

          Row {
            width: parent.width
            spacing: 8

            Text {
              width: parent.width - dismissButton.width - parent.spacing
              text: root.currentNotification
                ? (root.currentNotification.summary || root.currentNotification.appName || "Notification")
                : ""
              color: root.currentIsCritical ? root.runtimeConfig.base08 : root.runtimeConfig.base05
              font.pixelSize: 14
              textFormat: Text.PlainText
              wrapMode: Text.Wrap
            }

            Rectangle {
              id: dismissButton
              width: 24
              height: 24
              radius: 6
              color: dismissMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"

              Text {
                anchors.centerIn: parent
                text: "×"
                color: root.currentIsCritical ? root.runtimeConfig.base08 : root.runtimeConfig.base05
                font.pixelSize: 20
                textFormat: Text.PlainText
              }

              MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.currentNotification)
                    root.currentNotification.dismiss()
                }
              }
            }
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
