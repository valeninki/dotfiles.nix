pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

Scope {
  id: root

  required property var runtimeConfig
  required property var anchorWindow

  readonly property alias historyModel: history
  property var liveByKey: ({})
  property var keyByNotificationId: ({})
  property int nextHistoryKey: 0
  property var toastQueue: []
  property int currentToastKey: -1
  readonly property var currentNotification: liveByKey[currentToastKey] || null
  readonly property bool currentIsCritical: currentNotification !== null && currentNotification.urgency === 2

  ListModel { id: history }

  function historyIndex(key) {
    for (let i = 0; i < history.count; i++) {
      if (history.get(i).key === key)
        return i
    }
    return -1
  }

  function notificationIconSource(notification) {
    if (!notification)
      return ""
    const icon = notification.image || notification.appIcon || ""
    return icon ? (icon.includes("://") || icon.startsWith("/") ? icon : "image://icon/" + icon) : ""
  }

  function showNextToast() {
    if (currentToastKey !== -1)
      return
    const queue = toastQueue.slice()
    while (queue.length > 0) {
      const key = queue.shift()
      if (liveByKey[key] && historyIndex(key) !== -1) {
        toastQueue = queue
        currentToastKey = key
        if (liveByKey[key].urgency !== 2)
          notificationTimer.restart()
        return
      }
    }
    toastQueue = []
  }

  function advanceToast() {
    notificationTimer.stop()
    currentToastKey = -1
    showNextToast()
  }

  function recordNotification(notification) {
    const id = notification.id
    const idKey = id === undefined || id === null ? "" : String(id)
    let key = idKey !== "" && keyByNotificationId[idKey] !== undefined
      ? keyByNotificationId[idKey] : -1
    if (key !== -1 && historyIndex(key) === -1)
      key = -1
    if (key === -1)
      key = nextHistoryKey++

    const previous = liveByKey[key]
    const actions = notification.actions || []
    const labels = []
    for (let i = 0; i < actions.length; i++) {
      if (actions[i].identifier !== "default" && actions[i].text)
        labels.push({ identifier: String(actions[i].identifier), label: String(actions[i].text) })
    }
    const row = {
      key: key,
      appName: notification.appName || "",
      iconSource: notificationIconSource(notification),
      summary: notification.summary || "",
      body: notification.body || "",
      receivedAtMs: Date.now(),
      urgency: notification.urgency,
      actionLabels: labels,
      isLive: true
    }
    // Keep app sections contiguous and newest entries first within each section.
    const index = historyIndex(key)
    if (index !== -1)
      history.remove(index)
    let insertAt = 0
    for (let i = 0; i < history.count; i++) {
      if (history.get(i).appName === row.appName) {
        insertAt = i
        break
      }
    }
    history.insert(insertAt, row)

    const updated = Object.assign({}, liveByKey)
    updated[key] = notification
    liveByKey = updated
    if (idKey !== "") {
      const ids = Object.assign({}, keyByNotificationId)
      ids[idKey] = key
      keyByNotificationId = ids
    }
    // A replacement may close the previous object later. Only the current object may invalidate this row.
    notification.closed.connect(function() {
      if (root.liveByKey[key] !== notification)
        return
      const remaining = Object.assign({}, root.liveByKey)
      delete remaining[key]
      root.liveByKey = remaining
      if (idKey !== "" && root.keyByNotificationId[idKey] === key) {
        const ids = Object.assign({}, root.keyByNotificationId)
        delete ids[idKey]
        root.keyByNotificationId = ids
      }
      const rowIndex = root.historyIndex(key)
      if (rowIndex !== -1)
        root.history.setProperty(rowIndex, "isLive", false)
      if (root.currentToastKey === key)
        root.advanceToast()
      else
        root.toastQueue = root.toastQueue.filter(k => k !== key)
    })

    if (previous && previous !== notification && currentToastKey === key)
      notificationTimer.stop()
    if (notification.urgency === 2 && currentToastKey !== -1 && !currentIsCritical) {
      // Interrupt a normal toast without losing it; critical alerts take priority.
      toastQueue = [currentToastKey].concat(toastQueue.filter(k => k !== currentToastKey))
      notificationTimer.stop()
      currentToastKey = -1
    }
    if (currentToastKey !== key && toastQueue.indexOf(key) === -1) {
      if (notification.urgency === 2)
        toastQueue = [key].concat(toastQueue)
      else
        toastQueue = toastQueue.concat([key])
    }
    if (currentToastKey === key && notification.urgency !== 2)
      notificationTimer.restart()
    showNextToast()
    while (history.count > 100) {
      let oldest = 0
      for (let i = 1; i < history.count; i++) {
        if (history.get(i).receivedAtMs < history.get(oldest).receivedAtMs)
          oldest = i
      }
      dismissKey(history.get(oldest).key)
    }
  }

  function dismissKey(key) {
    const index = historyIndex(key)
    if (index === -1)
      return
    history.remove(index)
    const notification = liveByKey[key]
    const remaining = Object.assign({}, liveByKey)
    delete remaining[key]
    liveByKey = remaining
    const ids = Object.assign({}, keyByNotificationId)
    for (const id in ids) {
      if (ids[id] === key)
        delete ids[id]
    }
    keyByNotificationId = ids
    toastQueue = toastQueue.filter(k => k !== key)
    if (currentToastKey === key)
      advanceToast()
    if (notification)
      notification.dismiss()
  }

  function clearAll() {
    while (history.count > 0)
      dismissKey(history.get(0).key)
  }

  function invokeAction(key, identifier) {
    if (historyIndex(key) === -1)
      return
    const notification = liveByKey[key]
    if (!notification)
      return
    const actions = notification.actions || []
    for (let i = 0; i < actions.length; i++) {
      if (actions[i].identifier === identifier) {
        actions[i].invoke()
        return
      }
    }
  }

  function invokeDefaultAction() {
    invokeAction(currentToastKey, "default")
  }

  NotificationServer {
    id: notificationServer
    keepOnReload: true
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    onNotification: function(notification) {
      notification.tracked = true
      root.recordNotification(notification)
    }
  }

  Timer {
    id: notificationTimer
    interval: root.runtimeConfig.notificationTimeoutMs
    repeat: false
    onTriggered: {
      if (root.currentToastKey !== -1 && !root.currentIsCritical)
        root.advanceToast()
    }
  }

  PopupWindow {
    id: notificationPopup
    visible: root.currentToastKey !== -1 && root.anchorWindow !== null
    color: "transparent"
    grabFocus: false
    implicitWidth: 360
    implicitHeight: notificationCard.implicitHeight

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow ? root.anchorWindow.width - implicitWidth - 10 : 0
    anchor.rect.y: root.anchorWindow ? root.anchorWindow.height + 10 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX

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
                    root.advanceToast()
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
