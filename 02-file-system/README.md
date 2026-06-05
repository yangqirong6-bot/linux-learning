# 02 — 文件系统与路径 / File System & Paths

> [!info] 本章目标
> 学完这一章，你将能够：理解 Linux 的目录树结构、识别不同的文件类型、看懂和修改文件权限、理解硬链接和符号链接的区别、用 `find` 精确搜索文件、查看磁盘使用情况。
>
> **预计时间**：1.5-2 小时

---

## 2.1 Linux 的目录树：只有一个根

### 和 Windows 的根本区别

这是新手最容易困惑的一点：

| Windows | Linux |
|:---|:---|
| 多棵"树"：`C:\`、`D:\`、`E:\` | **一棵树**：`/` |
| 每个盘独立一个根 | 所有盘/设备/分区挂载到 `/` 下面 |
| 反斜杠：`C:\Users\yang` | 正斜杠：`/home/yang` |

在 Windows 里，插一个 U 盘，它变成 `E:\`。在 Linux 里，插一个 U 盘，它被**挂载（mount）**到 `/mnt/usb` 或 `/media/yang/usb`——它变成了目录树上的一个分支。

```bash
# 看看整个系统的目录树（只看最顶层）
$ ls -l /
```
输出：
```text
drwxr-xr-x   2 root root  4096 Jan 15 14:00 bin
drwxr-xr-x   4 root root  4096 Jan 15 14:00 boot
drwxr-xr-x  20 root root  4260 Jan 15 14:30 dev
drwxr-xr-x 144 root root 12288 Jan 15 14:30 etc
drwxr-xr-x   3 root root  4096 Jan 15 14:00 home
drwxr-xr-x  20 root root  4096 Jan 15 14:00 lib
drwxr-xr-x   2 root root  4096 Jan 15 14:00 media
drwxr-xr-x   2 root root  4096 Jan 15 14:00 mnt
drwxr-xr-x   2 root root  4096 Jan 15 14:00 opt
dr-xr-xr-x 300 root root     0 Jan 15 14:30 proc
drwx------   5 root root  4096 Jan 15 14:30 root
drwxr-xr-x  38 root root  1060 Jan 15 14:30 run
drwxr-xr-x   2 root root  4096 Jan 15 14:00 sbin
drwxr-xr-x   2 root root  4096 Jan 15 14:00 srv
dr-xr-xr-x  13 root root     0 Jan 15 14:30 sys
drwxrwxrwt  12 root root  4096 Jan 15 14:30 tmp
drwxr-xr-x  11 root root  4096 Jan 15 14:00 usr
drwxr-xr-x  12 root root  4096 Jan 15 14:30 var
```

### 每个目录是干什么的？

| 目录                | 用途                            | 你应该关注吗？  |
| :---------------- | :---------------------------- | :------: |
| `/bin`            | 所有用户都能用的基础命令（`ls`、`cp`、`cat`） |   不用管    |
| `/sbin`           | 系统管理命令（通常需要 root 权限）          |   不用管    |
| `/etc`            | **所有配置文件都在这里**                |  ✅ 经常要用  |
| `/home/yang/`     | **你的主目录（`~`）**                | ✅ 每天在这里  |
| `/var/log/`       | **系统日志**                      | ✅ 排查问题时看 |
| `/tmp`            | 临时文件，重启就清空                    |   偶尔用    |
| `/dev`            | 设备文件（硬盘、键盘、终端等）               |  很少直接访问  |
| `/proc`           | 内核和进程信息（虚拟的，不占磁盘）             | 排查性能问题时看 |
| `/boot`           | 启动文件（内核、引导程序）                 |   基本不用   |
| `/usr`            | 用户安装的软件                       |   不用管    |
| `/opt`            | 第三方商业软件                       |   很少用    |
| `/media` 和 `/mnt` | 临时挂载点（U 盘、外接硬盘）               |  挂载设备时用  |

> [!tip] 你日常只会在三个地方活动
> - `~`（你自己的 home 目录）—— 你的文件
> - `/etc` —— 改配置
> - `/var/log` —— 看日志
>
> 其他目录大部分时候不用碰。

```bash
# 快速体验：看看每个目录长什么样
$ ls /etc          # 配置文件海洋
$ ls /var/log      # 各种 .log 文件
$ ls /proc         # 一堆数字目录 + 奇怪的名字
```

### 🧪 即时练习

```bash
# 1. 列出根目录，找出 home 和 etc
$ ls /

