import Quickshell
import Quickshell.I3
import Quickshell.Io
import QtQuick

Scope {
  id: root

  required property var runtimeConfig

  property string networkTooltipString: "Disconnected"
  property string networkDevice: ""
  property bool networkEnabled: false
  property string volumeLevel: "--"
  property bool volumeMuted: false
  property string volumeTooltipString: "--"
  property string brightnessLevel: "--"
  property string brightnessTooltipString: "--"
  property string ramUsage: "--"
  property string ramTooltipString: "--"
  property string batteryLevel: "--"
  property string calendarTooltipString: ""
  property bool calendarYearly: false
  property string focusedWindowTitle: ""
  property string focusedWindowAppId: ""
  property bool focusedWindowRefreshPending: false

  function formatCalendar(text, highlightToday) {
    const escaped = text.replace(/\s+$/, "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
    if (!highlightToday)
      return "<pre style=\"margin: 0\">" + escaped + "</pre>"

    const day = String(new Date().getDate())
    const dayPattern = new RegExp("(^|\\s)(" + day + ")(?=\\s|$)", "m")
    const highlighted = escaped.replace(
      dayPattern,
      "$1<font color=\"" + runtimeConfig.base0D + "\"><b>$2</b></font>"
    )

    return "<pre style=\"margin: 0\">" + highlighted + "</pre>"
  }

  function findFocusedWindow(node) {
    if (node.focused)
      return node

    const childLists = [ node.nodes || [], node.floating_nodes || [] ]
    for (let i = 0; i < childLists.length; i++) {
      for (let j = 0; j < childLists[i].length; j++) {
        const focused = findFocusedWindow(childLists[i][j])
        if (focused)
          return focused
      }
    }

    return null
  }

  function toggleCalendarView() {
    calendarYearly = !calendarYearly
    calendarTooltipProcess.running = false
    calendarTooltipProcess.running = true
  }

  function adjustVolume(step) {
    const current = Number(volumeLevel)
    if (!isNaN(current))
      volumeLevel = String(Math.max(0, Math.min(100, current + step)))

    if (step > 0)
      volumeUpProcess.startDetached()
    else
      volumeDownProcess.startDetached()
  }

  function toggleVolumeMute() {
    volumeMuted = !volumeMuted
    volumeMuteProcess.startDetached()
  }

  function adjustBrightness(step) {
    if (!runtimeConfig.backlightEnabled)
      return

    const current = Number(brightnessLevel)
    if (!isNaN(current))
      brightnessLevel = String(Math.max(1, Math.min(100, current + step)))

    if (step > 0)
      brightnessUpProcess.startDetached()
    else
      brightnessDownProcess.startDetached()
  }

  function toggleNetwork() {
    if (!runtimeConfig.iwdEnabled || !networkDevice)
      return

    networkEnabled = !networkEnabled
    networkTooltipString = networkEnabled ? "Connecting..." : "Wi-Fi off"
    networkToggleProcess.command = [
      runtimeConfig.iwctl,
      "device",
      networkDevice,
      "set-property",
      "Powered",
      networkEnabled ? "on" : "off"
    ]
    networkToggleProcess.startDetached()
    networkRefreshTimer.restart()
  }

  function refreshNetwork() {
    if (runtimeConfig.iwdEnabled && !networkDetailsProcess.running)
      networkDetailsProcess.running = true
  }

  function refreshVolumeTooltip() {
    if (!volumeTooltipProcess.running)
      volumeTooltipProcess.running = true
  }

  function refreshBrightness() {
    if (runtimeConfig.backlightEnabled && !brightnessProcess.running)
      brightnessProcess.running = true
  }

  function refreshRamTooltip() {
    if (!ramTooltipProcess.running)
      ramTooltipProcess.running = true
  }

  function refreshCalendar() {
    if (!calendarTooltipProcess.running)
      calendarTooltipProcess.running = true
  }

  function openVolumeControl() {
    volumeControlProcess.startDetached()
  }

  function poweroff() {
    shutdownProcess.startDetached()
  }

  function reboot() {
    restartProcess.startDetached()
  }

  Process {
    id: networkDetailsProcess
    command: [ root.runtimeConfig.networkStatus ]

    stdout: StdioCollector {
      onStreamFinished: {
        const details = text.trim().split("\n").map(line => line.trim())
        root.networkTooltipString = details[0] || "Disconnected"
        root.networkEnabled = details[1] === "on"
        root.networkDevice = details[2] || ""
      }
    }
  }

  Process {
    id: networkToggleProcess
  }

  Process {
    id: volumeProcess
    command: [ root.runtimeConfig.wpctl, "get-volume", "@DEFAULT_AUDIO_SINK@" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const output = text.trim()
        const value = Number(output.split(/\s+/)[1])
        root.volumeLevel = isNaN(value) ? "--" : String(Math.round(value * 100))
        root.volumeMuted = output.includes("[MUTED]")
      }
    }
  }

  Process {
    id: volumeTooltipProcess
    command: [ root.runtimeConfig.wpctl, "inspect", "@DEFAULT_AUDIO_SINK@" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
          if (!lines[i].includes("node.description"))
            continue

          const separator = lines[i].indexOf(" = ")
          if (separator >= 0) {
            root.volumeTooltipString = lines[i]
              .slice(separator + 3)
              .trim()
              .replace(/^\"|\"$/g, "") || "--"
            return
          }
        }
        root.volumeTooltipString = "--"
      }
    }
  }

  Process {
    id: volumeUpProcess
    command: [ root.runtimeConfig.wpctl, "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+" ]
  }

  Process {
    id: volumeDownProcess
    command: [ root.runtimeConfig.wpctl, "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-" ]
  }

  Process {
    id: volumeMuteProcess
    command: [ root.runtimeConfig.wpctl, "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle" ]
  }

  Process {
    id: brightnessProcess
    command: [ root.runtimeConfig.brightnessctl, "-m" ]

    stdout: StdioCollector {
      onStreamFinished: {
        const fields = text.trim().split(",")
        root.brightnessLevel = fields.length > 3 ? fields[3].replace("%", "") : "--"
        root.brightnessTooltipString = fields.length > 4
          ? fields[0] + ": " + fields[2] + " / " + fields[4] + " (" + fields[3] + ")"
          : "--"
      }
    }
  }

  Process {
    id: brightnessUpProcess
    command: [ root.runtimeConfig.brightnessctl, "set", "+5%" ]
  }

  Process {
    id: brightnessDownProcess
    command: [ root.runtimeConfig.brightnessctl, "set", "5%-" ]
  }

  Process {
    id: ramProcess
    command: [
      root.runtimeConfig.shell,
      "-c",
      root.runtimeConfig.free
        + " | "
        + root.runtimeConfig.awk
        + " '/Mem:/ {printf(\"%.0f\", $3/$2 * 100.0)}'"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.ramUsage = text.trim() || "--"
    }
  }

  Process {
    id: ramTooltipProcess
    command: [
      root.runtimeConfig.shell,
      "-c",
      root.runtimeConfig.free
        + " -h | "
        + root.runtimeConfig.awk
        + " '/^Mem:/ {print $3 \" / \" $2}'"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.ramTooltipString = text.trim() || "--"
    }
  }

  Process {
    id: batteryProcess
    command: [
      root.runtimeConfig.cat,
      "/sys/class/power_supply/" + root.runtimeConfig.batteryDevice + "/capacity"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.batteryLevel = text.trim() || "--"
    }
  }

  Process {
    id: calendarTooltipProcess
    command: [
      root.runtimeConfig.env,
      "LC_TIME=en_GB.UTF-8",
      root.runtimeConfig.cal,
      root.calendarYearly ? "-y" : "-m"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.calendarTooltipString = root.formatCalendar(text, !root.calendarYearly)
    }
  }

  Process {
    id: volumeControlProcess
    command: [ root.runtimeConfig.pavucontrol ]
  }

  Process {
    id: focusedWindowProcess
    command: [ root.runtimeConfig.swaymsg, "-t", "get_tree", "-r" ]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const focused = root.findFocusedWindow(JSON.parse(text))
          root.focusedWindowTitle = focused && focused.name ? focused.name : ""
          root.focusedWindowAppId = focused
            ? (focused.app_id || focused.window_properties?.class || "")
            : ""
        } catch (_) {
          root.focusedWindowTitle = ""
          root.focusedWindowAppId = ""
        }

        if (root.focusedWindowRefreshPending) {
          root.focusedWindowRefreshPending = false
          focusedWindowRefreshTimer.restart()
        }
      }
    }
  }

  Process {
    id: shutdownProcess
    command: [
      root.runtimeConfig.systemdRun,
      "--user",
      "--collect",
      "--quiet",
      "--unit=quickshell-poweroff",
      root.runtimeConfig.gracefulSystemAction,
      "poweroff"
    ]
  }

  Process {
    id: restartProcess
    command: [
      root.runtimeConfig.systemdRun,
      "--user",
      "--collect",
      "--quiet",
      "--unit=quickshell-reboot",
      root.runtimeConfig.gracefulSystemAction,
      "reboot"
    ]
  }

  I3IpcListener {
    id: focusedWindowListener
    onIpcEvent: function(event) {
      if (event.type === "window" || event.type === "workspace")
        focusedWindowRefreshTimer.restart()
    }
  }

  Timer {
    interval: 0
    running: true
    onTriggered: focusedWindowListener.subscriptions = [ "window", "workspace" ]
  }

  Timer {
    id: focusedWindowRefreshTimer
    interval: 50
    repeat: false
    onTriggered: {
      if (!focusedWindowProcess.running)
        focusedWindowProcess.running = true
      else
        root.focusedWindowRefreshPending = true
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refreshNetwork()
      if (!volumeProcess.running)
        volumeProcess.running = true
      root.refreshBrightness()
      if (!ramProcess.running)
        ramProcess.running = true
    }
  }

  Timer {
    id: networkRefreshTimer
    interval: 1000
    repeat: false
    onTriggered: root.refreshNetwork()
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refreshCalendar()
      if (root.runtimeConfig.batteryEnabled && !batteryProcess.running)
        batteryProcess.running = true
    }
  }

  Component.onCompleted: focusedWindowRefreshTimer.start()
}
