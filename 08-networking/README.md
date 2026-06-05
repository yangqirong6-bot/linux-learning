# 08 — 网络基础与服务 / Networking Basics

> [!info] 本章目标
> 学完这一章，你将能够：理解 TCP/IP 模型、用 `ip` 和 `ss` 查看网络配置、排查 DNS 问题、用 `curl` 调试 HTTP、配置安全的 SSH、用防火墙保护服务器、搭建 nginx 静态站点。
>
> **预计时间**：2-2.5 小时

---

## 8.1 TCP/IP 四层模型速览

想理解网络，把这个表记住就够了：

| 层 | 干什么的 | 例子 |
|:---|:---|:---|
| 应用层 | 程序之间的通信格式 | HTTP, DNS, SSH, SMTP |
| 传输层 | 把数据可靠地送到目标程序 | TCP (可靠), UDP (快速) |
| 网际层 | 把数据包从 A 机器送到 B 机器 | IP, ICMP (ping 走这层) |
| 网络接口层 | 物理传输：网线、WiFi、光纤 | Ethernet, Wi-Fi |

数据是怎么传的？从应用层往下逐层封装（加了 TCP 头 → 加了 IP 头 → 加了 Ethernet 帧头），到目标机器再逐层解开。

```bash
# 发送一个 HTTP 请求时，数据包经过的封装：
# [你的HTTP数据] → [TCP头|你的数据] → [IP头|TCP头|你的数据] → [Ethernet帧头|IP头|TCP头|你的数据]
```

---

## 8.2 看网络配置：`ip` 和 `ss`

> [!note] 弃用警告
> `ifconfig` 和 `netstat` 已经被 `ip` 和 `ss` 取代。老教程还在用它们，学新命令。

### `ip` — 网络接口、路由、地址

```bash
# 看所有网卡和 IP
$ ip addr show
```
输出：
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 ...
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
```

- `lo` = 回环接口（`127.0.0.1`，自己连自己）
- `eth0` = 第一块网卡（物理或虚拟）
- `192.168.1.100/24` = IP + 子网掩码（`/24` 就是 255.255.255.0）

```bash
$ ip route show                  # 路由表（数据从哪出去）
$ ip link show                   # 网卡状态
$ ip neighbor show               # ARP 表（IP → MAC 地址映射）
```

### `ss` — 看谁在监听、谁连了进来

```bash
$ ss -tlnp         # TCP 监听 (-t TCP, -l 监听, -n 不解析域名, -p 显示进程)
```
输出：
```text
State     Recv-Q    Send-Q    Local Address:Port    Peer Address:Port    Process
LISTEN    0         128       0.0.0.0:22           0.0.0.0:*            sshd
LISTEN    0         128       127.0.0.1:5432       0.0.0.0:*            postgres
LISTEN    0         128       0.0.0.0:80           0.0.0.0:*            nginx
```

| 列 | 含义 |
|:---|:---|
| `0.0.0.0:80` | 监听所有网卡的 80 端口（所有 IP 都能连） |
| `127.0.0.1:5432` | 只监听本机 5432 端口（只能本机连） |

```bash
$ ss -tanp                        # 所有 TCP 连接（包括已建立的）
$ ss -s                           # 连接统计
$ ss -tlnp src :80                # 只看 80 端口
```

### 🧪 即时练习

```bash
$ ip addr show
$ ip route show
$ ss -tlnp
$ ss -s
```

---

## 8.3 DNS 解析

DNS 把域名翻译成 IP。比如 `github.com` → `20.205.243.166`。

### 系统怎么找 IP？

1. 先查 `/etc/hosts`（本地覆盖）
2. 再查 `/etc/resolv.conf` 指定的 DNS 服务器（通常是你家路由器或 `8.8.8.8`）

```bash
$ cat /etc/resolv.conf
```
输出：
```text
nameserver 8.8.8.8
nameserver 1.1.1.1
```

### `dig` — DNS 查询利器

```bash
$ dig github.com
```
输出（关键行）：
```text
;; ANSWER SECTION:
github.com.     60    IN    A    20.205.243.166
```

```bash
$ dig github.com +short            # 只要 IP
$ dig -x 8.8.8.8 +short            # 反向查询（IP → 域名）
$ dig google.com MX                # 查邮件服务器
$ dig @1.1.1.1 github.com          # 指定 DNS 服务器
```

### `host` — 更简单的查询

```bash
$ host github.com
```
输出：
```text
github.com has address 20.205.243.166
```

### 🧪 即时练习

```bash
$ cat /etc/hosts
$ cat /etc/resolv.conf
$ dig github.com +short
$ host google.com
```

---

## 8.4 `curl` — 命令行里的 HTTP 客户端

```bash
# 最基础的 GET 请求
$ curl https://api.github.com