# 2. 进 /etc 看看有多少 .conf 结尾的配置文件
$ cd /etc
$ ls *.conf

# 3. 回家
$ cd ~
```

---

## 2.2 文件不只是"普通文件"

在 Windows 里，文件类型主要靠后缀名（`.txt`、`.exe`、`.jpg`）。Linux 里后缀名只是**提示**，系统通过文件的实际属性来判断类型。

用 `ls -l` 看第一列的第一个字符：

```bash
$ ls -l /dev/sda
```
输出：
```text
brw-rw---- 1 root disk 8, 0 Jan 15 14:30 /dev/sda
```
首字符 `b` = 块设备（硬盘）。

```bash
$ ls -l /dev/tty
```
输出：
```text
crw-rw-rw- 1 root tty 5, 0 Jan 15 14:30 /dev/tty
```
首字符 `c` = 字符设备（终端）。

### 七种文件类型

| 首字符 | 类型   | 是什么            | 在哪见过                   |
| :-: | :--- | :------------- | :--------------------- |
| `-` | 普通文件 | 文字、图片、程序       | 几乎所有你创建的文件             |
| `d` | 目录   | 装其他文件的容器       | `Desktop/`、`/etc/`     |
| `l` | 符号链接 | 指向另一个文件的"快捷方式" | `/etc/os-release`      |
| `b` | 块设备  | 硬盘、SSD、U 盘     | `/dev/sda`             |
| `c` | 字符设备 | 键盘、终端、鼠标       | `/dev/tty`、`/dev/null` |
| `p` | 命名管道 | 进程间通信用的管道      | 少见                     |
| `s` | 套接字  | 网络通信端点         | `/var/run/docker.sock` |

```bash
# 查看文件的具体类型
$ file /bin/ls
```
输出：
```text
/bin/ls: ELF 64-bit LSB pie executable, x86-64, ...
```

```bash
$ file /etc/passwd
```
输出：
```text
/etc/passwd: ASCII text
```

```bash
$ file /dev/null
```
输出：
```text
/dev/null: character special (1/3)
```

> [!tip] `file` 命令会读取文件内容来判断类型，比看后缀名可靠得多。

> [!WARNING] 注意 Linux 识别文件**绝对不依赖扩展名**（它不在乎文件是不是 `.txt` 或 `.mp4` 结尾）。`file` 命令通过以下“三步走”的严格流程来鉴定文件的真实格式。

**1. 第一关：查户口（文件系统测试 / Filesystem Test）**

- **原理**：调用底层系统（`stat`），直接查操作系统的“设备台账”，问这个路径是什么属性。
    
- **结果**：如果系统明确指出它是特殊节点，`file` 就直接输出结果并停止探测。
    
    - _示例_：测 `/dev/null`，直接输出 `character special`。
        

**2. 第二关：验 DNA（魔数测试 / Magic Number Test）**

- **原理**：如果第一关查出只是个普通文件，`file` 会拆开文件，读取最开头的几个字节（即“魔数 / Magic Number”），并和系统自带的“魔数密码本”进行比对。
    
- **结果**：大多数标准二进制文件在开头都有固定标识。
    
    - _示例_：测 `/bin/ls`，发现开头是 `\x7fELF`，立刻判定并输出：`ELF 64-bit... executable`（64位可执行程序）。
        

**3. 第三关：测语言（字符集与语言测试 / Language Test）**

- **原理**：如果前两关都没结论（没有魔数），`file` 会假设它是文本。接着它扫描文件前几 KB 的内容，逐字节分析字符编码。
    
- **结果**：如果全是由标准英文字母、符号等组成的纯净字符，没有乱码，就判定为文本。
    
    - _示例_：测 `/etc/passwd`，全符合标准编码，输出：`ASCII text`。
### 🧪 即时练习

```bash
# 1. 看根目录下各项目的文件类型
$ ls -l /

