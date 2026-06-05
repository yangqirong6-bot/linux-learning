# 04 — 用户与权限 / Users & Permissions

> [!info] 本章目标
> 学完这一章，你将能够：理解 UID/GID 体系、创建和管理用户与组、精确控制文件权限、使用 ACL 实现细粒度权限、掌握 sudo 配置、理解 setuid/setgid/sticky bit。
>
> **预计时间**：2-2.5 小时

---

## 4.1 Linux 是多用户系统

### Windows 和 Linux 的区别

Windows 最初是为单用户 PC 设计的，虽然现在支持多用户，但"每个人一台电脑"的思维根深蒂固。Linux 从出生第一天就是多用户系统——一台服务器上几十个人同时登录工作。

```bash
# 看看现在有多少用户在这台机器上
$ who
```
输出：
```text
yang     tty1         2026-01-15 09:30
yang     pts/0        2026-01-15 09:35
alice    pts/1        2026-01-15 10:00
bob      pts/2        2026-01-15 10:15
```

```bash
# 最近有哪些人登录过
$ last | head -10
```

### 三个核心概念

| 概念 | 含义 | 类比 |
|:---|:---|:---|
| 用户 (User) | 登录系统的账户 | 公司的员工 |
| 组 (Group) | 把多个用户放一起 | 公司的部门 |
| 权限 (Permission) | 谁可以对什么做什么 | 门禁卡 |

```bash
# 我是谁？
$ whoami
# 我属于哪些组？
$ groups
```

---

## 4.2 UID 和 GID：用户的身份证号

系统实际上不关心你的用户名，它只认数字——**UID (User ID)** 和 **GID (Group ID)**。用户名只是给人类看的标签。

### 查看自己的 UID/GID

```bash
$ id
```
输出：
```text
uid=1000(yang) gid=1000(yang) groups=1000(yang),4(adm),27(sudo)
```

拆解：
- `uid=1000(yang)` → 我的 UID 是 1000
- `gid=1000(yang)` → 我的主组 GID 是 1000
- `groups=1000(yang),4(adm),27(sudo)` → 我还属于 adm 和 sudo 组

### UID 的范围约定

| UID 范围 | 用途 |
|:---|:---|
| `0` | root（唯一的超级管理员） |
| `1-999` | 系统用户（服务账户，不能登录） |
| `1000+` | 普通用户 |

```bash
# root 永远是 UID=0
$ id root
```
输出：
```text
uid=0(root) gid=0(root) groups=0(root)
```

> [!important] root 的权限不是"很大"，是"无限"
> root 可以做任何事——删掉整个系统、读任何人的文件、修改任何配置。普通用户的行为被权限系统约束，root 不受任何限制。

### 🧪 即时练习

```bash
# 1. 看看自己的 UID 和所属组
$ id

# 2. 看看 root 的 UID
$ id root

# 3. 列出系统上所有的用户
$ cat /etc/passwd | head -10

# 4. 数数这台机器有多少个系统用户（UID < 1000）
$ awk -F: '{if ($3 < 1000) print $1}' /etc/passwd | wc -l
```

---

## 4.3 用户数据库：passwd / shadow / group

Linux 把用户信息存在三个文件里（不是数据库，就是纯文本文件）：

### `/etc/passwd` — 用户列表（所有人可读）

```bash
$ cat /etc/passwd | grep yang
```
输出：
```text
yang:x:1000:1000:Yang,,,:/home/yang:/bin/bash
```

用 `:` 分隔的 7 个字段：

| 字段 | 含义 | 示例 |
|:---|:---|:---|
| `yang` | 用户名 | — |
| `x` | 密码占位符（真密码在 shadow 里） | — |
| `1000` | UID | — |
| `1000` | GID（主组 ID） | — |
| `Yang,,,` | GECOS（全名 + 办公室 + 电话等） | 可选 |
| `/home/yang` | 家目录 | — |
| `/bin/bash` | 登录 Shell | — |

> [!note] 如果最后一个字段是 `/usr/sbin/nologin` 或 `/bin/false`
> 这个用户**不能登录**——它是服务账户，只用来运行程序。
> ```bash
> $ cat /etc/passwd | grep nologin | head -5
> ```

### `/etc/shadow` — 密码哈希（只有 root 能读）

```bash
$ sudo cat /etc/shadow | grep yang
```
输出：
```text
yang:$6$xyz...加密后的密码哈希...:19700:0:99999:7:::
```

| 字段 | 含义 |
|:---|:---|
| `yang` | 用户名 |
| `$6$xyz...` | 加密后的密码（`$6$` = SHA-512） |
| `19700` | 上次改密码的日期（从 1970-01-01 起的天数） |
| `0` | 最少使用天数才能再次改密码 |
| `99999` | 密码有效期（天） |
| `7` | 过期前 7 天开始提醒 |

