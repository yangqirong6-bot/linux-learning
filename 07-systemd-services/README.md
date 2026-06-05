# 07 — Systemd 与服务管理 / Systemd & Services

> [!info] 本章目标
> 学完这一章，你将能够：管理服务的生命周期（启动/停止/启用）、用 `journalctl` 查日志、编写自己的 `.service` 文件、用 timer 替代 cron、理解 target 和系统启动流程。
>
> **预计时间**：1.5-2 小时

---

## 7.1 systemd 是什么？

systemd 是 Linux 的管家：它启动系统（最早启动，PID=1），然后帮你管理服务、日志、定时器、网络和挂载。

> [!note] systemd 的争议
> systemd 包揽了很多事——批评者说它不守 Unix 的"只做一件事"原则。但几乎所有主流发行版（Ubuntu, Debian, Fedora, CentOS, Arch）都用了 systemd。对用户来说，学会它是最实用的。

```bash
$ systemctl --version
$ ps -p 1 -o comm=
```

---

## 7.2 管理服务：`systemctl`

### 查看服务状态

```bash
$ systemctl status sshd
```
输出：
```text
● ssh.service - OpenSSH Daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled)
     Active: active (running) since Thu 2026-01-15 09:00:00 CST; 1h ago
   Main PID: 1002 (sshd)
      Tasks: 1 (limit: 2317)
     Memory: 6.3M
        CPU: 120ms
     CGroup: /system.slice/sshd.service
             └─1002 sshd: /usr/sbin/sshd -D
```

关键信息：`loaded`=`enabled` (开机自启), `active (running)` (正在运行)。

### 启停服务

```bash
$ sudo systemctl start nginx          # 启动
$ sudo systemctl stop nginx           # 停止
$ sudo systemctl restart nginx        # 重启
$ sudo systemctl reload nginx         # 重载配置（不中断连接）
$ sudo systemctl enable nginx         # 设为开机自启
$ sudo systemctl disable nginx        # 取消开机自启
$ sudo systemctl daemon-reload        # 重读所有 unit 文件（修改 .service 后执行）
```

```bash
# 看看所有运行中的服务
$ systemctl list-units --type=service --state=running

# 看看所有失败的服务
$ systemctl --failed

# 看看哪些服务开机自启
$ systemctl list-unit-files --type=service | grep enabled
```

---

## 7.3 unit 文件的位置

| 路径 | 用途 |
|:---|:---|
| `/usr/lib/systemd/system/` | 系统包安装的默认 unit（包管理器管） |
| `/etc/systemd/system/` | 你自己写的或者改过的 unit（优先于上面） |
| `~/.config/systemd/user/` | 用户自己的 unit（无需 root） |

> [!tip] `/etc/systemd/system/` 优先级高于 `/usr/lib/`
> 如果要覆盖系统的默认配置，在 `/etc/systemd/system/` 下创建一个同名的 unit 文件。systemd 会优先用这个。

---

## 7.4 编写自己的 .service 文件

### 最小示例

```bash
$ sudo nano /etc/systemd/system/myapp.service
```

```ini
[Unit]
Description=My Custom App
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp
Restart=on-failure
RestartSec=5
User=yang
Group=yang
WorkingDirectory=/home/yang/app
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
$ sudo systemctl daemon-reload          # 重读配置
$ sudo systemctl enable --now myapp     # 立即启动 + 开机自启
$ systemctl status myapp
```

### 关键字段解释

| 字段 | 含义 |
|:---|:---|
| `After=network.target` | 等网络就绪后再启动 |
| `Type=simple` | 大部分服务用这个（认为 ExecStart 启动的程序就是主进程） |
| `Restart=on-failure` | 主进程异常退出时自动重启 |
| `RestartSec=5` | 失败后等 5 秒再重启 |
| `StandardOutput=journal` | 输出到 systemd 日志 |
| `WantedBy=multi-user.target` | 在正常的多用户模式下启动（开机自启） |

### 一个更完整的例子：Python Web 应用

```ini
[Unit]
Description=My Flask App
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/myapp
Environment="FLASK_ENV=production"
Environment="PORT=5000"
ExecStart=/opt/myapp/venv/bin/python -m flask run --host=0.0.0.0 --port=5000
Restart=always
RestartSec=10
StandardOutput=append:/var/log/myapp/access.log
StandardError=append:/var/log/myapp/error.log

[Install]
WantedBy=multi-user.target
```

---

## 7.5 日志：`journalctl`

systemd 把所有服务的日志集中管起来，不需要去翻各个日志文件。

```bash
# 查看所有日志（从最新往前翻）
$ journalctl

# 只看某个服务
$ journalctl -u nginx

# 只看本次启动后的日志
$ journalctl -b

# 实时跟踪（类似 tail -f）
$ journalctl -f

# 只看最近 30 分钟
$ journalctl --since "30 min ago"

# 只看错误级别以上
$ journalctl -p err

# 只看内核消息
$ journalctl -k

# 组合使用
$ journalctl -u nginx --since "1 hour ago" -p warning
```

### journalctl 输出格式

```bash
$ journalctl -u nginx -n 10 --no-pager -o short-full
```