# 2. 用 file 识别不同类型的文件
$ file /bin/bash
```
![[Pasted image 20260603233618.png]]
```
$ file /etc/hostname
$ file ~/.bashrc
```
![[Pasted image 20260603233638.png]]
```
$ file /dev/zero
```
![[Pasted image 20260603233756.png]]

> [!info] 🗂️ Linux 文件类型首字符速查表 (`ls -l`)
> 
> 在 Linux 的世界里，“一切皆文件”。通过 `ls -l` 输出的第一个字符，就能看透这个文件的真实身份。
> 
> | 首字符 | 文件类型 | 英文全称 | 解释（公司资产类比） | 常见示例 |
> | :---: | :--- | :--- | :--- | :--- |
> | `-` | 普通文件 | Regular File | **纸质报告/档案**。存放具体数据内容。 | 纯文本、图片、压缩包、可执行程序等 |
> | `d` | 目录 | Directory | **档案柜**。本身没有数据，用于装其他文件或子目录。 | 根目录 `/`、`/home/user` |
> | `l` | 符号链接 | Symbolic Link | **指路牌/便利贴**。极小的文件，指向另一个真正的文件路径（类似快捷方式）。 | 动态链接库 `/lib64/libc.so.6` |
> | `b` | 块设备 | Block Device | **带编号的立体仓库**。按“数据块”为单位进行随机读写的硬件。 | 硬盘 `/dev/sda`、U 盘、SSD |
> | `c` | 字符设备 | Character Device | **传送带/碎纸机**。按“字符”顺序进行流式收发的硬件，不支持随机跳转读写。 | 键盘、终端 `/dev/tty`、黑洞 `/dev/null` |
> | `p` | 命名管道 | Named Pipe | **跨部门传票筒**。用于两个进程间的单向数据传输（先进先出 FIFO）。 | 复杂后台服务或脚本编程中多见 |
> | `s` | 套接字 | Socket | **总机/多功能插座**。用于网络通信或同一台机器上不同进程间的高级通信。 | `/var/run/docker.sock`、MySQL 接口 |
---

## 2.3 文件权限：谁可以对这个文件做什么？

搞懂权限是 Linux 的基本功。权限分为三个维度：**谁（user/group/others）× 什么操作（read/write/execute）**。

### 拆解 `ls -l` 的权限列

```bash
$ ls -l ~/.bashrc
```
输出：
```text
-rw-r--r-- 1 yang yang 3771 Jan 15 14:23 /home/yang/.bashrc
```

把这串字符拆开：

```text
-   rw-   r--   r--
│   └┬┘   └┬┘   └┬┘
│    │     │     └── 其他人 (others) 的权限：只能读
│    │     └─────── 组 (group) 的权限：只能读
│    └──────────── 所有者 (user) 的权限：可以读+写
└───────────────── 文件类型：普通文件
```

每一组三个字符：`r`（读）、`w`（写）、`x`（执行）。

### 权限对文件和目录的含义不同

| 权限 | 对文件 | 对目录 |
|:---|:---|:---|
| `r` | 可以看文件内容 | 可以列出目录里的文件名 |
| `w` | 可以修改文件内容 | 可以在目录里创建/删除文件 |
| `x` | 可以执行这个程序/脚本 | 可以**进入**这个目录（`cd` 进去） |

> [!warning] 最容易搞错的一点
> 目录的 `x`（执行权限）控制你能不能 "进入" 这个目录。没有 `r` 只是不能列出文件名（不知道里面有什么），但没有 `x` 你连进都进不去。
>
> 试试看：
> ```bash
> $ mkdir testdir
> $ chmod -x testdir      # 去掉自己的执行权限
> $ cd testdir
> # bash: cd: testdir: Permission denied
> $ chmod +x testdir      # 加回来
> $ cd testdir            # 这下可以了
> ```
![[Pasted image 20260603235235.png]]
### `chmod`【**change mode**】：修改权限

#### 方法一：数字法（快，推荐记）

系统给每种权限赋予了一个数字权重：

- **`r` (读取) = 4**
    
- **`w` (写入) = 2**
    
- **`x` (执行) = 1**
    
- **无权限 (-) = 0**
    
**怎么算？加起来就行！** 如果你想拥有读取 (4) 和写入 (2) 权限，但不想要执行 (1) 权限，那么权限值就是 `4 + 2 = 6`。 你想让“所有者(u)”、“用户组(g)”和“其他人(o)”分别拥有不同的权限，只需连写三个数字。

| 数字  | 权限    | 含义         |
| :-: | :---- | :--------- |
|  7  | `rwx` | 读 + 写 + 执行 |
|  6  | `rw-` | 读 + 写      |
|  5  | `r-x` | 读 + 执行     |
|  4  | `r--` | 只读         |
|  0  | `---` | 啥都不能做      |

三位数字分别对应：user（所有者）、group（组）、others（其他人）。

```bash
$ chmod 755 script.sh      # rwxr-xr-x
```
拆解：`7` = user 可以读写执行，`5` = group 可以读和执行，`5` = others 可以读和执行。这是**脚本和可执行文件最常见的权限**。

```bash
$ chmod 644 file.txt       # rw-r--r--
```
拆解：`6` = user 可以读写，`4` = group 只读，`4` = others 只读。这是**普通文件最常见的权限**。

```bash
$ chmod 600 secret.key     # rw-------
```
拆解：只有所有者（你）能读写。group 和 others 完全看不到内容。这是**私密文件（SSH 密钥等）**的标准权限。

> [!danger] 永远不要做的事
> ```bash
> $ chmod 777 file      # ❌ 任何人可以读写执行！安全隐患极大！
> ```
> 除非你真的**确定**需要让所有人读写执行，否则永远不用 `777`。

#### 方法二：符号法（直观，适合微调）

```bash
$ chmod +x script.sh       # 给所有人加执行权限
$ chmod -x script.sh       # 去掉所有人的执行权限
$ chmod u+w file.txt       # 只给所有者 (user) 加写权限
$ chmod g-w file.txt       # 只去掉组 (group) 的写权限
$ chmod o-rwx file.txt     # 去掉其他人 (others) 的所有权限
$ chmod a=r notes.md       #强制让所有人(all)都只能读取
```

> [!important] 什么时候用哪种？
> - **从零设权限** → 数字法：`chmod 755 myscript`
> - **微调现有权限** → 符号法：`chmod +x myscript`

### `chown`：修改所有者

```bash
$ chown user:group file    # 同时改所有者和组
$ chown user file          # 只改所有者
$ chown :group file        # 只改组
```

普通用户不能 `chown` 别人的文件（只有 root 可以），这能防止你把文件冒充给别人。

### 🧪 即时练习

```bash
$ cd ~