# 只显示响应头
$ curl -I https://github.com

# 显示请求的详细信息（请求头+响应头+时间）
$ curl -v https://github.com

# POST 请求（发 JSON）
$ curl -X POST https://httpbin.org/post \
  -H "Content-Type: application/json" \
  -d '{"name":"alice"}'

# 查看完整的请求/响应过程（包括 SSL 握手）
$ curl -w "\nHTTP %{http_code} | time_total: %{time_total}s\n" https://github.com

# 一次发多个请求（用 {} 展开）
$ curl -O "https://example.com/file[1-5].zip"
```

### curl 故障排除

```bash
# 连接超时（只等 3 秒）
$ curl --connect-timeout 3 https://down-server.com

# 跟随重定向
$ curl -L https://bit.ly/short-link

# 下载文件
$ curl -O https://example.com/file.zip        # 保持文件名
$ curl -o myname.zip https://example.com/file.zip  # 改名
```

---

## 8.5 SSH 安全配置

### 生成密钥对

```bash
$ ssh-keygen -t ed25519 -C "your@email.com"
```

这会在 `~/.ssh/` 下生成 `id_ed25519`（私钥）和 `id_ed25519.pub`（公钥）。公钥可以放心给别人，私钥必须保密。

```bash
# 把公钥复制到服务器（让别人可以免密码登你的机器）
$ ssh-copy-id user@remote-server

# 然后就可以直接登录了
$ ssh user@remote-server
```

### 高级 SSH

```bash
# 本地端口转发：把本机 8080 转发到远程 80
$ ssh -L 8080:localhost:80 user@remote

# 远程端口转发：把远程 9090 转发到本机 3000
$ ssh -R 9090:localhost:3000 user@remote

# 跳板代理：通过 jump-host 跳到 target-host
$ ssh -J user@jump-host user@target-host

# SSH 配置文件 (~/.ssh/config)
$ cat ~/.ssh/config
```

```text
Host myserver
    HostName 192.168.1.100
    User alice
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_myserver
```

此后直接 `ssh myserver` 就行。

### SSH 安全加固要点

| 措施 | 配置位置 `/etc/ssh/sshd_config` |
|:---|:---|
| 禁 root 直接登录 | `PermitRootLogin no` |
| 只用密钥认证 | `PasswordAuthentication no` |
| 改默认端口（可选） | `Port 2222`（防扫描，但不能替代密钥） |
| 限特定用户 | `AllowUsers alice bob` |

```bash
$ sudo nano /etc/ssh/sshd_config
# 修改后重启
$ sudo systemctl restart sshd
```

> [!warning] 改 SSH 配置之前留一个正在连接的窗口
> 如果你改错了 SSH 配置造成无法登录，你至少还有一个活着的连接可以恢复。否则只有去机器跟前操作了。

---

## 8.6 防火墙：`ufw` 快速入门

Linux 底层防火墙上 `nftables`（以前是 `iptables`）。但日常用 `ufw` 就够了——它是面向普通用户的简洁前端。

```bash
$ sudo ufw status
$ sudo ufw enable                     # 打开防火墙
$ sudo ufw default deny incoming      # 默认拒绝所有入站
$ sudo ufw default allow outgoing     # 默认允许所有出站

