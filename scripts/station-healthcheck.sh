#!/usr/bin/env bash
# scripts/station-healthcheck.sh
# Non-destructive station health inspection script for Monster (Macmini7,1)
# Designed to be piped via SSH: ssh monster 'bash -s' < scripts/station-healthcheck.sh

set -euo pipefail

UPTIME=$(uptime -p 2>/dev/null || uptime)
LOAD=$(cut -d ' ' -f 1-3 /proc/loadavg)

TEMP_CPU="N/A"
FAN_RPM="N/A"
if command -v sensors >/dev/null 2>&1; then
    TEMP_CPU=$(sensors 2>/dev/null | awk '/Package id 0:/ {print $4}' | tr -d '+' || echo "N/A")
    FAN_RPM=$(sensors 2>/dev/null | awk '/Exhaust/ {print $3" "$4}' || echo "N/A")
fi

MEM_TOTAL_MB=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED_MB=$(free -m | awk '/Mem:/ {print $3}')
MEM_AVAIL_MB=$(free -m | awk '/Mem:/ {print $7}')
MEM_PCT=$(( 100 * MEM_USED_MB / MEM_TOTAL_MB ))
SWAP_TOTAL_MB=$(free -m | awk '/Swap:/ {print $2}')
SWAP_USED_MB=$(free -m | awk '/Swap:/ {print $3}')
SWAP_PCT=0
if [ "$SWAP_TOTAL_MB" -gt 0 ]; then
    SWAP_PCT=$(( 100 * SWAP_USED_MB / SWAP_TOTAL_MB ))
fi

DISK_ROOT_LINE=$(df -h / | awk 'NR==2 {print $2, $3, $4, $5}')
DISK_ROOT_PCT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_BOOT_LINE=$(df -h /boot 2>/dev/null | awk 'NR==2 {print $2, $3, $4, $5}' || echo "N/A")

FAILED_SYS=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
FAILED_USER=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)

CONTAINER_TOTAL=$(podman ps -a -q 2>/dev/null | wc -l)
CONTAINER_RUNNING=$(podman ps -q 2>/dev/null | wc -l)
CONTAINER_UNHEALTHY=$(podman ps -a --filter health=unhealthy -q 2>/dev/null | wc -l)

JOURNAL_ERRORS=$(journalctl -p 3 -q --since "24 hours ago" --no-pager 2>/dev/null | wc -l || echo 0)

OVERALL="HEALTHY"
WARNINGS=()

if [ "$TEMP_CPU" != "N/A" ] && [ -n "$TEMP_CPU" ]; then
    TEMP_NUM=$(echo "$TEMP_CPU" | sed 's/°C//' | cut -d'.' -f1)
    if [ "$TEMP_NUM" -ge 85 ]; then
        OVERALL="CRITICAL"
        WARNINGS+=("CPU temperature critical: ${TEMP_CPU}")
    elif [ "$TEMP_NUM" -ge 75 ]; then
        [ "$OVERALL" = "HEALTHY" ] && OVERALL="WARNING"
        WARNINGS+=("CPU temperature elevated: ${TEMP_CPU}")
    fi
fi

if [ "$DISK_ROOT_PCT" -ge 90 ]; then
    OVERALL="CRITICAL"
    WARNINGS+=("Root partition disk usage critical: ${DISK_ROOT_PCT}%")
elif [ "$DISK_ROOT_PCT" -ge 80 ]; then
    [ "$OVERALL" = "HEALTHY" ] && OVERALL="WARNING"
    WARNINGS+=("Root partition disk usage high: ${DISK_ROOT_PCT}%")
fi

if [ "$MEM_PCT" -ge 90 ]; then
    [ "$OVERALL" = "HEALTHY" ] && OVERALL="WARNING"
    WARNINGS+=("Memory usage high: ${MEM_PCT}%")
fi

if [ "$FAILED_SYS" -gt 0 ] || [ "$FAILED_USER" -gt 0 ]; then
    [ "$OVERALL" = "HEALTHY" ] && OVERALL="WARNING"
    WARNINGS+=("Failed systemd services: system=${FAILED_SYS}, user=${FAILED_USER}")
fi

if [ "$CONTAINER_UNHEALTHY" -gt 0 ]; then
    [ "$OVERALL" = "HEALTHY" ] && OVERALL="WARNING"
    WARNINGS+=("Unhealthy podman containers: ${CONTAINER_UNHEALTHY}")
fi

cat <<EOF
======================================================================
STATION HEALTH SUMMARY: Monster (Macmini7,1)
Status: [${OVERALL}]
Timestamp: $(date -Iseconds)
Uptime: ${UPTIME} | Load: ${LOAD}
----------------------------------------------------------------------
[Thermal & Cooling]
- CPU Temp: ${TEMP_CPU}
- Fan:      ${FAN_RPM}

[Memory & Swap]
- RAM:      ${MEM_USED_MB}MB / ${MEM_TOTAL_MB}MB (${MEM_PCT}% used, ${MEM_AVAIL_MB}MB avail)
- Swap:     ${SWAP_USED_MB}MB / ${SWAP_TOTAL_MB}MB (${SWAP_PCT}% used)

[Storage]
- Root (/): Total/Used/Avail/Use% -> ${DISK_ROOT_LINE}
- Boot:     Total/Used/Avail/Use% -> ${DISK_BOOT_LINE}

[Services & Containers]
- Systemd Failed: System=${FAILED_SYS}, User=${FAILED_USER}
- Podman:         Running=${CONTAINER_RUNNING}, Total=${CONTAINER_TOTAL}, Unhealthy=${CONTAINER_UNHEALTHY}
- Journal Errors: ${JOURNAL_ERRORS} (priority err/crit in last 24h)
----------------------------------------------------------------------
EOF

if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "All core subsystems are operating within normal parameters."
else
    echo "Subsystem Alerts:"
    for w in "${WARNINGS[@]}"; do
        echo "  - [!] ${w}"
    done
fi
echo "======================================================================"