# 1. 创建一个文件，看看默认权限
$ touch test_perm
$ ls -l test_perm
# 输出类似：-rw-r--r--  (644)

# 2. 把它改成只有你能读写
$ chmod 600 test_perm
$ ls -l test_perm
# 输出：-rw-------  (600)

# 3. 改成可执行
$ chmod 755 test_perm
$ ls -l test_perm
# 输出：-rwxr-xr-x  (755)

# 4. 恢复初始权限
$ chmod 644 test_perm

# 5. 清理
$ rm test_perm
```

---

## 2.4 硬链接和符号链接：文件的"分身"和"快捷方式"

### 先理解 inode：每个文件的身份证号

Linux 文件系统里，**文件名和文件数据是分开的**。每个文件有一个唯一的 inode 号，文件数据真正存储在 inode 指向的数据块里。

用 `ls -li` 看 inode 号（第一列）：

```bash
$ ls -li ~/.bashrc
```
输出：
```text
262147 -rw-r--r-- 1 yang yang 3771 Jan 15 14:23 /home/yang/.bashrc
```

`262147` 就是这个文件的 inode 号。你可以把 inode 理解为文件的**身份证号**——它指向"数据在哪里"。

### 符号链接（软链接 / Symlink）= Windows 快捷方式

符号链接是一个小文件，里面存着"目标路径"。它有自己的 inode，指向的不是数据，而是一段路径文字。

```bash
$ ln -s /etc/hostname ~/hostname-link
$ ls -l ~/hostname-link
```
输出：
```text
lrwxrwxrwx 1 yang yang 14 Jan 15 15:00 /home/yang/hostname-link -> /etc/hostname
```

注意：
- 首字符 `l` = 这是一个符号链接
- `-> /etc/hostname` = 它指向 `/etc/hostname`
- 文件大小 `14` = 里面存的就是这段路径字串的长度

```bash
# 读符号链接，跟读原文件一样
$ cat ~/hostname-link
```
输出：
```text
ubuntu
```

```bash
# 删掉原文件，链接就断了
$ ls -l ~/hostname-link    # 原文件还在，正常
$ sudo rm /etc/hostname    # ❌ 别真删！这只是演示原理
# 如果删了，hostname-link 会变成红色闪烁的"断链"（dangling link）
```

### 硬链接（Hard Link）= 同一个 inode 的另一个名字

硬链接是给同一个 inode 起第二个名字。它**不是一个独立文件**，而是同一个文件的另一个入口。

```bash
$ cd ~
$ echo "hello" > original.txt
$ ln original.txt hardlink.txt      # 创建硬链接

