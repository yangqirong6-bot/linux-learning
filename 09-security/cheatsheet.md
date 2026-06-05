# 09 — Security 速查表 / Cheatsheet

## 系统更新 / Updates
| 命令 | 说明 |
|:---|:---|
| `apt update && apt upgrade -y` | 更新系统 |
| `unattended-upgrades` | 自动安全更新 |
| `apt list --upgradable \| grep security` | 查看安全更新 |

## SSH 加固 / SSH Hardening
| 配置 | 推荐值 |
|:---|:---|
| `PermitRootLogin` | `no` |
| `PasswordAuthentication` | `no` |
| `MaxAuthTries` | 3 |
| `AllowUsers` | 只列必需用户 |

```bash
sudo sshd -t                      # 改完检查语法
sudo systemctl reload sshd        # 重载
sudo lastb | head -20             # 查看失败登录
```

## fail2ban
| 命令 | 说明 |
|:---|:---|
| `fail2ban-client status sshd` | 查看 SSH jail |
| `fail2ban-client set sshd unbanip <IP>` | 解封 IP |
| `/etc/fail2ban/jail.local` | 自定义配置 |

## 权限审计 / Permission Audit
```bash
find / -perm -4000 -type f       # 所有 SUID 程序
find / -perm -o+w -type f        # 全局可写文件
ls -l /etc/passwd /etc/shadow    # 关键文件权限检查
```

## 工具 / Tools
| 命令 | 说明 |
|:---|:---|
| `lynis audit system` | 安全扫描 |
| `aa-status` | AppArmor 状态 |
| `getenforce` | SELinux 状态 |
| `setenforce 1` | 启用 SELinux |
| `dmesg \| grep -i audit` | 安全审计日志 |

## 内核硬底 / Kernel Hardening
| 参数 | 推荐值 |
|:---|:---|
| `net.ipv4.conf.all.rp_filter` | 1 |
| `net.ipv4.conf.all.accept_redirects` | 0 |
| `net.ipv4.tcp_syncookies` | 1 |
| `net.ipv4.ip_forward` | 0（非路由器） |
| `kernel.dmesg_restrict` | 1 |

```bash
sudo sysctl -p /etc/sysctl.d/99-hardening.conf  # 生效
```

## 安全三原则 / Three Principles
1. **最小权限** — 每个人/程序只有必需权限
2. **纵深防御** — 多层防护，不依赖单一防线
3. **持续过程** — 安全不是一次性配置
