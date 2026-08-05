set -euo pipefail

iwctl_bin="${IWCTL_BIN:-iwctl}"

devices="$("$iwctl_bin" device list 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' || true)"
device="$(awk '$3 == "on" || $3 == "off" { print $1; exit }' <<<"$devices")"
powered="$(awk -v device="$device" '$1 == device { print $3; exit }' <<<"$devices")"

if [[ "$powered" == "on" ]]; then
  station="$("$iwctl_bin" station "$device" show 2>/dev/null || true)"
  ssid="$(
    awk '{
        gsub(/\x1B\[[0-9;]*m/, "")
      }
      /Connected network/ {
          line=$0
          sub(/^.*Connected network[[:space:]]+/, "", line)
          print line
          exit
        }' <<<"$station"
  )"
else
  ssid="Wi-Fi off"
fi

printf '%s\n%s\n%s\n' "${ssid:-Disconnected}" "${powered:-off}" "$device"
