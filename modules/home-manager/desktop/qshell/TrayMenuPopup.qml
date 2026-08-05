pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

PopupWindow {
  id: root

  required property var runtimeConfig
  required property var popupCoordinator
  required property var anchorItem
  property int maximumHeight: 600
  property var menuOwner: null
  property var rootMenuOpener: null
  property bool menuReady: false
  property real anchorX: 0
  property real anchorY: 0

  visible: false
  color: "transparent"
  grabFocus: true
  implicitWidth: 224
  implicitHeight: Math.min(
    (menuStack.currentItem ? menuStack.currentItem.implicitHeight : 0) + 16,
    maximumHeight
  )

  anchor.item: anchorItem
  anchor.rect.x: anchorX
  anchor.rect.y: anchorY
  anchor.edges: Edges.Top | Edges.Left
  anchor.gravity: Edges.Bottom | Edges.Right
  anchor.adjustment: PopupAdjustment.SlideX
    | PopupAdjustment.SlideY
    | PopupAdjustment.ResizeY

  function openMenu(owner, opener) {
    closeMenu()
    const position = owner.mapToItem(anchorItem, 0, 0)
    anchorX = position.x + owner.width - implicitWidth
    anchorY = position.y + owner.height + 8
    menuOwner = owner
    rootMenuOpener = opener
    menuStack.push(menuPage, { menuOpener: opener })
    popupCoordinator.openPopup("tray")
    menuOpenTimer.attempts = 0
    menuOpenTimer.start()
  }

  function closeMenu() {
    visible = false
    popupCoordinator.closePopup("tray")
    resetMenu()
  }

  function resetMenu() {
    menuOpenTimer.stop()
    menuReady = false
    menuStack.clear()
    rootMenuOpener = null
    menuOwner = null
  }

  onVisibleChanged: {
    if (!visible && menuReady) {
      popupCoordinator.closePopup("tray")
      resetMenu()
    }
  }

  Connections {
    target: root.popupCoordinator
    function onActivePopupChanged() {
      if (root.popupCoordinator.activePopup !== "tray" && root.rootMenuOpener !== null) {
        root.visible = false
        root.resetMenu()
      }
    }
  }

  Component {
    id: menuPage

    Item {
      id: page
      required property var menuOpener

      width: menuStack.width
      height: menuStack.height
      implicitHeight: menuColumn.calculatedHeight

      Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: menuColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
          policy: menuColumn.implicitHeight > page.height
            ? ScrollBar.AlwaysOn
            : ScrollBar.AsNeeded
        }

        Column {
          id: menuColumn
          readonly property real calculatedHeight: {
            const entries = page.menuOpener.children
              ? page.menuOpener.children.values : []
            let total = menuStack.depth > 1 ? 34 : 0
            for (let i = 0; i < entries.length; i++)
              total += entries[i].isSeparator ? 9 : 36

            const itemCount = entries.length + (menuStack.depth > 1 ? 1 : 0)
            return total + Math.max(0, itemCount - 1) * spacing
          }

          width: parent.width
          height: calculatedHeight
          spacing: 2

          Rectangle {
            width: parent.width
            height: visible ? 34 : 0
            visible: menuStack.depth > 1
            radius: 8
            color: backMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"

            Row {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              spacing: 10

              Text {
                text: "‹"
                color: root.runtimeConfig.base0D
                font.pixelSize: 18
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Back"
                color: root.runtimeConfig.base05
                font.pixelSize: 13
              }
            }

            MouseArea {
              id: backMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: menuStack.pop()
            }
          }

          Repeater {
            model: page.menuOpener.children

            delegate: Item {
              id: menuEntry
              required property var modelData

              width: menuColumn.width
              height: modelData.isSeparator ? 9 : 36
              opacity: modelData.enabled ? 1 : 0.45

              QsMenuOpener {
                id: submenuOpener
                menu: menuEntry.modelData
              }

              Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: 1
                visible: menuEntry.modelData.isSeparator
                color: root.runtimeConfig.base02
              }

              Rectangle {
                anchors.fill: parent
                visible: !menuEntry.modelData.isSeparator
                radius: 8
                color: entryMouse.containsMouse ? root.runtimeConfig.base02 : "transparent"
              }

              Item {
                id: entryVisual
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 18
                height: 18
                visible: !menuEntry.modelData.isSeparator

                Rectangle {
                  anchors.centerIn: parent
                  width: 14
                  height: 14
                  radius: menuEntry.modelData.buttonType === 2 ? 7 : 3
                  visible: menuEntry.modelData.buttonType !== 0
                  color: "transparent"
                  border.width: 1
                  border.color: root.runtimeConfig.base05

                  Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: menuEntry.modelData.buttonType === 2 ? 4 : 2
                    visible: menuEntry.modelData.checkState === Qt.Checked
                    color: root.runtimeConfig.base0D
                  }
                }

                IconImage {
                  anchors.fill: parent
                  source: menuEntry.modelData.icon || ""
                  implicitSize: 18
                  asynchronous: true
                  visible: menuEntry.modelData.buttonType === 0 && source !== ""
                }
              }

              Text {
                anchors.left: entryVisual.right
                anchors.leftMargin: 10
                anchors.right: entryArrow.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: !menuEntry.modelData.isSeparator
                text: (menuEntry.modelData.text || "").replace(/&/g, "")
                color: root.runtimeConfig.base05
                font.pixelSize: 13
                elide: Text.ElideRight
              }

              Text {
                id: entryArrow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                visible: !menuEntry.modelData.isSeparator && menuEntry.modelData.hasChildren
                text: "›"
                color: root.runtimeConfig.base0D
                font.pixelSize: 18
              }

              MouseArea {
                id: entryMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: !menuEntry.modelData.isSeparator && menuEntry.modelData.enabled
                onClicked: {
                  if (menuEntry.modelData.hasChildren) {
                    menuStack.push(menuPage, { menuOpener: submenuOpener })
                  } else {
                    menuEntry.modelData.triggered()
                    root.closeMenu()
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Timer {
    id: menuOpenTimer
    property int attempts: 0

    interval: 16
    repeat: true
    onTriggered: {
      attempts++
      if (menuStack.currentItem && menuStack.currentItem.implicitHeight > 0) {
        stop()
        root.menuReady = true
        if (root.popupCoordinator.activePopup === "tray")
          root.visible = true
        else
          root.resetMenu()
      } else if (attempts >= 60) {
        stop()
        root.closeMenu()
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: root.runtimeConfig.base00
    radius: 10
    border.width: 1
    border.color: root.runtimeConfig.base02

    StackView {
      id: menuStack
      anchors.fill: parent
      anchors.margins: 8
      clip: true
    }
  }
}
