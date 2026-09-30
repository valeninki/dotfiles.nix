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
  property var closedHandlersByKey: ({})
  property int nextHistoryKey: 0
  property var toastQueue: []
  property var activeToast: null
  property bool isShowingToast: false
  readonly property bool currentIsCritical: activeToast !== null && activeToast.urgency === 2

  onAnchorWindowChanged: {
    if (!anchorWindow)
      notificationTimer.stop()
    else if (isShowingToast && !currentIsCritical)
      notificationTimer.restart()
    else
      displayNextToast()
  }

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

  function makeToastSnapshot(notification, key) {
    return Object.freeze({
      appName: String(notification.appName || ""),
      summary: String(notification.summary || ""),
      body: String(notification.body || ""),
      icon: String(notificationIconSource(notification)),
      urgency: Number(notification.urgency),
      key: key
    })
  }

  function toastActions(key) {
    const index = historyIndex(key)
    return index === -1 ? [] : history.get(index).actionLabels || []
  }

  function hasDefaultAction(key) {
    const notification = liveByKey[key]
    if (!notification)
      return false
    const actions = notification.actions || []
    for (let i = 0; i < actions.length; i++) {
      if (actions[i].identifier === "default")
        return true
    }
    return false
  }

  function enqueueToast(snapshot) {
    toastQueue = toastQueue.concat([snapshot])
    if (isShowingToast && !currentIsCritical && toastQueue.length >= 3 && anchorWindow)
      notificationTimer.restart()
    displayNextToast()
  }

  function displayNextToast() {
    if (isShowingToast || drainTimer.running || !anchorWindow || toastQueue.length === 0)
      return
    const queue = toastQueue.slice()
    activeToast = queue.shift()
    toastQueue = queue
    isShowingToast = true
    if (currentIsCritical)
      notificationTimer.stop()
    else
      notificationTimer.restart()
  }

  function dismissActiveToast() {
    if (!isShowingToast)
      return
    notificationTimer.stop()
    isShowingToast = false
    activeToast = null
    drainTimer.restart()
  }

  function disconnectClosedHandler(key) {
    const entry = closedHandlersByKey[key]
    if (!entry)
      return
    entry.notification.closed.disconnect(entry.handler)
    const handlers = Object.assign({}, closedHandlersByKey)
    delete handlers[key]
    closedHandlersByKey = handlers
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
    // Disconnect replaced objects so a long-lived server cannot retain old closures.
    disconnectClosedHandler(key)
    const closedHandler = function() {
      root.disconnectClosedHandler(key)
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
      // Closed DBus handles do not invalidate already captured toast snapshots.
    }
    notification.closed.connect(closedHandler)
    const handlers = Object.assign({}, closedHandlersByKey)
    handlers[key] = { notification: notification, handler: closedHandler }
    closedHandlersByKey = handlers

    while (history.count > 100) {
      let oldest = 0
      for (let i = 1; i < history.count; i++) {
        if (history.get(i).receivedAtMs < history.get(oldest).receivedAtMs)
          oldest = i
      }
      dismissKey(history.get(oldest).key)
    }
    return key
  }

  function dismissKey(key) {
    const index = historyIndex(key)
    if (index === -1)
      return
    history.remove(index)
    const notification = liveByKey[key]
    disconnectClosedHandler(key)
    const remaining = Object.assign({}, liveByKey)
    delete remaining[key]
    liveByKey = remaining
    const ids = Object.assign({}, keyByNotificationId)
    for (const id in ids) {
      if (ids[id] === key)
        delete ids[id]
    }
    keyByNotificationId = ids
    toastQueue = toastQueue.filter(toast => toast.key !== key)
    if (activeToast && activeToast.key === key)
      dismissActiveToast()
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
    if (activeToast)
      invokeAction(activeToast.key, "default")
  }

  NotificationServer {
    id: notificationServer
    keepOnReload: true
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    onNotification: function(notification) {
      notification.tracked = true
      const key = root.recordNotification(notification)
      root.enqueueToast(root.makeToastSnapshot(notification, key))
    }
  }

  Timer {
    id: notificationTimer
    interval: root.currentIsCritical ? 0
      : root.toastQueue.length >= 3 ? 1200 : root.runtimeConfig.notificationTimeoutMs
    repeat: false
    onTriggered: root.dismissActiveToast()
  }

  Timer {
    id: drainTimer
    interval: 80
    repeat: false
    onTriggered: root.displayNextToast()
  }

  PopupWindow {
    id: notificationPopup
    visible: root.isShowingToast && root.activeToast !== null && root.anchorWindow !== null
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
        enabled: root.activeToast ? root.hasDefaultAction(root.activeToast.key) : false
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
            source: root.activeToast ? root.activeToast.icon : ""
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
              text: root.activeToast
                ? (root.activeToast.summary || root.activeToast.appName || "Notification")
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
                  root.dismissActiveToast()
                }
              }
            }
          }

          Text {
            width: parent.width
            text: root.activeToast ? root.activeToast.body : ""
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
              model: root.activeToast ? root.toastActions(root.activeToast.key) : []

              delegate: Rectangle {
                required property var modelData

                visible: modelData.identifier !== "default" && modelData.label !== ""
                width: visible ? actionText.implicitWidth + 20 : 0
                height: visible ? 28 : 0
                radius: 7
                color: actionMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
                border.width: 1
                border.color: root.runtimeConfig.base02

                Text {
                  id: actionText
                  anchors.centerIn: parent
                  text: root.activeToast ? modelData.label : ""
                  color: root.runtimeConfig.base0D
                  font.pixelSize: 12
                  textFormat: Text.PlainText
                }

                MouseArea {
                  id: actionMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (root.activeToast)
                      root.invokeAction(root.activeToast.key, modelData.identifier)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
