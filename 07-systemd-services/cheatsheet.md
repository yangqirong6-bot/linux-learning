# 07 — Systemd / Services 速查表 / Cheatsheet

## 服务管理 / Service Management
| 命令 | 说明 |
|:---|:---|
| `systemctl status <svc>` | 服务状态 |
| `systemctl start <svc>` | 启动 |
| `systemctl stop <svc>` | 停止 |
| `systemctl restart <svc>` | 重启 |
| `systemctl reload <svc>` | 重载配置 |
| `systemctl enable <svc>` | 开机自启 |
| `systemctl disable <svc>` | 取消自启 |
| `systemctl enable --now <svc>` | 立即启动+自启 |
| `systemctl daemon-reload` | 重读 unit 文件 |
| `systemctl --failed` | 失败的服务 |

## 列表查看 / Listing
| 命令 | 说明 |
|:---|:---|
| `systemctl list-units --type=service` | 所有服务 |
| `systemctl list-unit-files --type=service` | 含已禁用的 |
| `systemctl list-timers` | 定时器 |
| `systemctl list-dependencies <target>` | 依赖关系 |

## 日志 / journalctl
| 命令 | 说明 |
|:---|:---|
| `journalctl -u <svc>` | 指定服务日志 |
| `journalctl -f` | 实时跟踪 |
| `journalctl -b` | 本次启动 |
| `journalctl --since "1h ago"` | 最近一小时 |
| `journalctl -p err` | 只看错误 |
| `journalctl -n 50 --no-pager` | 最后 50 条 |
| `journalctl -o json` | JSON 输出 |

## .service 模板 / Template
```ini
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp
Restart=on-failure
User=myuser
Group=mygroup

[Install]
WantedBy=multi-user.target
```

## .timer 模板 / Timer Template
```ini
[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

## Runlevels / Targets
| target | 含义 |
|:---|:---|
| `multi-user.target` | 多用户模式（服务器） |
| `graphical.target` | 图形界面（桌面） |
| `rescue.target` | 救援模式 |
| `emergency.target` | 紧急模式 |

| 命令 | 说明 |
|:---|:---|
| `systemctl get-default` | 当前 target |
| `systemctl set-default <t>` | 设置默认 |
| `systemctl isolate <t>` | 切换 target |