$ ls -li original.txt hardlink.txt
```
输出：
```text
524288 -rw-r--r-- 2 yang yang 6 Jan 15 15:10 hardlink.txt
524288 -rw-r--r-- 2 yang yang 6 Jan 15 15:10 original.txt
```

关键信息：
- **inode 号一样**（524288）—— 它们就是同一个文件
- 第 2 列 `2` = 这个 inode 现在有两个名字（link count）
- 修改其中一个，另一个同步变（因为指向同一份数据）

```bash
$ echo "new line" >> original.txt
$ cat hardlink.txt
```
输出：
```text
hello
new line
```

```bash
# 删掉 original.txt，数据还在（因为 hardlink.txt 还指向它）
$ rm original.txt
$ cat hardlink.txt          # 正常读取！
```
输出：
```text
hello
new line
```

### 对比总结

| | 符号链接 Symlink | 硬链接 Hard Link |
|:---|:---|:---|
| 本质 | 一个小文件，存目标路径 | 同一个 inode 的另一个名字 |
| 删掉原文件 | ❌ 链接断掉 | ✅ 数据还在 |
| 跨文件系统（C 盘链接到 D 盘） | ✅ 可以 | ❌ 不行 |
| 链接目录 | ✅ 可以 | ❌ 不行（通常） |
| 怎么创建 | `ln -s 目标 链接名` | `ln 目标 链接名` |
| 看得见指向吗 | ✅ `ls -l` 显示 `-> 目标` | ❌ `ls -l` 看不出区别 |

> [!tip] 该用哪个？
> - 绝大多数情况用**符号链接**（更安全、更明显）
> - 硬链接几乎只在特定场景用（比如备份系统保护关键文件不被误删）

### 🧪 即时练习

```bash
$ cd ~

# 1. 创建一个文件
$ echo "data" > myfile.txt

# 2. 创建符号链接
$ ln -s myfile.txt mylink.txt
$ ls -l mylink.txt          # 看到 -> 指向吗？

