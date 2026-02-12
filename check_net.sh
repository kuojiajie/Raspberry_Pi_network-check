#!/bin/bash
# check_net.sh - 單次網路檢查

set -u  # 未定義變數直接退出

CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/config.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi
source "$CONFIG_FILE"

# 確保 log 目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

{
    echo "==============================="
    echo "Single check at $(date '+%Y-%m-%d %H:%M:%S')"
    echo "-------------------------------"
    if ping -c 3 "$PING_TARGET" &>/dev/null; then
        echo "Internet OK"
    else
        echo "Internet FAILED"
    fi
    echo "==============================="
} >> "$LOG_FILE"

