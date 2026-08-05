{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.valentinus.desktop.quickshell;
  c = config.lib.stylix.colors;

  iconDataDirs = lib.concatStringsSep ":" [
    "${pkgs.papirus-icon-theme}/share"
    "${pkgs.hicolor-icon-theme}/share"
    "${pkgs.kdePackages.breeze-icons}/share"
  ];

  quickshellForSway = pkgs.writeShellApplication {
    name = "quickshell-for-sway";
    text = ''
      if [[ -z "''${SWAYSOCK:-}" ]]; then
        echo "quickshell-for-sway: SWAYSOCK is not set" >&2
        exit 1
      fi

      export I3SOCK="$SWAYSOCK"
      export XDG_DATA_DIRS="${iconDataDirs}:''${XDG_DATA_DIRS:-/run/current-system/sw/share:${config.home.profileDirectory}/share}"
      exec ${lib.getExe config.programs.quickshell.package} "$@"
    '';
  };

  networkStatus = pkgs.writeShellApplication {
    name = "network-status";
    runtimeInputs = [
      pkgs.gawk
      pkgs.gnused
      pkgs.iwd
    ];
    text = builtins.readFile ./qshell/scripts/network-status.sh;
  };

  gracefulSystemAction = pkgs.writeShellApplication {
    name = "graceful-system-action";
    runtimeInputs = [ pkgs.systemd ];
    text = builtins.readFile ./qshell/scripts/graceful-system-action.sh;
  };

  runtimeConfig = pkgs.replaceVars ./qshell/RuntimeConfig.qml {
    iwdEnabled = lib.boolToString cfg.capabilities.iwd.enable;
    backlightEnabled = lib.boolToString cfg.capabilities.backlight.enable;
    batteryEnabled = lib.boolToString cfg.capabilities.battery.enable;
    batteryDevice = cfg.capabilities.battery.device;
    notificationTimeoutMs = toString cfg.notificationTimeoutMs;

    base00 = c.base00;
    base02 = c.base02;
    base05 = c.base05;
    base08 = c.base08;
    base0A = c.base0A;
    base0D = c.base0D;

    awk = lib.getExe pkgs.gawk;
    brightnessctl = lib.getExe pkgs.brightnessctl;
    cal = lib.getExe' pkgs.util-linux "cal";
    cat = lib.getExe' pkgs.coreutils "cat";
    env = lib.getExe' pkgs.coreutils "env";
    free = lib.getExe' pkgs.procps "free";
    gracefulSystemAction = lib.getExe gracefulSystemAction;
    iwctl = lib.getExe' pkgs.iwd "iwctl";
    networkStatus = lib.getExe networkStatus;
    pavucontrol = lib.getExe pkgs.pavucontrol;
    shell = lib.getExe pkgs.bash;
    swaymsg = lib.getExe' pkgs.sway "swaymsg";
    systemdRun = lib.getExe' pkgs.systemd "systemd-run";
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  };

  qmlFiles = [
    "Bar.qml"
    "Notifications.qml"
    "PopupCoordinator.qml"
    "ShellBackend.qml"
    "Tray.qml"
    "TrayMenuPopup.qml"
    "shell.qml"
  ];

  qmlConfigFiles = lib.listToAttrs (
    map (name: {
      name = "quickshell/${name}";
      value.source = ./qshell/${name};
    }) qmlFiles
  );

in
{
  options.valentinus.desktop.quickshell = {
    enable = lib.mkEnableOption "the Quickshell desktop shell";

    capabilities = {
      iwd.enable = lib.mkEnableOption "iwd-backed Wi-Fi controls";
      backlight.enable = lib.mkEnableOption "backlight controls";
      battery = {
        enable = lib.mkEnableOption "battery status";
        device = lib.mkOption {
          type = lib.types.strMatching "[A-Za-z0-9._-]+";
          default = "BAT0";
          description = "Power-supply device whose capacity is shown in the bar.";
        };
      };
    };

    notificationTimeoutMs = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5000;
      description = "Time before the current notification expires, in milliseconds.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.papirus-icon-theme
      pkgs.hicolor-icon-theme
      pkgs.kdePackages.breeze-icons
    ];

    programs.quickshell = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };

    systemd.user.services.quickshell = {
      Unit.PartOf = [ "sway-session.target" ];
      Service = {
        ExecStart = lib.mkForce (lib.getExe quickshellForSway);
        RestartSec = 2;
      };
    };

    xdg.configFile = qmlConfigFiles // {
      "quickshell/RuntimeConfig.qml".source = runtimeConfig;
    };
  };
}
