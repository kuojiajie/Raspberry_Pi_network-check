# Network Check v0.3

## 介紹
這個專案提供了一個簡單的網路檢查工具，適合初學者學習如何從腳本到 systemd daemon 建立完整流程。主要功能包括：
- 單次檢查網路 (`check_net.sh`)
- 持續監控網路 (`check_net_daemon.sh`)
- 使用 systemd 管理 daemon 自動啟動、Crash 重啟、信號停止
- 網路狀態寫入 log (`net.log`)
> 注意:systemd unit 需要建立在 `/etc/systemd/system/` 才能被 systemctl 管理。

---

## 流程圖

```plaintext
┌─────────────────────┐
│ check_net.sh         │
│ (單次檢查 ping)      │
└─────────┬───────────┘
          │ chmod +x
          ▼
┌─────────────────────┐
│ check_net_daemon.sh  │
│ (while true + trap)  │
└─────────┬───────────┘
          │ ExecStart
          ▼
┌───────────────────────────────┐
│ /etc/systemd/system/check_net.service │
│ Type=simple                   │
│ Restart=always                │
│ After=network-online.target   │
└─────────┬─────────────────────┘
          │ systemctl enable/start
          ▼
┌─────────────────────┐
│ systemd 管理 daemon │
│ - 自動啟動          │
│ - Crash 重啟        │
│ - Signal 停止       │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ 網路狀態寫入 net.log │
└─────────────────────┘
```

---

## 測試說明

1. 單次檢查

```bash
chmod +x check_net.sh
./check_net.sh
cat net.log
```

2. 執行 daemon

```bash
chmod +x check_net_daemon.sh
```

建立 systemd unit

```bash
# 本專案的 daemon 需要由 systemd 管理，請在系統中建立以下檔案：
sudo vim /etc/systemd/system/check_net.service  
# systemd 只會讀取此目錄下的 unit 檔案，ExecStart 請使用「絕對路徑」
```

# unit 內容範例（依實際路徑修改）

```ini
[Unit]
Description=Check Internet Connectivity Daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/home/your_user/projects/network-check/check_net_daemon.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

systemd 操作指令

```bash
# 重新載入 systemd 目錄
sudo systemctl daemon-reload

# 啟用並啟動 daemon
sudo systemctl enable check_net.service
sudo systemctl start check_net.service

# 查看 daemon 狀態
sudo systemctl status check_net.service
```

3. 查看 log

```bash
tail -f ~/projects/network-check/net.log
```

4. 停止 daemon

```bash
sudo systemctl stop check_net.service
```

---

## 配置說明

- 使用 `config.sh` 設定：
  - `PING_TARGET`：ping 目標 IP 或 hostname
  - `CHECK_INTERVAL`：檢查間隔（秒）
  - `LOG_FILE`：log 路徑，可選系統 `/var/log/...` 或專案內 `./net.log`

- 建議流程：
  1. 先修改 `config.sh`，確定 log 路徑可寫
  2. 測試單次檢查，確認 ping 正常
  3. 再啟用 daemon 與 systemd unit

---

## 補充說明 / Tips

1. **權限與執行**
   - 腳本需加上執行權限：

     ```bash
     chmod +x check_net_daemon.sh
     ```
   - systemd daemon 會以 root 或執行者權限啟動，注意 log 檔案可寫

2. **網路啟動順序**
   - `After=network-online.target` 確保網路啟動完成再執行
   - Wi-Fi 連線不穩定時，`Restart=always` 可自動重啟

3. **單次 / daemon log 格式統一**

```
    ===============================
    <MODE> started at YYYY-MM-DD HH:MM:SS
    ===============================
    ----- YYYY-MM-DD HH:MM:SS -----
    Internet OK|FAILED
    ===============================
```

4. **log 管理**
   - `net.log` 會持續累積，如果長期運行建議定期清理或使用 logrotate
   - 可透過 `tail -f` 即時查看網路狀態

---
