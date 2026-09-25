set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
stub_dir="$(mktemp -d)"
trap 'rm -rf "$stub_dir"' EXIT

printf '#!%s\n' "$BASH" >"$stub_dir/systemctl"
cat >>"$stub_dir/systemctl" <<'EOF'
set -euo pipefail

printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
if [[ "${FAIL_USER_STOP:-0}" == 1 && "${1:-}" == --user ]]; then
  exit 1
fi
EOF
chmod +x "$stub_dir/systemctl"

for action in poweroff reboot; do
  log="$stub_dir/$action.log"
  SYSTEMCTL_BIN="$stub_dir/systemctl" SYSTEMCTL_LOG="$log" \
    bash "$root_dir/scripts/graceful-system-action.sh" "$action"

  expected=$'--user stop graphical-session.target graphical-session-pre.target\n'"$action"
  actual="$(<"$log")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'graceful action %s used the wrong command order\nexpected:\n%s\nactual:\n%s\n' \
      "$action" "$expected" "$actual" >&2
    exit 1
  fi
  failure_log="$stub_dir/$action-stop-fails.log"
  warning_log="$stub_dir/$action-warning.log"
  FAIL_USER_STOP=1 SYSTEMCTL_BIN="$stub_dir/systemctl" SYSTEMCTL_LOG="$failure_log" \
    bash "$root_dir/scripts/graceful-system-action.sh" "$action" 2>"$warning_log"

  actual="$(<"$failure_log")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'graceful action %s did not run after the user stop failed\nexpected:\n%s\nactual:\n%s\n' \
      "$action" "$expected" "$actual" >&2
    exit 1
  fi
  if ! grep -q "warning: could not stop the graphical session; continuing with $action" "$warning_log"; then
    printf 'graceful action %s did not warn after the user stop failed\n' "$action" >&2
    exit 1
  fi
done

if SYSTEMCTL_BIN="$stub_dir/systemctl" SYSTEMCTL_LOG="$stub_dir/invalid.log" \
  bash "$root_dir/scripts/graceful-system-action.sh" suspend 2>/dev/null; then
  printf 'unsupported graceful action unexpectedly succeeded\n' >&2
  exit 1
fi

if [[ -e "$stub_dir/invalid.log" ]]; then
  printf 'unsupported graceful action invoked systemctl\n' >&2
  exit 1
fi
