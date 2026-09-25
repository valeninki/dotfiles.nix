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
  off-before-on:device:list)
    if [[ -f "$FIXTURE_DIR/device-off-before-on.txt" ]]; then
      cat "$FIXTURE_DIR/device-off-before-on.txt"
    else
      # Untracked fixtures are omitted from a Git-backed Nix flake source.
      cat "$FIXTURE_DIR/device-off.txt"
      awk 'NR > 1 { $1 = "wlan1"; $4 = "phy1"; print }' "$FIXTURE_DIR/device-on.txt"
    fi
    ;;
  ap-before-station:device:list)
    if [[ -f "$FIXTURE_DIR/device-ap-before-station.txt" ]]; then
      cat "$FIXTURE_DIR/device-ap-before-station.txt"
    else
      # Keep the derivation test equivalent before the fixtures are staged.
      awk 'NR == 1 { print; next } { $1 = "ap0"; $5 = "ap"; print }' "$FIXTURE_DIR/device-on.txt"
      awk 'NR > 1 { $1 = "wlan1"; $4 = "phy1"; print }' "$FIXTURE_DIR/device-on.txt"
    fi
    ;;
  none:device:list)
    cat "$FIXTURE_DIR/device-none.txt"
    ;;
  connected:station:wlan0 | off-before-on:station:wlan1 | ap-before-station:station:wlan1)
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
run_case off-before-on $'Home Wi-Fi\non\nwlan1'
run_case ap-before-station $'Home Wi-Fi\non\nwlan1'
run_case station-failure $'Disconnected\non\nwlan0'
run_case off $'Wi-Fi off\noff\nwlan0'
run_case none $'Wi-Fi off\noff'
