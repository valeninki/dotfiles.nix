{
  bash,
  quickshell,
  qt6Packages,
  runCommand,
  shellcheck,
}:

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