| 选项 | 格式效果 |
|:---|:---|
| `-o short` | 默认简洁格式 |
| `-o verbose` | 显示所有字段 |
| `-o json` | JSON 输出（方便用 jq 处理） |
| `--no-pager` | 不进入分页模式 |
| `-n N` | 只看最后 N 条 |

---

## 7.6 定时任务：`.timer` 替代 cron

传统上用 `cron` 做定时任务。systemd 提供了 `.timer`，优势是：和 service 集成、日志自动进 journal、支持随机延迟、不会因为重叠而产生竞态条件。

### 创建定时任务

**第一步**：创建 service（执行实际任务）

```bash
$ sudo nano /etc/systemd/system/cleanup.service
```

```ini
[Unit]
Description=Clean up temp files

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cleanup-temp.sh
```

**第二步**：创建 timer（控制何时执行）

```bash
$ sudo nano /etc/systemd/system/cleanup.timer
```

```ini
[Unit]
Description=Run cleanup every day at 3am

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now cleanup.timer
$ systemctl list-timers              # 看看有哪些定时器
```

### 时间表达式

```ini
OnCalendar=daily                    # 每天 00:00
OnCalendar=*-*-* 03:00:00           # 每天凌晨 3 点
OnCalendar=Mon *-*-* 09:00:00       # 每周一上午 9 点
OnBootSec=5min                      # 启动后 5 分钟
OnUnitActiveSec=1h                  # 上次 unit 激活后 1 小时
```

---

## 7.7 target：系统的运行级别

target 是一组 service 的集合，代表系统的一种状态。

```bash
# 当前在哪个 target？
$ systemctl get-default
```

输出：
```text
multi-user.target
```

```bash
# 切换 target
$ sudo systemctl isolate rescue.target    # 进入救援模式
$ sudo systemctl isolate graphical.target # 进入图形界面模式

# 设置默认 target
$ sudo systemctl set-default multi-user.target
```

| target | 相当于 | 说明 |
|:---|:---|:---|
| `multi-user.target` | runlevel 3 | 多用户模式（服务器默认） |
| `graphical.target` | runlevel 5 | 带图形界面（桌面版默认） |
| `rescue.target` | rescue mode | 救援模式（最小环境，单用户） |
| `emergency.target` | emergency | 紧急模式（仅 root Shell） |
| `reboot.target` | reboot | 重启 |

### 查看依赖关系

```bash
# 哪个 target 会启动 sshd？
$ systemctl show -p WantedBy sshd | cut -d= -f2

# target 依赖了哪些 service？
$ systemctl list-dependencies multi-user.target
```

---

## 7.8 实战：把自己的脚本做成服务

### 场景：监控脚本

一个脚本每分钟检测 CPU 温度，超过阈值就报警。

```bash
$ sudo nano /usr/local/bin/temp-monitor.sh
```

```bash
#!/bin/bash
set -euo pipefail
THRESHOLD=80
TEMP=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//')
if [[ "${TEMP%.*}" -gt "$THRESHOLD" ]]; then
    echo "WARNING: CPU temp is ${TEMP}°C (threshold: ${THRESHOLD}°C)"
fi
```

```bash
$ sudo chmod +x /usr/local/bin/temp-monitor.sh
```

创建 service + timer：

```bash
$ sudo nano /etc/systemd/system/temp-monitor.service
```

```ini
[Unit]
Description=CPU Temperature Monitor

[Service]
Type=oneshot
ExecStart=/usr/local/bin/temp-monitor.sh
```

```bash
$ sudo nano /etc/systemd/system/temp-monitor.timer
```

```ini
[Unit]
Description=CPU Temperature Monitor Timer

[Timer]
OnUnitActiveSec=1min

[Install]
WantedBy=timers.target
```

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now temp-monitor.timer
$ systemctl list-timers | grep temp
```

---

## 🧪 本章综合练习

1. 查看 `sshd` 服务的状态，确认它在运行且开机自启
2. 创建一个 `.service` 文件，运行 `echo "Hello at $(date)" >> /tmp/my-service.log`（Type=oneshot）
3. 创建一个 `.timer` 文件，每分钟运行一次上面的 service
4. 用 `journalctl -u <service>` 查看运行日志
5. 用 `systemctl list-dependencies` 看看 `multi-user.target` 都依赖了哪些东西

---

## 📋 本章命令速查

| 命令 | 作用 |
|:---|:---|
| `systemctl status <svc>` | 服务状态 |
| `systemctl start/stop/restart` | 启停服务 |
| `systemctl enable/disable` | 开机自启 |
| `systemctl daemon-reload` | 重读 unit 文件 |
| `systemctl list-units --type=service` | 列出所有服务 |
| `systemctl --failed` | 失败的服务 |
| `journalctl -u <svc>` | 查看服务日志 |
| `journalctl -f` | 实时日志 |
| `journalctl --since "1h ago"` | 时间过滤 |
| `systemctl list-timers` | 定时器列表 |
| `systemctl get-default` | 当前 target |
| `systemctl isolate <target>` | 切换运行模式 |
| `systemctl list-dependencies` | 查看依赖 |

---

> [!info] 继续学习
> - 速查表：[[07-systemd-services/cheatsheet|Chapter 07 Cheatsheet]]
> - 上一章：[[06-shell-scripting/README|Shell 脚本编程]]
> - 下一章：[[08-networking/README|网络基础与服务]]
