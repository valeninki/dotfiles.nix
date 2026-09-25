import Quickshell
import QtQuick

PanelWindow {
  id: root

  required property var runtimeConfig
  required property var backend
  required property var outputScreen
  property string osdType: "volume"
  property int displayedLevel: 0

  screen: outputScreen
  anchors.bottom: true
  margins.bottom: 72
  implicitWidth: 280
  implicitHeight: 64
  exclusiveZone: 0
  color: "transparent"
  visible: false

  Connections {
    target: root.backend

    function onOsdRequested(type, value) {
      root.osdType = type
      if (type === "volume")
        root.displayedLevel = Math.max(0, Math.min(100, Number(value) || 0))
      root.visible = true
      hideTimer.restart()
    }
  }

  Timer {
    id: hideTimer
    interval: 1500
    repeat: false
    onTriggered: root.visible = false
  }

  Rectangle {
    anchors.fill: parent
    radius: 12
    color: root.runtimeConfig.base00
    border.color: root.runtimeConfig.base02
    border.width: 1

    Row {
      anchors.centerIn: parent
      spacing: 12

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.osdType === "microphone"
          ? (root.backend.microphoneMuted ? "󰍭" : "󰍬")
          : (root.backend.volumeMuted ? "󰝟" : "󰕾")
        color: root.osdType === "microphone" && root.backend.microphoneMuted
          ? root.runtimeConfig.base08 : root.runtimeConfig.base05
        font.pixelSize: 22
      }

      Row {
        visible: root.osdType === "volume"
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 150
          height: 8
          radius: 4
          color: root.runtimeConfig.base02
          clip: true

          Rectangle {
            width: parent.width * root.displayedLevel / 100
            height: parent.height
            radius: 4
            color: root.runtimeConfig.base0D
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 42
          text: root.displayedLevel + "%"
          color: root.runtimeConfig.base05
          font.pixelSize: 14
        }
      }

      Text {
        visible: root.osdType === "microphone"
        anchors.verticalCenter: parent.verticalCenter
        text: root.backend.microphoneMuted ? "Muted" : "Unmuted"
        color: root.backend.microphoneMuted
          ? root.runtimeConfig.base08 : root.runtimeConfig.base05
        font.pixelSize: 14
      }
    }
  }
}
