# 04 — Users & Permissions 速查表 / Cheatsheet

## 用户与组 / Users & Groups
| 命令 | 说明 |
|:---|:---|
| `id` | 查看 UID/GID 和所属组 |
| `whoami` | 当前用户名 |
| `groups` | 所属组列表 |
| `useradd -m -s /bin/bash -G sudo <user>` | 创建用户 |
| `usermod -aG <group> <user>` | 追加附加组 |
| `usermod -L/-U <user>` | 锁定/解锁账户 |
| `userdel -r <user>` | 删除用户及家目录 |
| `passwd <user>` | 改密码 |
| `passwd -S <user>` | 查看密码状态 |
| `groupadd <group>` | 创建组 |

## su / sudo
| 命令 | 说明 |
|:---|:---|
| `su - <user>` | 切换用户（加载目标环境） |
| `sudo <cmd>` | 临时提权 |
| `sudo -l` | 查看自己的 sudo 权限 |
| `sudo -i` | 进入 root Shell |
| `visudo` | 安全编辑 /etc/sudoers |

## 权限 / Permissions
| 命令 | 说明 |
|:---|:---|
| `chmod 755 file` | rwxr-xr-x（脚本/目录） |
| `chmod 644 file` | rw-r--r--（普通文件） |
| `chmod 600 file` | rw-------（私密文件） |
| `chmod +x file` | 加执行位 |
| `chown user:group file` | 改所有者 |
| `chown -R user:group dir/` | 递归改所有者 |

## SUID / SGID / Sticky
| 命令 | 说明 |
|:---|:---|
| `chmod 4755 file` | SUID（以所有者身份运行） |
| `chmod 2755 dir` | SGID（新文件继承组） |
| `chmod 1777 dir` | Sticky（只能删自己的） |
| `chmod u+s file` | 符号法设 SUID |
| `chmod g+s dir` | 符号法设 SGID |
| `chmod +t dir` | 符号法设 Sticky |
| `find / -perm -4000` | 找出所有 SUID 程序 |

## ACL
| 命令 | 说明 |
|:---|:---|
| `getfacl file` | 查看 ACL |
| `setfacl -m u:alice:r file` | 给用户加权限 |
| `setfacl -m g:devs:rw file` | 给组加权限 |
| `setfacl -x u:alice file` | 删除用户 ACL |
| `setfacl -b file` | 清空所有 ACL |

## 关键文件 / Key Files
| 文件 | 内容 |
|:---|:---|
| `/etc/passwd` | 用户列表（7 字段） |
| `/etc/shadow` | 密码哈希 |
| `/etc/group` | 组列表 |
| `/etc/sudoers` | sudo 配置 |
