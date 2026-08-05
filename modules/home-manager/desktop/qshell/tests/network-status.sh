set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$root_dir/tests/fixtures"
stub_dir="$(mktemp -d)"
trap 'rm -rf "$stub_dir"' EXIT

printf '#!%s\n' "$BASH" >"$stub_dir/iwctl"
cat >>"$stub_dir/iwctl" <<'EOF'
set -euo pipefail

case "${TEST_MODE:-}:$1:$2" in
  connected:device:list | station-failure:device:list)
    cat "$FIXTURE_DIR/device-on.txt"
    ;;
  off:device:list)
    cat "$FIXTURE_DIR/device-off.txt"
    ;;
  none:device:list)
    cat "$FIXTURE_DIR/device-none.txt"
    ;;
  connected:station:wlan0)
    cat "$FIXTURE_DIR/station-connected.txt"
    ;;
  station-failure:station:wlan0)
    exit 1
    ;;
  *)
    exit 2
    ;;
esac
EOF
chmod +x "$stub_dir/iwctl"

run_case() {
  local mode="$1"
  local expected="$2"
  local actual

  actual="$(
    TEST_MODE="$mode" \
      FIXTURE_DIR="$fixture_dir" \
      IWCTL_BIN="$stub_dir/iwctl" \
      bash "$root_dir/scripts/network-status.sh"
  )"

  if [[ "$actual" != "$expected" ]]; then
    printf 'network-status case %s failed\nexpected:\n%s\nactual:\n%s\n' \
      "$mode" "$expected" "$actual" >&2
    return 1
  fi
}

run_case connected $'Home Wi-Fi\non\nwlan0'
run_case station-failure $'Disconnected\non\nwlan0'
run_case off $'Wi-Fi off\noff\nwlan0'
run_case none $'Wi-Fi off\noff'
