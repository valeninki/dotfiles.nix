{
  bash,
  lib,
  pkgs,
  quickshell,
  qt6Packages,
  runCommand,
  shellcheck,
}:

let
  networkStatus = pkgs.writeShellApplication {
    name = "network-status";
    runtimeInputs = [
      pkgs.gawk
      pkgs.gnused
      pkgs.iwd
    ];
    text = builtins.readFile ./scripts/network-status.sh;
  };
  gracefulSystemAction = pkgs.writeShellApplication {
    name = "graceful-system-action";
    runtimeInputs = [ pkgs.systemd ];
    text = builtins.readFile ./scripts/graceful-system-action.sh;
  };

  # The standalone flake check has no Home Manager config. Use representative
  # capability and color values, but the same store-backed commands as the module.
  runtimeConfig = pkgs.replaceVars ./RuntimeConfig.qml {
    iwdEnabled = "true";
    backlightEnabled = "true";
    batteryEnabled = "true";
    batteryDevice = "BAT0";
    notificationTimeoutMs = "5000";

    base00 = "1d1f21";
    base02 = "373b41";
    base05 = "c5c8c6";
    base08 = "cc6666";
    base0A = "f0c674";
    base0D = "81a2be";

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
in
runCommand "quickshell-qml-check"
  {
    nativeBuildInputs = [
      bash
      qt6Packages.qtdeclarative
      shellcheck
    ];
  }
  ''
    cp -R ${./.} source
    chmod -R u+w source
    cp ${runtimeConfig} source/RuntimeConfig.qml
    chmod u+w source/RuntimeConfig.qml
    if grep -Eq '@[A-Za-z][A-Za-z0-9_]*@' source/RuntimeConfig.qml; then
      echo "RuntimeConfig.qml still contains unsubstituted variables" >&2
      exit 1
    fi

    # Quickshell qmltypes cause missing-type/uncreatable-type and signal
    # parameter warnings; modelData yields unqualified warnings. Keep exits fatal.
    if ! qmllint \
      -I ${quickshell}/lib/qt-6/qml \
      -I ${qt6Packages.qtdeclarative}/lib/qt-6/qml \
      source/*.qml > qmllint.log 2>&1; then
      cat qmllint.log >&2
      exit 1
    fi

    for script in \
      source/scripts/*.sh \
      source/tests/*.sh; do
      bash -n "$script"
      shellcheck -s bash "$script"
    done

    bash source/tests/network-status.sh
    bash source/tests/graceful-system-action.sh

    mkdir -p "$out"
    cp qmllint.log "$out/"
  ''