# 3. 创建硬链接
$ ln myfile.txt myhard.txt
$ ls -li myfile.txt myhard.txt    # inode 号一样吗？

# 4. 验证：修改 myfile，看硬链接是否同步
$ echo "more data" >> myfile.txt
$ cat myhard.txt            # 应该也有 "more data"

# 5. 验证：删原文件，硬链接仍然能用
$ rm myfile.txt
$ cat myhard.txt            # 数据完好！

# 6. 清理
$ rm myhard.txt mylink.txt
```

---

## 2.5 查找文件：`find` 和 `locate`

### `locate` — 快，但从数据库查

```bash
# 先更新数据库（系统一般每天自动更新一次）
$ sudo updatedb

# 搜索
$ locate .bashrc
```
输出：
```text
/etc/bash.bashrc
/etc/skel/.bashrc
/home/yang/.bashrc
/usr/share/base-files/dot.bashrc
```

> [!tip] `locate` 优缺点
> - 优点：瞬间出结果
> - 缺点：只能搜文件名，不能搜内容、大小、时间；刚创建的文件搜不到（数据库还没更新）

### `find` — 慢，但能搜任何条件

`find` 的语法比较特殊，需要练习才能记住。基本格式：

```text
find [从哪里搜] [什么条件] [找到后做什么]
```

#### 按名字搜

```bash
# 在当前目录及子目录中，找所有 .log 文件
$ find . -name "*.log"

# 在 /etc 下找所有 .conf 文件
$ find /etc -name "*.conf"

# 忽略大小写
$ find . -iname "README*"     # -iname = case insensitive
```

#### 按类型搜

```bash
$ find . -type f              # 只要普通文件
$ find . -type d              # 只要目录
$ find . -type l              # 只要符号链接
```

#### 按时间搜

```bash
$ find . -mtime -7            # 最近 7 天内修改过
$ find . -mtime +30           # 30 天以前修改过
$ find . -mmin -60            # 最近 60 分钟内修改过
$ find . -newer reference.txt # 比 reference.txt 更新的文件
```

#### 按大小搜

```bash
$ find . -size +100M          # 大于 100MB
$ find . -size -1k            # 小于 1KB
$ find . -size +10M -size -100M  # 10MB 到 100MB 之间
```

#### 组合条件

```bash
# 所有 .log 文件 AND 大于 10MB
$ find . -name "*.log" -size +10M

# OR 条件（两个条件间用 -o）
$ find . -name "*.jpg" -o -name "*.png"
```

#### 找到后执行操作

```bash
# 找到并删除（危险！先不加 -delete 预演一遍）
$ find . -name "*.tmp" -delete

# 找到并对每个文件执行命令
$ find . -name "*.txt" -exec cat {} \;       # 显示每个 .txt 文件的内容

# -exec 语法：{} 代表找到的文件名，\; 表示命令结束（这个反斜杠分号不要忘记）
```

> [!warning] `find -delete` 前先预演
> 永远先不加 `-delete` 跑一遍，确认找到的东西是你想删的：
> ```bash
> $ find . -name "*.tmp"        # 先看看会找到什么
> $ find . -name "*.tmp" -delete   # 确认没问题再加 -delete
> ```

### 🧪 即时练习

```bash
# 1. 在 /etc 下找所有 .conf 文件
$ find /etc -name "*.conf" | head -10

# 2. 在你的 home 目录下找最近 3 天内修改过的文件
$ find ~ -mtime -3 -type f | head -10

# 3. 找出 home 下大于 1MB 的文件
$ find ~ -size +1M

# 4. 组合：/var/log 下 .log 结尾、且 7 天内修改过的文件
$ find /var/log -name "*.log" -mtime -7

