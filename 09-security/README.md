# 09 — 安全加固 / Security Hardening

> [!info] 本章目标
> 学完这一章，你将能够：用最小权限原则管理系统、加固 SSH 防止暴力破解、用 fail2ban 封禁攻击者、用 auditd 和 lynis 做安全审计、配置内核安全参数。
>
> **预计时间**：2 小时

---

## 9.1 安全思维

> [!important] 三条核心原则
> 1. **最小权限 (Least Privilege)**：每个用户/程序只有做自己工作所需的最小权限
> 2. **纵深防御 (Defense in Depth)**：不依赖单一防线——防火墙 + 密钥 + 审计 + 监控
> 3. **安全是过程，不是状态**：攻击方法一直在进化，你的安全措施也要持续更新

---

## 9.2 保持系统更新

大多数安全事件利用的是已知的、已经有补丁的漏洞。不更新 = 敞开门。

```bash
# Ubuntu/Debian
$ sudo apt update && sudo apt upgrade -y

# 安全更新（Ubuntu 自动安全更新）
$ sudo apt install unattended-upgrades
$ sudo dpkg-reconfigure unattended-upgrades

# 查看有没有没打的安全更新
$ sudo apt list --upgradable | grep security

# Fedora/RHEL
$ sudo dnf update --security
```

---

## 9.3 SSH 加固：避免暴力破解

```bash
$ sudo nano /etc/ssh/sshd_config
```

```text
# 关掉 root 直接登录（用 sudo 提权）
PermitRootLogin no

# 只用密钥，不要密码登录
PasswordAuthentication no

# 限制尝试次数和速率
MaxAuthTries 3
MaxSessions 2

# 如果不需要，关掉 X11 转发和 TCP 转发
X11Forwarding no
AllowTcpForwarding no
```

```bash
# 改完先检查语法（非常重要！）
$ sudo sshd -t

# 然后重启
$ sudo systemctl reload sshd
```

> [!danger] 改 SSH 之前：保留一个活的连接窗口
> 另开一个终端登进去保持活跃，如果配置改错了导致新连不上，用这个窗口修复。

### 查看登录失败记录

```bash
$ sudo journalctl -u sshd | grep "Failed password" | tail -20
$ sudo lastb | head -20                # 失败的登录尝试
```

---

## 9.4 fail2ban：自动封禁攻击者

`fail2ban` 监控日志，如果有人反复尝试失败登录，自动在防火墙里封掉他的 IP。

```bash
$ sudo apt install fail2ban
$ sudo systemctl enable --now fail2ban
```

默认配置就保护 SSH（3 分钟内失败 6 次 → 封 10 分钟）。

```bash
# 看看有没有人已被封
$ sudo fail2ban-client status sshd
```
输出：
```text
Status for the jail: sshd
|- Filter
|  |- Currently failed: 1
|  |- Total failed:     245
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 3
   |- Total banned:     47
   `- Banned IP list:   23.45.67.89 101.202.33.44 87.65.43.21
```

### 自定义配置（不要改默认文件）

```bash
$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
$ sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
maxretry = 3
findtime = 10m
bantime = 1h

# 白名单：办公室 IP 永不封
ignoreip = 127.0.0.1/8 10.0.0.0/8 192.168.1.0/24
```

```bash
$ sudo systemctl restart fail2ban
```

### 自己解封一个 IP

```bash
$ sudo fail2ban-client set sshd unbanip 23.45.67.89
```

---

## 9.5 文件权限审计

### 找出危险的 SUID/GUID 程序

```bash
# SUID 程序（以 root 身份运行）
$ sudo find / -perm -4000 -type f 2>/dev/null

# SGID 程序（以 root 组身份运行）
$ sudo find / -perm -2000 -type f 2>/dev/null

