# 02 — 文件系统与路径 / File System & Paths

---

## 2.1 Linux 目录结构 / The Linux Directory Tree

Linux 只有一棵目录树，以 `/`（root）为根。所有设备、分区都挂载到这棵树下。

Linux has a single directory tree rooted at `/`. All devices and partitions are mounted into this tree.

| 目录 | 用途 Purpose |
|------|-------------|
| `/` | 根目录 / root of everything |
| `/bin` | 基础命令（ls, cp, cat） / essential binaries |
| `/sbin` | 系统管理命令（fdisk, mount） / system binaries |
| `/etc` | 配置文件 / configuration files |
| `/home` | 用户主目录 / user home directories |
| `/var` | 可变数据（日志、缓存） / variable data (logs, cache) |
| `/tmp` | 临时文件（重启清空） / temporary files (cleared on reboot) |
| `/dev` | 设备文件 / device files |
| `/proc` | 内核/进程信息（虚拟文件系统） / kernel/process info (virtual) |
| `/sys` | 内核/驱动信息（虚拟文件系统） / kernel/driver info (virtual) |
| `/usr` | 用户程序和数据 / user programs and data |
| `/boot` | 启动相关文件 / boot loader files |
| `/opt` | 第三方软件 / optional third-party software |

```bash
# 查看目录树 / View the directory tree
tree -L 1 /
# 或 / or
ls -l /
```

---

## 2.2 文件类型 / File Types

Linux 中一切皆文件，但有不同种类。使用 `ls -l` 第一个字符判断：

| 首字符 | 类型 Type | 说明 |
|--------|----------|------|
| `-` | 普通文件 regular file | 数据或文本 / data or text |
| `d` | 目录 directory | 包含其他文件 / contains other files |
| `l` | 符号链接 symlink | 指向另一个文件的快捷方式 / pointer to another file |
| `b` | 块设备 block device | 硬盘等 / hard disks, etc. |
| `c` | 字符设备 char device | 键盘、终端等 / keyboard, terminal, etc. |
| `p` | 命名管道 named pipe | 进程间通信 / inter-process communication |
| `s` | 套接字 socket | 网络通信端点 / network endpoint |

```bash
ls -l /dev/sda         # b — 块设备 / block device
ls -l /dev/tty         # c — 字符设备 / char device
ls -l /etc/os-release  # - → l → 符号链接 / symlink
file /etc/os-release   # 查看文件类型 / check file type
```

---

## 2.3 硬链接 vs 符号链接 / Hard Links vs Symlinks

```bash
# 符号链接（软链接）：指向路径的快捷方式
# Symlink: a shortcut that points to a path
ln -s /original/file /path/to/link

# 硬链接：同一个 inode 的另一个名字，不能跨文件系统，不能链接目录
# Hard link: another name for the same inode, can't cross filesystems or link dirs
ln /original/file /path/to/hardlink
```

| | 符号链接 Symlink | 硬链接 Hard Link |
|---|---|---|
| 删除原文件后 | 链接断掉 broken | 数据仍存在 data still exists |
| 跨文件系统 | 可以 yes | 不可以 no |
| 链接目录 | 可以 yes | 不可以 no |
| 本质 | 指向**路径** points to path | 指向**inode** points to inode |

```bash
# 显示 inode 号 / Show inode numbers
ls -li
# 查找所有硬链接 / Find all hard links to same file
find / -inum <inode_number> 2>/dev/null
```

---

## 2.4 文件权限 / File Permissions

```text
-rwxr-xr-x  1 user group  4096 Jan 10 13:00 file.txt
 └┬┘└┬┘└┬┘
  │  │  └── others (其他人)
  │  └───── group (组)
  └──────── user  (所有者)
```

| 符号 | 数字 | 含义 Meaning |
|------|------|-------------|
| `r` | 4 | 读 Read |
| `w` | 2 | 写 Write |
| `x` | 1 | 执行 Execute |
| `-` | 0 | 无 None |

```bash
chmod 755 file   # rwxr-xr-x → 所有者全权限，其他人只读+执行
chmod 644 file   # rw-r--r-- → 所有者读写，其他人只读
chmod +x script  # 给所有人加执行权限 / add execute for all
chown user:group file   # 改所有者:组 / change owner:group
```

---

## 2.5 查找文件 / Finding Files

```bash
# locate: 从数据库查找（先 updatedb）/ search from database (run updatedb first)
locate filename

# find: 实时搜索 / real-time search — 功能强大，语法特殊
find /path -name "*.txt"            # 按文件名 / by name
find /path -type d -name "backup"   # 按类型 / by type
find /path -size +100M              # 大于 100MB / larger than 100MB
find /path -mtime -7                # 7 天内修改过 / modified within 7 days
find /path -name "*.log" -delete    # 找到并删除 / find and delete
find /path -name "*.txt" -exec grep "error" {} \;  # 找到并执行命令 / find and exec
```

---

## 2.6 磁盘与挂载 / Disks & Mounting

```bash
lsblk              # 列出块设备 / list block devices
df -h              # 磁盘使用情况 / disk usage (human-readable)
du -sh /path/      # 目录总大小 / directory total size
du -h --max-depth=1 /path/  # 子目录各占多少 / per-subdirectory sizes
mount              # 查看所有挂载 / view all mounts
mount /dev/sdb1 /mnt/data   # 挂载设备 / mount a device
umount /mnt/data   # 卸载 / unmount

# /etc/fstab: 定义开机自动挂载 / defines mounts at boot
cat /etc/fstab
```

---

## 练习 / Exercises

进入 `exercises/` 目录运行 `bash check.sh`。

1. 在 `$HOME/linux-lab/temp/chapter2/` 创建一个符号链接 `link-to-passwd` 指向 `$HOME/linux-lab/files/passwd.txt`
2. 用 `find` 在 `$HOME/linux-lab/` 下找到所有 `.log` 文件
3. 查看 `/etc` 目录下所有 `.conf` 文件的权限（一条命令）
4. 用 `du` 查看 `$HOME/linux-lab/` 的总大小
5. 用 `stat` 查看 `$HOME/linux-lab/files/hello.txt` 的 inode 号
