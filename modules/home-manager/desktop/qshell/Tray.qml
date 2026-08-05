pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
  id: root

  required property var runtimeConfig
  required property var popupCoordinator
  required property var menuPopup

  property bool opened: false

  anchors.verticalCenter: parent.verticalCenter
  spacing: 8

  function closeDrawer() {
    opened = false
    menuPopup.closeMenu()
  }

  Text {
    id: drawerToggle
    anchors.verticalCenter: parent.verticalCenter
    text: root.opened ? "󰁞" : "󰁆"
    color: root.runtimeConfig.base05
    font.pixelSize: 14

    MouseArea {
      anchors.fill: parent
      onClicked: {
        root.opened = !root.opened
        if (!root.opened)
          root.menuPopup.closeMenu()
      }
    }
  }

  Row {
    visible: root.opened
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8

    Repeater {
      model: SystemTray.items

      delegate: Item {
        id: trayItem
        required property var modelData

        width: 22
        height: 22

        function openMenu() {
          root.menuPopup.openMenu(trayItem, menuOpener)
        }

        QsMenuOpener {
          id: menuOpener
          menu: trayItem.modelData.menu
        }

        Component.onDestruction: {
          if (root.menuPopup.menuOwner === trayItem)
            root.menuPopup.closeMenu()
        }

        Connections {
          target: trayItem.modelData
          function onHasMenuChanged() {
            if (!trayItem.modelData.hasMenu && root.menuPopup.menuOwner === trayItem)
              root.menuPopup.closeMenu()
          }
        }

        Image {
          id: trayImage
          anchors.fill: parent
          source: modelData.icon
          sourceSize: Qt.size(18, 18)
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          visible: status === Image.Ready
        }

        Text {
          anchors.centerIn: parent
          text: "󰏫"
          color: root.runtimeConfig.base05
          font.pixelSize: 14
          visible: trayImage.status !== Image.Ready
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
              if (modelData.onlyMenu && modelData.hasMenu)
                trayItem.openMenu()
              else
                modelData.activate()
            } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
              trayItem.openMenu()
            }
          }
        }
      }
    }
  }
}