# 全世界可写的文件（任何人能改）
$ sudo find / -perm -o+w -type f 2>/dev/null | grep -v /proc | grep -v /sys
```

### 检查关键文件的权限

```bash
$ ls -l /etc/passwd /etc/shadow /etc/group /etc/sudoers
```

| 文件 | 应该是 |
|:---|:---|
| `/etc/passwd` | `-rw-r--r--` (644) |
| `/etc/shadow` | `-rw-r-----` (640) |
| `/etc/sudoers` | `-r--r-----` (440) |

---

## 9.6 安全审计：lynis

```bash
$ sudo apt install lynis
$ sudo lynis audit system
```

lynis 会扫描你的系统，给出从 A（硬）到 E（软）的安全评分，告诉你哪些地方该加固。

输出最后会有一个 `/var/log/lynis-report.dat` 报告路径，里面的 `suggestion[]` 条目值得看一下。

---

## 9.7 AppArmor / SELinux

它们是**强制访问控制 (MAC)**系统，在"谁可以读写什么文件"的基础上又加了一道墙：即使你是 root，违反 AppArmor/SELinux 策略的操作也会被阻止。

```bash
# Ubuntu 默认用 AppArmor
$ sudo aa-status                   # 看看启用了哪些 profile
$ sudo aa-enforce /etc/apparmor.d/* # 给一个程序加 profile

# RHEL/CentOS/Fedora 默认用 SELinux
$ getenforce                       # 看状态
$ setenforce 1                     # 临时启用（0 关闭）
$ sudo cat /var/log/audit/audit.log | grep AVC   # 看 SELinux 拦截记录
```

> [!tip] 大部分应用不需要手动配置
> AppArmor/SELinux 通常会随系统包自动带有合理策略。遇到权限被拒绝时，先看日志看是不是它们拦的，不要上来就关掉。

---

## 9.8 内核安全参数（sysctl hardening）

```bash
$ sudo nano /etc/sysctl.d/99-hardening.conf
```

```ini
# 防 IP 欺骗
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1

# 不转发 ICMP 重定向（你的机器不是路由器就别重定向）
net.ipv4.conf.all.accept_redirects=0
net.ipv6.conf.all.accept_redirects=0

# 防 SYN 洪水攻击
net.ipv4.tcp_syncookies=1

# 禁 IP 转发（不是路由器就关了）
net.ipv4.ip_forward=0

# 核心转储限制（包含敏感内存数据）
kernel.core_uses_pid=1
fs.suid_dumpable=0

# dmesg 只允许 root 看（普通用户可能看到敏感信息）
kernel.dmesg_restrict=1
```

```bash
$ sudo sysctl -p /etc/sysctl.d/99-hardening.conf   # 立即生效
```

---

## 9.9 实战：安全基线检查脚本

```bash
#!/bin/bash
# quick-security-check.sh —— 快速安全基线检查

echo "=== SSH Root Login ==="
grep "^PermitRootLogin" /etc/ssh/sshd_config || echo "NOT SET (default may allow root)"

echo "=== SSH Password Auth ==="
grep "^PasswordAuthentication" /etc/ssh/sshd_config || echo "NOT SET"

echo "=== Unattended Upgrades ==="
systemctl is-active unattended-upgrades 2>/dev/null || echo "NOT INSTALLED"

echo "=== fail2ban ==="
systemctl is-active fail2ban 2>/dev/null || echo "NOT INSTALLED"

echo "=== Listening Ports ==="
ss -tlnp | awk '{print $4}' | grep -v "127.0.0.1" | grep -v "Local"

echo "=== World-Writable Files ==="
find /etc -perm -o+w -type f 2>/dev/null | head -5

echo "=== Users with UID 0 ==="
awk -F: '$3 == 0 {print $1}' /etc/passwd

echo "=== Failed Logins (last 10) ==="
sudo lastb 2>/dev/null | head -10
```

```bash
$ chmod +x quick-security-check.sh
$ sudo ./quick-security-check.sh
```

---

## 🧪 本章综合练习

1. 检查 SSH 配置：关 root 登录、开密钥认证
2. 安装 fail2ban，观察被禁的 IP 列表
3. 用 `find` 找出系统上所有 SUID 程序
4. 用 lynis 跑一遍扫描，看看评分和建议
5. 写好并运行安全基线检查脚本

---

## 📋 本章命令速查

| 命令 / 文件 | 作用 |
|:---|:---|
| `apt update && apt upgrade` | 系统更新 |
| `unattended-upgrades` | 自动安全更新 |
| `/etc/ssh/sshd_config` | SSH 配置 |
| `ssh -t` 检查 | 语法检查 |
| `fail2ban-client status sshd` | 封禁状态 |
| `lynis audit system` | 安全扫描 |
| `find / -perm -4000` | 找 SUID 程序 |
| `aa-status` | AppArmor 状态 |
| `getenforce` | SELinux 状态 |
| `sysctl -p` | 加载内核参数 |
| `/etc/sysctl.d/` | 内核参数目录 |
| `lastb` | 登录失败记录 |

---

> [!info] 继续学习
> - 速查表：[[09-security/cheatsheet|Chapter 09 Cheatsheet]]
> - 上一章：[[08-networking/README|网络基础与服务]]
> - 下一章：[[10-kernel-performance/README|内核与性能调优]]