> [!danger] shadow 文件绝对不能丢
> 如果 shadow 丢失，所有人的密码都没了，谁都登不进去。这就是为什么它只有 root 能读。

### `/etc/group` — 组列表

```bash
$ cat /etc/group | grep yang
```
输出：
```text
adm:x:4:syslog,yang
sudo:x:27:yang
yang:x:1000:
```

四个字段：组名 / 密码占位符 / GID / 组成员列表（逗号分隔）。

### 🧪 即时练习

```bash
# 1. 数数系统有多少个用户
$ wc -l /etc/passwd

# 2. 看看哪些用户有家目录
$ awk -F: '{print $1, $6}' /etc/passwd | grep home

# 3. 找出所有能登录的用户（Shell 不是 nologin）
$ cat /etc/passwd | grep -v nologin | grep -v /bin/false
```

---

## 4.4 创建和管理用户与组

### `useradd` — 添加用户

```bash
# 最简单的（使用所有默认值）
$ sudo useradd alice

# 常用选项
$ sudo useradd -m -s /bin/bash -G sudo,developers -c "Alice Wang" bob
```

| 选项 | 含义 |
|:---|:---|
| `-m` | 自动创建家目录 `/home/alice` |
| `-s /bin/bash` | 设置登录 Shell |
| `-G sudo,developers` | 额外附加组 |
| `-c "Alice Wang"` | 全名 / 备注 |
| `-u 2000` | 手动指定 UID |

```bash
# 设密码（不设的话账户是锁定的！）
$ sudo passwd alice
```

### `usermod` — 修改用户

```bash
$ sudo usermod -aG docker alice     # 把 alice 加进 docker 组（-a 是追加，不加会覆盖！）
$ sudo usermod -s /bin/zsh alice    # 改 Shell
$ sudo usermod -L alice             # 锁定账户（Lock）
$ sudo usermod -U alice             # 解锁（Unlock）
```

> [!warning] `-aG` 不要忘记 `-a`
> `usermod -G docker alice` 会把 alice **替换到** docker 组——她之前所在的组全没了！
> `usermod -aG docker alice` 才是**追加到** docker 组。

### `userdel` — 删除用户

```bash
$ sudo userdel alice                # 只删用户，保留家目录
$ sudo userdel -r alice             # 连家目录和邮件一起删掉
```

### `groupadd` / `groupdel` — 管理组

```bash
$ sudo groupadd developers
$ sudo groupdel developers
```

### 🧪 即时练习

```bash
# 1. 创建一个测试用户
$ sudo useradd -m -s /bin/bash testuser

# 2. 设密码
$ sudo passwd testuser

# 3. 看看这个用户的信息
$ id testuser
$ cat /etc/passwd | grep testuser

# 4. 锁定，然后解锁
$ sudo usermod -L testuser
$ sudo passwd -S testuser          # 看看账户状态
$ sudo usermod -U testuser

# 5. 清理
$ sudo userdel -r testuser
```

---

## 4.5 换身份：`su` 和 `sudo`

### `su` — 切换用户（Switch User）

```bash
$ su - alice               # 切换到 alice（需要 alice 的密码）
$ su -                     # 切换到 root（需要 root 密码）
```

`-` 的含义是"加载目标用户的环境变量"——不用 `-` 你会留在原来的目录，环境变量也不变。

### `sudo` — 临时提权（SuperUser Do）

```bash
$ sudo whoami              # root
$ sudo apt update           # 以 root 身份更新
$ sudo -u alice whoami      # 以 alice 身份运行
```

sudo 的优势：**不需要 root 密码，用你自己的密码就行**；**每条 sudo 命令都被记录**。

```bash
# 看看你有哪些 sudo 权限
$ sudo -l
```
输出：
```text
User yang may run the following commands on ubuntu:
    (ALL : ALL) ALL
```

> [!tip] su 和 sudo 的选择
> - 日常操作用 `sudo`（安全、有日志）
> - 需要连续做很多 root 操作时用 `sudo -i`（进入 root Shell）
> - 不要直接 `su -` 然后用 root 一直操作——容易手滑

### `/etc/sudoers` 和 `visudo`

**不要直接编辑 `/etc/sudoers`！** 语法错误会让你失去 sudo 权限。用 `visudo`，它会在保存前检查语法。

```bash
$ sudo visudo
```

