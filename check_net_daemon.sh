#!/bin/bash
# check_net_daemon.sh - 持續監控網路

set -u  # 未定義變數直接退出

CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/config.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi
source "$CONFIG_FILE"

# 確保 log 目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# Daemon 開始 log
{
    echo "==============================="
    echo "Daemon started at $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==============================="
} >> "$LOG_FILE"

# trap 使用 function，更穩定
cleanup() {
    {
        echo "==============================="
        echo "Daemon stopping at $(date '+%Y-%m-%d %H:%M:%S')"
        echo "==============================="
    } >> "$LOG_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM

# 主迴圈
while true; do
    {
        echo "----- $(date '+%Y-%m-%d %H:%M:%S') -----"
        if ping -c 3 "$PING_TARGET" &>/dev/null; then
            echo "Internet OK"
        else
            echo "Internet FAILED"
        fi
    } >> "$LOG_FILE"
    sleep "$CHECK_INTERVAL"
done