# 5. 练习 -exec：找到所有 .txt 文件并显示行数
$ find ~/linux-lab -name "*.txt" -exec wc -l {} \;
```

---

## 2.6 磁盘空间：`df`、`du`、`lsblk`

### `df` — 磁盘还剩多少空间？

```bash
$ df -h
```
输出：
```text
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           391M  1.9M  389M   1% /run
/dev/sda3        25G   12G   12G  50% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
/dev/sda2       974M  282M  625M  32% /boot
```

| 列 | 含义 |
|:---|:---|
| Filesystem | 分区/设备名 |
| Size | 总大小 |
| Used | 用了多少 |
| Avail | 还剩多少 |
| Use% | 使用百分比 |
| Mounted on | 挂载在哪 |

`-h` 的意思是 "human-readable"——用 K/M/G 显示而不是显示长数字。

### `du` — 哪个目录占了最多空间？

```bash
# 当前目录的总大小
$ du -sh .

# 当前目录下，每个子目录各占多少
$ du -h --max-depth=1 . | sort -h
```
输出：
```text
4.0K    ./Desktop
12K     ./Documents
1.2G    ./Downloads       ← 这里最占空间
8.0K    ./Music
16K     ./Pictures
```

> [!tip] 磁盘清理的思路
> ```bash
> # 1. 先看哪个分区快满了
> $ df -h
> 
> # 2. 进那个分区，从根开始看哪些目录最占空间
> $ cd /
> $ sudo du -h --max-depth=1 . | sort -h
> 
> # 3. 一级一级往下钻，直到找到罪魁祸首
> $ sudo du -h --max-depth=1 /var | sort -h
> $ sudo du -h --max-depth=1 /var/log | sort -h
> ```

### `lsblk` — 看看有哪些磁盘/分区

```bash
$ lsblk
```
输出：
```text
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   30G  0 disk
├─sda1   8:1    0    1M  0 part
├─sda2   8:2    0    1G  0 part /boot
└─sda3   8:3    0   29G  0 part /
sr0     11:0    1 1024M  0 rom
```

- `sda` = 第一块硬盘
- `sda1`、`sda2`、`sda3` = 分区
- 注意 `MOUNTPOINTS` 列——`/` 挂在 `sda3` 上，`/boot` 挂在 `sda2` 上

---

## 🧪 本章综合练习

> [!example] 在虚拟机终端完成

1. 在 `~/linux-lab/temp/` 下创建 `chapter2/` 目录，在里面创建指向 `~/linux-lab/files/passwd.txt` 的**符号链接**，名叫 `link-to-passwd`
2. 用 `find` 在 `~/linux-lab/` 下找到所有 `.log` 文件
3. 用一条命令查看 `/etc` 目录下所有 `.conf` 文件的权限
4. 用 `du` 查看 `~/linux-lab/` 的总大小
5. 用 `stat` 查看 `~/linux-lab/files/hello.txt` 的 inode 号

---

## 📋 本章命令速查

| 命令 | 作用 | 关键选项 |
|:---|:---|:---|
| `ls -l` | 详细列表（含权限） | `-a` 隐藏文件, `-i` inode号 |
| `file` | 识别文件类型 | — |
| `chmod 755` | 数字法设权限 | `+x` 加执行, `-w` 去写 |
| `chown user:group` | 改所有者 | `-R` 递归 |
| `ln -s` | 创建符号链接 | 不加 `-s` = 硬链接 |
| `find /p -name "*.txt"` | 按名搜索 | `-type`, `-size`, `-mtime`, `-exec` |
| `locate` | 从数据库搜索 | （先 `sudo updatedb`） |
| `df -h` | 磁盘剩余空间 | — |
| `du -sh` | 目录总大小 | `--max-depth=1` 只看一级 |
| `lsblk` | 磁盘/分区列表 | — |
| `stat` | 文件详细信息 | — |
| `readlink` | 查看符号链接指向 | — |

---

> [!info] 继续学习
> - 速查表：[[02-file-system/cheatsheet|Chapter 02 Cheatsheet]]
> - 上一章：[[01-cli-basics/README|CLI 基础与 Shell 入门]]
> - 下一章：[[03-text-processing/README|文本处理三剑客]]