```text
# 允许 yang 无需密码就 sudo
yang ALL=(ALL) NOPASSWD: ALL

# 允许 developers 组的所有人 sudo
%developers ALL=(ALL) ALL

# 允许 alice 只重启 nginx（不能做其他 root 操作）
alice ALL=(ALL) /usr/bin/systemctl restart nginx
```

### 🧪 即时练习

```bash
# 1. 看看你能 sudo 什么
$ sudo -l

# 2. 查看 sudo 记录
$ sudo cat /var/log/auth.log | grep sudo | tail -10

# 3. 试试 sudo -i 进入 root Shell（小心操作！）
$ sudo -i
# exit
```

---

## 4.6 文件权限深入：setuid / setgid / sticky bit

### 复习：基本权限

```bash
$ ls -l /bin/ls
```
输出：
```text
-rwxr-xr-x 1 root root 138208 Jan 15 14:00 /bin/ls
```

9 个权限位：user(rwx) + group(r-x) + others(r-x)。

### setuid (SUID) — 以文件所有者的身份运行

最典型的例子是 `passwd` 命令。普通用户改密码需要修改 `/etc/shadow`（只有 root 能写），所以 `passwd` 被设了 SUID：

```bash
$ ls -l /usr/bin/passwd
```
输出：
```text
-rwsr-xr-x 1 root root 59976 Jan 15 14:00 /usr/bin/passwd
```

注意 `rws` 而不是 `rwx`——这个 `s` 就是 SUID 位。它表示：**任何人运行 passwd，都以 root 身份运行**。

```bash
# 设置 SUID：4 + 文件权限
$ chmod 4755 myscript     # rwsr-xr-x
# 或者用符号法
$ chmod u+s myscript
```

> [!danger] SUID 是把双刃剑
> 带 SUID 的程序如果有 bug，攻击者就能以 root 身份执行任意代码。永远不要给脚本 (`#!/bin/bash`) 设 SUID——它们可以被篡改。

### setgid (SGID) — 以文件所属组的身份运行

SGID 对目录特别有用：

```bash
$ mkdir shared
$ chgrp developers shared
$ chmod 2775 shared       # drwxrwsr-x（注意组权限位的 s）
```

此后任何人往 `shared/` 里创建文件，文件的所属组自动设为 `developers`——不管创建者是谁。

### sticky bit — 只有文件所有者才能删

看 `/tmp` 的权限：

```bash
$ ls -ld /tmp
```
输出：
```text
drwxrwxrwt 20 root root 4096 Jan 15 14:30 /tmp
```

最后一位是 `t`（而不是 `x`）——这就是 sticky bit。它表示：**任何人都可以在 /tmp 里创建文件，但只能删除自己创建的文件**。

```bash
$ chmod 1777 shared_dir     # rwxrwxrwt
# 或
$ chmod +t shared_dir
```

### 三位的汇总

| 位 | 数字 | 作用 | 挂在谁的权限位 |
|:---|:---|:---|:---|
| SUID | 4 | 以**所有者**身份运行 | user 位 |
| SGID | 2 | 以**所属组**身份运行 | group 位 |
| Sticky | 1 | 只能删**自己的**文件 | others 位 |

```bash
# chmod 前面多加一位数字来控制这三个位
$ chmod 4755 file       # SUID
$ chmod 2755 dir        # SGID
$ chmod 1777 dir        # Sticky
$ chmod 6755 file       # SUID + SGID（6 = 4 + 2）
```

### 🧪 即时练习

```bash
# 1. 找出系统上所有带 SUID 的程序
$ sudo find /usr/bin -perm -4000 -ls

# 2. 看看 /tmp 的 sticky bit
$ ls -ld /tmp

# 3. 创建一个共享目录，设 SGID
$ mkdir ~/test_shared
$ chmod 2775 ~/test_shared
$ ls -ld ~/test_shared
# drwxrwsr-x
$ rm -r ~/test_shared
```

---

## 4.7 ACL：比基本权限更精细的权限

基本权限只有 user/group/others 三级。如果想给**一个特定的用户**对**一个特定的文件**设置权限，就得用 ACL。

### 查看 ACL：`getfacl`

```bash
$ getfacl myfile.txt
```
输出：
```text
# file: myfile.txt
# owner: yang
# group: yang
user::rw-
group::r--
other::r--
```

### 设置 ACL：`setfacl`

```bash
# 给 alice 单独加读权限（不影响其他人的权限）
$ setfacl -m u:alice:r myfile.txt

# 给 developers 组加读写权限
$ setfacl -m g:developers:rw myfile.txt

# 删除 alice 的权限
$ setfacl -x u:alice myfile.txt

# 删掉所有 ACL
$ setfacl -b myfile.txt
```

设置 ACL 后，`ls -l` 的权限后面会多一个 `+` 号：

