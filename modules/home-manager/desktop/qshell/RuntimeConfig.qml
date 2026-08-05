import QtQuick

QtObject {
  readonly property bool iwdEnabled: "@iwdEnabled@" === "true"
  readonly property bool backlightEnabled: "@backlightEnabled@" === "true"
  readonly property bool batteryEnabled: "@batteryEnabled@" === "true"
  readonly property string batteryDevice: "@batteryDevice@"
  readonly property int notificationTimeoutMs: Number("@notificationTimeoutMs@")

  readonly property string base00: "#@base00@"
  readonly property string base02: "#@base02@"
  readonly property string base05: "#@base05@"
  readonly property string base08: "#@base08@"
  readonly property string base0A: "#@base0A@"
  readonly property string base0D: "#@base0D@"

  readonly property string awk: "@awk@"
  readonly property string brightnessctl: "@brightnessctl@"
  readonly property string cal: "@cal@"
  readonly property string cat: "@cat@"
  readonly property string env: "@env@"
  readonly property string free: "@free@"
  readonly property string gracefulSystemAction: "@gracefulSystemAction@"
  readonly property string iwctl: "@iwctl@"
  readonly property string networkStatus: "@networkStatus@"
  readonly property string pavucontrol: "@pavucontrol@"
  readonly property string shell: "@shell@"
  readonly property string swaymsg: "@swaymsg@"
  readonly property string systemdRun: "@systemdRun@"
  readonly property string wpctl: "@wpctl@"
}
