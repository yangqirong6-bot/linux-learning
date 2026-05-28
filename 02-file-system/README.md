# 02 — 文件系统与路径 / File System & Paths

> [!info] 本章目标
> 理解 Linux 的目录树结构，掌握文件类型、权限、硬链接/符号链接、文件查找和磁盘管理。

---

## 2.1 Linux 目录结构 / The Linux Directory Tree

Linux 只有一棵目录树，以 `/`（root）为根。所有设备、分区都**挂载**到这棵树下。

Linux has a single directory tree rooted at `/`. All devices and partitions are **mounted** into this tree.

```bash
# 查看目录树 / View the directory tree
$ tree -L 1 /
$ ls -l /
```

| 目录 | 用途 Purpose |
|------|-------------|
| `/` | 根目录 / root of everything |
| `/bin` | 基础用户命令（ls, cp, cat） / essential binaries |
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

> [!tip] 区分 `/bin` 和 `/sbin`
> - `/bin` — 普通用户也能用的基础命令
> - `/sbin` — 系统管理命令，通常需要 root 权限
> - 很多现代 Linux 发行版把两个合并了（`/bin` → `/usr/bin` 的符号链接）

---

## 2.2 文件类型 / File Types

`ls -l` 第一个字符告诉你文件是什么类型。The first character of `ls -l` tells you the file type.

| 首字符 | 类型 Type | 说明 |
|:------:|----------|------|
| `-` | 普通文件 / regular file | 数据或文本 |
| `d` | 目录 / directory | 包含其他文件 |
| `l` | 符号链接 / symlink | 指向路径的快捷方式 |
| `b` | 块设备 / block device | 硬盘等 |
| `c` | 字符设备 / char device | 键盘、终端等 |
| `p` | 命名管道 / named pipe | 进程间通信 |
| `s` | 套接字 / socket | 网络通信端点 |

```bash
$ ls -l /dev/sda         # b — 块设备 / block device
$ ls -l /dev/tty         # c — 字符设备 / char device
$ ls -l /etc/os-release  # 通常是符号链接 / usually a symlink
$ file /etc/os-release   # 查看实际文件类型 / check actual file type
```

---

## 2.3 硬链接 vs 符号链接 / Hard Links vs Symlinks

> [!note] 核心区别
> - **符号链接**指向**路径**（path）。原文件删了，链接就断了。
> - **硬链接**指向**inode**（数据本身）。只有所有硬链接都删了，数据才被释放。

### 创建链接

```bash
# 符号链接（软链接）/ Symlink: points to a path
ln -s /original/file /path/to/link

# 硬链接 / Hard link: points to the same inode
ln /original/file /path/to/hardlink
```

### 对比

| | 符号链接 Symlink | 硬链接 Hard Link |
|---|---|---|
| 删除原文件后 | ❌ 链接断掉 / broken | ✅ 数据仍存在 / data survives |
| 跨文件系统 | ✅ 可以 / yes | ❌ 不可以 / no |
| 链接目录 | ✅ 可以 / yes | ❌ 不可以 / no |
| 本质 | 指向**路径** / points to path | 指向**inode** / points to inode |

```bash
# 显示 inode 号 — 硬链接共享同一个 inode
$ ls -li

# 查找所有指向同一 inode 的硬链接
$ find / -inum <inode_number> 2>/dev/null

# 查看符号链接指向哪里
$ readlink /etc/os-release
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

### 权限数字对照 / Numeric Permission Table

| 数字 | 权限 | 含义 |
|:---:|------|------|
| 7 | `rwx` | 读 + 写 + 执行 |
| 6 | `rw-` | 读 + 写 |
| 5 | `r-x` | 读 + 执行 |
| 4 | `r--` | 只读 |
| 0 | `---` | 无权限 |

```bash
chmod 755 file   # rwxr-xr-x → 所有者全权限，其他人读+执行
chmod 644 file   # rw-r--r-- → 所有者读写，其他人只读
chmod +x script  # 给所有人加执行权限 / add execute for all
chown user:group file   # 改所有者:组 / change owner:group
```

> [!warning] 权限陷阱
> - `chmod 777` 永远是一个危险操作——任何人都能读写执行
> - 目录需要执行权限（`x`）才能进去；只读（`r`）只能列出文件名

---

## 2.5 查找文件 / Finding Files

### locate — 从数据库查（快，但依赖索引）

```bash
sudo updatedb         # 先更新文件数据库
locate filename       # 然后搜索
```

### find — 实时搜索（慢，但强大灵活）

```bash
# 基础 / Basic
find /path -name "*.txt"            # 按文件名 / by name
find /path -type d -name "backup"   # 按类型：只找目录 / directories only
find /path -type f -name "*.conf"   # 只找普通文件 / regular files only

# 按属性 / By attributes
find /path -size +100M              # 大于 100MB
find /path -mtime -7                # 7 天内修改过 / modified within 7 days
find /path -mmin -30                # 30 分钟内修改过 / modified within 30 min

# 执行操作 / Execute actions
find /path -name "*.log" -delete    # 找到并删除
find /path -name "*.tmp" -exec rm {} \;  # 找到并对每个执行命令
find /path -name "*.txt" -exec grep "error" {} \;  # 找到并搜索内容
```

> [!tip] `find` 语法特殊
> `-exec` 后面的 `{}` 是匹配文件名，"`\;`" 表示命令结束。这是最容易写错的地方。

---

## 2.6 磁盘与挂载 / Disks & Mounting

```bash
lsblk              # 列出块设备 / list block devices
df -h              # 磁盘使用情况 / disk usage (human-readable)
du -sh /path/      # 目录总大小 / directory total size
du -h --max-depth=1 /path/  # 各子目录分别占多少
mount               # 查看所有挂载 / view all mounts
sudo mount /dev/sdb1 /mnt/data   # 挂载设备
sudo umount /mnt/data            # 卸载

# /etc/fstab: 定义开机自动挂载 / auto-mount at boot
cat /etc/fstab
```

---

## 🧪 练习 / Exercises

> [!example] 在虚拟机终端完成
> 进入 `exercises/` 目录运行 `bash check.sh`。

1. 在 `$HOME/linux-lab/temp/` 下创建 `chapter2/`，在里面创建指向 `$HOME/linux-lab/files/passwd.txt` 的符号链接 `link-to-passwd`
2. 用 `find` 在 `$HOME/linux-lab/` 下找到所有 `.log` 文件
3. 查看 `/etc` 目录下所有 `.conf` 文件的权限（用一条命令）
4. 用 `du` 查看 `$HOME/linux-lab/` 的总大小
5. 用 `stat` 查看 `$HOME/linux-lab/files/hello.txt` 的 inode 号

---

> [!info] 相关资源
> - 速查表 / Cheatsheet: [[02-file-system/cheatsheet|Chapter 02 Cheatsheet]]
> - 上一章 / Prev: [[01-cli-basics/README|CLI 基础与 Shell 入门]]
> - 下一章 / Next: [[03-text-processing/README|文本处理三剑客]]
