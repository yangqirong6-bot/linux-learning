# 08 — Networking 速查表 / Cheatsheet

## 网络配置 / Network Config
| 命令 | 说明 |
|:---|:---|
| `ip addr show` | 查看 IP 地址 |
| `ip route show` | 路由表 |
| `ip link show` | 网卡状态 |
| `ip neighbor` | ARP 表 |
| `ss -tlnp` | 监听端口 |
| `ss -tanp` | 所有连接 |
| `ss -s` | 连接统计 |

## DNS
| 命令 | 说明 |
|:---|:---|
| `dig domain.com` | DNS 查询 |
| `dig +short domain.com` | 只显示 IP |
| `dig -x 8.8.8.8` | 反向查询 |
| `dig @1.1.1.1 domain.com` | 指定 DNS 服务器 |
| `host domain.com` | 快速查询 |
| `/etc/hosts` | 本地 hosts |
| `/etc/resolv.conf` | DNS 服务器配置 |

## curl
| 命令 | 说明 |
|:---|:---|
| `curl url` | GET 请求 |
| `curl -I url` | 只看响应头 |
| `curl -v url` | 详细过程 |
| `curl -X POST -H "..." -d '...' url` | POST JSON |
| `curl -O url` | 下载文件 |
| `curl -L url` | 跟随重定向 |
| `curl --connect-timeout 3 url` | 超时设置 |

## SSH
| 命令 | 说明 |
|:---|:---|
| `ssh-keygen -t ed25519 -C "email"` | 生成密钥对 |
| `ssh-copy-id user@host` | 复制公钥 |
| `ssh user@host` | 登录 |
| `ssh -L 8080:localhost:80 user@host` | 本地端口转发 |
| `ssh -R 9090:localhost:3000 user@host` | 远程端口转发 |
| `ssh -J jump@host target@host` | 跳板代理 |

## 防火墙 / ufw
| 命令 | 说明 |
|:---|:---|
| `ufw enable` | 启用 |
| `ufw default deny incoming` | 默认拒绝入站 |
| `ufw allow ssh` | 允许 SSH |
| `ufw allow 80/tcp` | 允许 HTTP |
| `ufw status verbose` | 查看规则 |
| `ufw delete <rule>` | 删除规则 |

## 故障排除 / Troubleshooting
| 命令 | 说明 |
|:---|:---|
| `ping -c 4 host` | 连通测试 |
| `traceroute host` | 路由追踪 |
| `mtr host` | ping + traceroute 合体 |
| `nc -zv host port` | 端口检测 |

## nginx 快速配置
```nginx
server {
    listen 80;
    root /var/www/mysite;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
```
`nginx -t` 检查语法 → `systemctl reload nginx`