```bash
$ ls -l myfile.txt
```
输出：
```text
-rw-r--r--+ 1 yang yang 100 Jan 15 15:00 myfile.txt
```

这个 `+` 表示"有额外的 ACL 规则"。

### 实际场景：共享项目目录

```bash
# 项目目录：所有者 yang 可以读写执行
# developers 组成员可以读写执行
# alice（不是 developers 组的）只能读
$ mkdir project
$ setfacl -m g:developers:rwx project
$ setfacl -m u:alice:r-x project
$ getfacl project
```

> [!tip] ACL vs 基本权限
> - 基本权限：简单场景，够用就好
> - ACL：多人协作、跨组共享、需要给"某一个人"特殊权限时
> - 大多数服务器的日常场景下基本权限就够了

### 🧪 即时练习

```bash
$ cd ~

# 1. 创建一个文件
$ echo "secret" > acl_test.txt

# 2. 查看默认 ACL
$ getfacl acl_test.txt

# 3. 给自己加个 ACL（虽然你已经是 owner 了）
$ setfacl -m u:root:r acl_test.txt
$ getfacl acl_test.txt

# 4. 看看 ls -l 的那个 + 号
$ ls -l acl_test.txt

# 5. 清理
$ rm acl_test.txt
```

---

## 4.8 实战：搭建多用户共享环境

### 场景

你想要三个用户（alice, bob, charlie）共享一个项目目录：
- 所有人都能读写自己的文件
- 所有人的文件自动归 `developers` 组
- 别人不能删另一人的文件（sticky-like 效果）
- 有个 `public/` 子目录所有人都能自由读写

```bash
# 1. 创建组和用户
$ sudo groupadd developers
$ sudo useradd -m -G developers alice
$ sudo useradd -m -G developers bob
$ sudo useradd -m -G developers charlie

# 给每个人设密码
$ sudo passwd alice
$ sudo passwd bob
$ sudo passwd charlie

# 2. 创建项目目录
$ sudo mkdir -p /srv/project
$ sudo chown yang:developers /srv/project
$ sudo chmod 2770 /srv/project        # SGID + rwxrwx---
# 270 = 2(SGID) + 770(rwxrwx---)

# 3. 创建 public 子目录（任何人可读写但 sticky）
$ sudo mkdir /srv/project/public
$ sudo chmod 1777 /srv/project/public  # Sticky + rwxrwxrwx

# 4. 验证
$ ls -ld /srv/project
# drwxrws--- 2 yang developers 4096 ... /srv/project
#      ↑ s = SGID，新文件自动归 developers 组
$ ls -ld /srv/project/public
# drwxrwxrwt 2 yang developers 4096 ... /srv/project/public
#            ↑ t = sticky，只能删自己的文件
```

---

## 🧪 本章综合练习

> [!example] 在虚拟机终端完成

1. 创建用户 `student`，主组 `students`，附加组 `sudo`，Shell 为 `/bin/bash`
2. 把 `/home/student` 下新创建文件的默认组设为 `students`（用 SGID）
3. 创建一个只有你自己能读写的文件 `secret.txt`（权限 `600`）
4. 用 ACL 给 `student` 用户单独添加对 `~/linux-lab/files/fruits.txt` 的只读权限
5. 找出系统上 `/usr/bin` 下所有带 SUID 的程序，把数量写进 `suid-count.txt`

---

## 📋 本章命令速查

| 命令 | 作用 | 关键选项 |
|:---|:---|:---|
| `whoami` | 当前用户 | — |
| `id` | UID/GID/组 | — |
| `groups` | 所属组 | — |
| `useradd -m -G` | 创建用户 | `-s` Shell, `-c` 备注 |
| `usermod -aG` | 修改用户 | `-L` 锁, `-U` 解锁 |
| `userdel -r` | 删除用户 | `-r` 连家目录删 |
| `passwd` | 设/改密码 | `-l` 锁, `-u` 解锁 |
| `su -` | 切换用户 | — |
| `sudo` | 临时提权 | `-u` 指定用户, `-i` root Shell |
| `visudo` | 安全编辑 sudoers | — |
| `chmod 4755` | 权限 + SUID | `u+s` `g+s` `+t` |
| `chown user:group` | 改所有者 | `-R` 递归 |
| `setfacl -m` | 设 ACL | `-x` 删, `-b` 清空 |
| `getfacl` | 查看 ACL | — |

---

> [!info] 继续学习
> - 速查表：[[04-users-permissions/cheatsheet|Chapter 04 Cheatsheet]]
> - 上一章：[[03-text-processing/README|文本处理三剑客]]
> - 下一章：[[05-processes/README|进程管理]]
