# 02 — File System 速查表 / Cheatsheet

## 权限 Permissions
| 命令 | 说明 |
|------|------|
| `chmod 755 file` | rwxr-xr-x |
| `chmod 644 file` | rw-r--r-- |
| `chmod +x file` | 加执行位 / add execute |
| `chown user:group file` | 改所有者 / change owner |
| `ls -l` | 查看权限 / view permissions |

## 文件类型 File Types (`ls -l` 首字符)
| 字符 | 类型 |
|------|------|
| `-` | 普通文件 / regular |
| `d` | 目录 / directory |
| `l` | 符号链接 / symlink |
| `b` | 块设备 / block device |

## 链接 Links
| 命令 | 说明 |
|------|------|
| `ln -s target link` | 创建符号链接 / create symlink |
| `ln target link` | 创建硬链接 / create hard link |
| `readlink path` | 读取链接目标 / read link target |
| `ls -li` | 显示 inode 号 / show inodes |

## 查找 Find
| 命令 | 说明 |
|------|------|
| `find /p -name "*.txt"` | 按名搜索 / by name |
| `find /p -type d` | 只找目录 / directories only |
| `find /p -size +100M` | 按大小 / by size |
| `find /p -mtime -7` | 7天内修改 / modified within 7d |
| `find /p -exec cmd {} \;` | 对结果执行命令 / exec on results |

## 磁盘 Disk
| 命令 | 说明 |
|------|------|
| `df -h` | 磁盘使用 / disk usage |
| `du -sh dir/` | 目录大小 / dir size |
| `lsblk` | 块设备列表 / list block devices |
| `mount / umount` | 挂载/卸载 |

## 文件信息 File Info
| 命令 | 说明 |
|------|------|
| `stat file` | 文件详细信息 / detailed info |
| `file file` | 文件类型检测 / file type detection |
| `wc -l file` | 行数 / line count |
| `tree dir/` | 目录树 / directory tree |