$ sudo ufw allow ssh                  # 允许 22 端口
$ sudo ufw allow 80/tcp               # 允许 HTTP
$ sudo ufw allow 443/tcp              # 允许 HTTPS
$ sudo ufw allow from 192.168.1.0/24  # 允许整个子网

$ sudo ufw delete allow 80/tcp        # 删除一条规则
$ sudo ufw status numbered            # 带编号查看
$ sudo ufw delete 3                   # 按编号删
```

```bash
# 推荐配置（Web 服务器）
$ sudo ufw allow ssh
$ sudo ufw allow 'Nginx Full'         # 80 + 443
$ sudo ufw enable
$ sudo ufw status verbose
```

---

## 8.7 排错工具四件套

```bash
$ ping -c 4 google.com                # 能通吗？
$ traceroute google.com               # 经过哪些路由器？（包走的路径）
$ mtr google.com                      # ping + traceroute 合体，实时更新
$ nc -zv google.com 443               # 这个端口开着吗？（-z 不传数据, -v 多说点）
```

```bash
$ traceroute google.com
```
输出：
```text
 1  _gateway (192.168.1.1)  1.234ms
 2  10.0.0.1  5.678ms
 3  172.16.0.1  10.123ms
 4  * * *                          ← 中间某个路由器不回包（常见的，不一定断了）
 5  8.8.8.8  20.456ms
```

> [!tip] `* * *` 不一定是故障
> 有些路由器配置了不响应 traceroute 探测包，只要最终能到达目标就没问题。

---

## 8.8 实战：nginx 静态站点

```bash
$ sudo apt install nginx
$ sudo systemctl enable --now nginx
```

此时浏览器打开 `http://你的IP`，应该看到 nginx 欢迎页。

### 部署你的页面

```bash
# 创建站点目录
$ sudo mkdir -p /var/www/mysite

# 写一个简单页面
$ echo '<h1>Hello World!</h1>' | sudo tee /var/www/mysite/index.html

# 创建 nginx 配置
$ sudo nano /etc/nginx/sites-available/mysite
```

```nginx
server {
    listen 80;
    server_name mysite.com;

    root /var/www/mysite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
$ sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
$ sudo nginx -t                      # 检查配置语法
$ sudo systemctl reload nginx
```

---

## 🧪 本章综合练习

1. 用 `ip addr show` 和 `ss -tlnp` 查看本机网络配置和服务
2. 用 `dig` 分别查询 `github.com` 和 `baidu.com` 的 A 记录
3. 用 `curl -v` 发一个 GET 请求，观察请求头和响应头
4. 生成一个 ed25519 密钥对并配置 `~/.ssh/config`
5. 安装 nginx，部署你的静态站点，配置防火墙只开 22 和 80 端口

---

## 📋 本章命令速查

| 命令 | 作用 |
|:---|:---|
| `ip addr show` | 看 IP 地址 |
| `ip route show` | 看路由表 |
| `ss -tlnp` | 看监听端口 |
| `ss -tanp` | 看所有连接 |
| `dig <domain>` | DNS 查询 |
| `host <domain>` | 快速 DNS |
| `curl -v <url>` | 调试 HTTP |
| `curl -I <url>` | 只看响应头 |
| `ssh-keygen -t ed25519` | 生成密钥 |
| `ssh-copy-id user@host` | 复制公钥 |
| `ssh -L/-R` | 端口转发 |
| `ssh -J` | 跳板代理 |
| `ufw allow/deny` | 防火墙 |
| `ufw status` | 防火墙状态 |
| `ping` / `traceroute` / `mtr` | 连通性测试 |
| `nc -zv host port` | 端口检测 |
| `nginx -t` | 检查 nginx 配置 |

---

> [!info] 继续学习
> - 速查表：[[08-networking/cheatsheet|Chapter 08 Cheatsheet]]
> - 上一章：[[07-systemd-services/README|Systemd 与服务管理]]
> - 下一章：[[09-security/README|安全加固]]
