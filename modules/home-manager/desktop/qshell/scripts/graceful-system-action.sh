set -euo pipefail

systemctl_bin="${SYSTEMCTL_BIN:-systemctl}"

case "${1:-}" in
  poweroff | reboot)
    action="$1"
    ;;
  *)
    echo "usage: graceful-system-action poweroff|reboot" >&2
    exit 2
    ;;
esac

"$systemctl_bin" --user stop graphical-session.target graphical-session-pre.target
exec "$systemctl_bin" "$action"
