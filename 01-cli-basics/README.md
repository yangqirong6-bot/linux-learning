# 01 — CLI 基础与 Shell 入门

> [!info] 本章目标
> 学完这一章，你将能够：在终端中自由导航目录、创建/查看/删除文件、组合多条命令做更复杂的事、在遇到不懂的命令时自己查手册。
>
> **预计时间**：1-2 小时（边看边敲）

---

## 1.0 准备工作：打开终端

在 Ubuntu 桌面上，按 `Ctrl+Alt+T` 打开终端。你会看到类似这样的黑底白字窗口：

```text
yang@ubuntu:~$
```

这行字叫**命令提示符（prompt）**，意思是：系统已经准备好接收你的命令了。
￥
拆开来看：

| 部分 | 含义 |
|:---|:----|
| `yang` | 当前用户名 / your username |
| `@` | "在（at）" |
| `ubuntu` | 这台电脑的主机名 / hostname |
| `:` | 分隔符 |
| `~` | 当前所在目录（`~` = home 目录） |
| `$` | 你是普通用户（`#` 表示 root 管理员） |

> [!tip] 从现在开始
> 本书中的 `$` 表示命令提示符，**你不需要输入 `$` 本身**。比如：
> ```bash
> $ whoami
> ```
> 你需要输入的是 `whoami`，不是 `$ whoami`。

### 立刻试试
输入
```bash
whoami
```
输出（Output）:
```text
yang
```
![[Pasted image 20260602170656.png]]
输入
```bash
hostname
```
输出（Output）:
```text
ubuntu
```
![[Pasted image 20260602170743.png]]
---

## 1.1 什么是 Shell？为什么你需要学它？

### 类比

| GUI（图形界面） | CLI（命令行） |
|:---|:---|
| 鼠标双击文件夹 | `cd /home/yang/Documents` |
| 右键 → 新建文件夹 | `mkdir newfolder` |
| 拖拽文件到回收站 | `rm file.txt` |
| 用文件管理器搜索 | `find / -name "*.txt"` |

GUI 方便直观，但 CLI 有三个 GUI 无法替代的优势：

1. **自动化**：你可以把 100 个命令写进脚本，一键执行
2. **远程管理**：SSH 登录服务器，服务器没有桌面，只有终端
3. **精确控制**：`find / -name "*.log" -mtime -7 -size +10M -exec gzip {} \;` 这种复杂条件，GUI 做不到

> [!note] Shell vs Terminal vs Console
> - **Terminal（终端）**：你看到的那个黑底白字的窗口
> - **Shell**：在终端内部运行的命令解释器，负责接收你的命令并执行
> - **Bash**：最常见的 Shell，Ubuntu 默认用它
> - 简单理解：Terminal 是容器，Shell 是里面的引擎

### 确认你用的是哪种 Shell

```bash
$ echo $SHELL
```
输出：
```text
/bin/bash
```

> [!tip] `echo` 是什么？
> `echo` 是"把后面的内容显示出来"的命令。`$SHELL` 是一个**环境变量**，存着当前 Shell 的路径。`echo $SHELL` 就是"告诉我当前 shell 在哪"。
我们可以把它拆开来详细理解：

- **`/`（根目录）**：这是 Linux 或 macOS 等类 Unix 操作系统中最高层级的目录，相当于整个系统的起点（类似于 Windows 里的 `C:\`）。
    
- **`bin`（二进制文件目录）**：`bin` 是 "binary"（二进制）的缩写。这个文件夹里专门用来存放系统运行所必需的、最基础的命令和可执行程序。
    
- **`bash`（具体的程序名）**：全称是 "Bourne Again SHell"。它是目前最流行、也是很多系统默认的 Shell 程序。它的作用就是作为你和计算机内核之间的“翻译官”——接收你输入的命令，然后翻译给底层系统去执行。
---

## 1.2 命令的结构：所有命令都是这个套路

Linux 命令几乎都遵循同一个语法：

```text
命令名 [选项] [参数]
command [-options] [argument]
```

用 `ls` 来举例——`ls` 是"list"的缩写，作用是列出目录里的文件：

```bash
$ ls
```
输出（你的可能不一样）：
```text
Desktop  Documents  Downloads  Music  Pictures  Videos
```

这是最简单的用法，没加任何选项和参数。

### 加选项：改变命令的行为

```bash
$ ls -l
```
输出：
```text
drwxr-xr-x 2 yang yang 4096 Jan 15 14:23 Desktop
drwxr-xr-x 2 yang yang 4096 Jan 15 14:23 Documents
```

`-l` 选项告诉 `ls`："别只给我看名字，给我**详细信息**"。**`l` = long**。

```bash
$ ls -a
```
输出：
```text
.  ..  .bashrc  .config  Desktop  .local  Documents
```

`-a` 选项 = "all"，把以 `.` 开头的隐藏文件也显示出来。

### 选项可以合并

```bash
$ ls -la        # 等于 ls -l -a ：详细信息 + 包含隐藏文件
$ ls -lh        # 等于 ls -l -h ：详细信息 + 文件大小用人类可读的格式（K/M/G）
```

> [!tip] 短选项 vs 长选项
> - 短选项：`-l`、`-a`（一个杠 + 一个字母）
> - 长选项：`--help`、`--version`（两个杠 + 完整单词）
> - 大部分命令两种都支持，含义一样

### 加参数：告诉命令操作什么

```bash
$ ls /home          # 列出 /home 目录的内容，而不是当前目录
$ ls -l /etc/ssh    # 以详细信息列出 /etc/ssh 的内容
```
/  <-- 这就是根目录，也就是全系统的“最高目录”
├── bin   (存放基础系统命令的地方，比如 bash、ls、echo)
├── home  (所有普通用户的“家”的集中地，你之前看到的 /home 就在这里)
│   ├── yang  <-- 这是你的主目录，也就是提示符里的 '~'
│   └── alice (另一个用户的主目录)
├── etc   (存放系统配置文件的文件夹)
├── usr   (存放用户安装的软件和程序)
└── ...   (还有很多其他系统文件夹)
### 命令一定有返回值

每个命令执行完都会返回一个数字，叫**退出码（exit code）**：
- **0** = 成功
- **非 0** = 出错了（不同数字代表不同错误）

```bash
$ ls /home
# 成功，返回 0

$ ls /nonexistent
```
输出：
![[Pasted image 20260602202454.png]]
```text
ls: cannot access '/nonexistent': No such file or directory
```

```bash
$ echo $?
```
输出：
```text
2
```

`echo $?` 显示上一条命令的退出码。`2` 表示"文件不存在"。
![[Pasted image 20260602202518.png]]
> [!warning] 常见错误
> 新手最容易犯的错误就是**拼写错误**。Linux 是大小写敏感的：`Desktop` 和 `desktop` 是两个不同的文件。
> ```bash
> $ ls desktop     # ❌ 找不到（除非你真的有个叫 desktop 的目录）
> $ ls Desktop     # ✅
> ```

---

## 1.3 你在哪？文件系统导航

### 你当前的位置：`pwd`

```bash
$ pwd
```
输出：
```text
/home/yang
```

`pwd` = Print Working Directory（打印当前工作目录）。在终端里**你永远在一个"位置"**，跟文件管理器里你有"当前打开的文件夹"是一个道理。

### Linux 目录树是什么样？

跟 Windows 的 `C:\`、`D:\` 多个盘不同，Linux 只有一棵树，根是 `/`：

```text
/                          ← 根目录（一切从这里开始）
├── bin/                   ← 基础命令（ls, cp, cat 都在这里）
├── etc/                   ← 所有配置文件
├── home/
│   └── yang/              ← 你的家目录（~ 指向这里）
│       ├── Desktop/
│       ├── Documents/
│       └── Downloads/
├── tmp/                   ← 临时文件，重启就清空
├── var/
│   └── log/               ← 系统日志
└── usr/
    ├── bin/               ← 更多用户命令
    └── lib/               ← 程序库
```

> [!tip] 和 Windows 对比
> | Windows | Linux |
> |:---|:---|
> | `C:\Users\yang\Desktop` | `/home/yang/Desktop` |
> | `C:\Windows\System32` | `/usr/bin` |
> | `C:\Program Files` | `/usr/local` 或 `/opt` |
> | 反斜杠 `\` | 正斜杠 `/` |

### 移动位置：`cd`

```bash
$ cd /               # 去根目录
$ pwd
# /home

$ cd ~               # 回家目录（~ 是 /home/yang 的简写）
$ pwd
# /home/yang

$ cd Desktop         # 进入当前目录下的 Desktop 文件夹
$ pwd
# /home/yang/Desktop

$ cd ..              # 返回上一级
$ pwd
# /home/yang

$ cd -               # 回到上次在的地方（在 / 和 ~ 之间来回切换）
# /home/yang/Desktop
```

> [!tip] 路径的四种写法
> 假设你在 `/home/yang`：
>
> | 写法 | 含义 | 解析结果 |
> |:---|:---|:---|
> | `cd /home/yang/Documents` | 绝对路径：从 `/` 出发 | `/home/yang/Documents` |
> | `cd Documents` | 相对路径：从当前目录出发 | `/home/yang/Documents` |
> | `cd ./Documents` | 同上，`.` 表示当前目录 | `/home/yang/Documents` |
> | `cd ../yang/Documents` | `..` 表示上一级，再回来 | `/home/yang/Documents` |
>
> **什么时候用绝对路径，什么时候用相对路径？**
> - 绝对路径：在脚本里、不确定自己在哪时
> - 相对路径：日常操作，更短更方便

### 看看周围有什么：`ls`

```bash
$ ls                # 列出当前目录的文件和文件夹
$ ls /etc           # 列出 /etc 下的内容
$ ls -l             # 详细列表（long format）
$ ls -a             # 包含隐藏文件（以 . 开头）
$ ls -lh            # 详细列表 + 人类可读的文件大小
$ ls -ltr           # 详细列表 + 按时间排序（最新的在最下面）
```

> [!tip] 怎样理解 `ls -l` 的输出？
> ```text
> -rw-r--r-- 1 yang yang  220 Jan 15 14:23 .bashrc
> drwxr-xr-x 2 yang yang 4096 Jan 15 14:23 Desktop
> ```
>
> | 列 | 含义 |
> |:---|:---|
> | `-rw-r--r--` | 类型 + 权限（后面章节讲） |
> | `1` | 硬链接数 |
> | `yang yang` | 所有者 + 所属组 |
> | `220` | 文件大小（字节） |
> | `Jan 15 14:23` | 最后修改时间 |
> | `.bashrc` | 文件名 |
## 🧩 常用核心参数拆解

理解了单个参数的含义，就能自由组合出适合各种场景的命令：

- `-l` (**L**ong format)：长格式。显示文件的详细属性（权限、所有者、大小、修改时间等）。
    
- `-a` (**A**ll)：全部。显示所有文件，包括以 `.` 开头的**隐藏文件**。
    
- `-h` (**H**uman-readable)：人类可读。将文件大小从难懂的字节（Bytes）智能换算成 `K`, `M`, `G`。_（通常配合 `-l` 使用）_
    
- `-t` (**T**ime)：按修改时间排序。默认是最新的在最上面。
    
- `-r` (**R**everse)：反向排序。_（通常配合 `-t` 使用，把最新的放到最下面）_
    

## 🚀 4个最高频的实战组合

### 1. `ls -l`：查看文件详细档案

- **作用**：以列表形式展示当前目录下所有非隐藏文件的详细信息。
    
- **痛点**：文件大小默认显示为纯字节数，大文件难以一眼估算。
    
- **输出示例**：`-rw-r--r-- 1 yang yang 1048576 6月 2 10:00 data.csv`
    

### 2. `ls -a`：显示所有文件（含隐藏文件）

- **作用**：列出当前目录下的所有内容，让系统配置文件等“隐身”文件现形。
    
- **注意**：Linux 中只要文件名以 `.` 开头（如 `.bashrc`），默认就会被系统隐藏。
    
- **输出示例**：`. .. .bash_history data.csv`
    

### 3. `ls -lh`：排查磁盘空间的利器

- **作用**：在详细列表的基础上，把文件大小换算成人类最容易看懂的单位（KB, MB, GB）。
    
- **输出示例**：`-rw-r--r-- 1 yang yang 1.0M 6月 2 10:00 data.csv`
    

### 4. `ls -ltr`：排错与找文件的终极神器

- **作用**：按时间**倒序**排列详细列表，确保**最新修改的文件永远在屏幕的最底端**。
    
- **场景**：当文件夹里有成百上千个文件时，刚生成的日志或刚下载的文件会直接显示在你输入下一次命令的上方，不用往上翻页去找。
![[Pasted image 20260602205428.png]]
### 🧪 即时练习

在终端里操作以下内容，感受导航：

```bash
# 1. 看看自己在哪
$ pwd

# 2. 去根目录，看看整个系统长什么样
$ cd /
$ ls

# 3. 去看配置文件目录
$ cd /etc
$ ls -l          # 翻看，是不是很多 .conf 结尾的文件？

# 4. 回家
$ cd ~

# 5. 看看家里有什么隐藏文件（以 . 开头的）
$ ls -a
```

---

## 1.4 文件操作：增删改查

### 创建文件：`touch`

`touch` 最常用的情况是**创建一个空文件**：

```bash
$ touch myfile.txt
$ ls -l myfile.txt
```
输出：
```text
-rw-r--r-- 1 yang yang 0 Jan 15 15:00 myfile.txt
```

注意文件大小是 `0`——`touch` 创建的是真正空的文件。
![[Pasted image 20260602205713.png]]

> [!note] `touch` 名字的由来
> 如果文件已经存在，`touch` 会更新它的"最后修改时间"而不改变内容——就像"碰了一下"。但对新手来说，记住"创建空文件"就够了。

### 创建目录：`mkdir`

```bash
$ mkdir myproject                    # 创建一个目录
$ ls -l | grep myproject   #grep是一个文本搜索员
```
- 📦 **原料库 (`ls -l`)** ➡️ 输送带 (`|`) ➡️ 🔍 **质检员 (`grep`)** ➡️ 最终产品
   - `ls -l`- 它对着当前目录“咔嚓”拍了一张照，然后把照片上的内容转换成了**纯文本报告**。
       
   - **管道符 `|` 就像一根水管**：它把这份纯文本报告变成了一股“字符水流”，接进了下一个机器里。
    
   - **`grep myproject` 就像一个只会过滤形状的滤网**：它张开大嘴，接收着流进来的这股字符水流。它的任务极其机械且死板——不管流过来的是什么，只要这一行里面有个字母 `myproject`，就放它过去；如果没有，就拦截掉。
- `grep` 的标准工作格式是这样的：> **`grep [你要找的关键词] [你要在哪个文件里找]`**
```text
drwxr-xr-x 2 yang yang 4096 Jan 15 15:05 myproject
```
注意行首是 `d`，表示这是个目录（directory）。
![[Pasted image 20260602210250.png]]

```bash
$ mkdir -p a/b/c/d                   # 一口气创建嵌套目录
```

`-p` 的意思是 "parents"：如果父目录不存在就自动创建。不加 `-p` 的话：

```bash
$ mkdir x/y/z
```
输出：
```text
mkdir: cannot create directory 'x/y/z': No such file or directory
```

> [!warning] 目录名不要有空格
> `my project` 会出问题，因为 Shell 会把空格当成分隔符。用 `my_project` 或 `my-project` 代替。
> 本章只讲基础，空格的处理后面 Shell 脚本那章会详细讲。

### 查看文件内容

#### `cat` — 一口气全部显示（适合短文件）

```bash
$ cat /etc/hostname
```
输出：
```text
ubuntu
```
![[Pasted image 20260602212530.png]]

#### `less` — 分页浏览（适合长文件）

```bash
$ less /etc/ssh/sshd_config
```

在 `less` 里：
> [!info] ⌨️ 终端阅读快捷键指南 (less / man)
> 
> | 按键 | 作用 |
> | :--- | :--- |
> | `↑` `↓` 或 `j` `k` | 上下滚动 |
> | `Space` (空格键) | 向下翻一页 |
> | `b` | 向上翻一页 |
> | `/` | 搜索（输入关键词，按回车） |
> | `n` | 跳转到下一个搜索结果 |
> | `q` | 退出 |

> [!tip] cat vs less
> - `cat` = 如果文件只有十几行，用 cat 方便
> - `less` = 文件可能很长（大多数配置文件），用 less
> - 如果用 `cat` 打开了一个很长的文件导致疯狂滚动，按 `Ctrl+C` 停下来

#### `head` 和 `tail` — 只看头或尾

```bash
$ head -n 3 /etc/passwd             # 前 3 行
$ tail -n 5 /var/log/syslog         # 最后 5 行
$ tail -f /var/log/syslog           # 实时跟踪（有新内容就立刻显示）
```

`tail -f` 是运维最常用的命令之一——盯着日志看。`Ctrl+C` 退出。
> [!tip] ✂️ 文本查看命令：掐头与去尾 (head / tail)
> 
> 当文件包含几万行数据时，我们通常不需要全部打开，只需查看局部即可。
> 
> | 命令格式 | 核心作用 | 典型应用场景 |
> | :--- | :--- | :--- |
> | `head -n 10 文件名` | 查看前 10 行 | 快速预览大文件格式、查看数据表头 (CSV) |
> | `tail -n 10 文件名` | 查看最后 10 行 | 查看日志文件里最新发生的报错记录 |
> | `tail -f 文件名` | 🔴 **实时滚动监控** | 像“直播”一样盯着服务器日志，看实时运行状态 |
> 
> **⚠️ 避坑提醒**：执行 `tail -f` 后终端会处于持续挂起状态，必须使用 `Ctrl + C` 强制中断才能退出！

### 复制、移动、删除
#### 1. 复制
```bash
# 复制
$ cp myfile.txt backup.txt           # 复制文件
$ cp -r myproject/ myproject_backup/ # 递归复制整个目录
```
我们假设你目前的 `myproject` 文件夹里有这样的结构（就像一棵树）：

- **复制前（数据源）：**
```
myproject/
├── data.csv            # 你的原始数据文件
├── script.py           # 你的 Python 代码
└── results/            # 这是一个子文件夹！
    └── output.txt      # 子文件夹里的输出结果
```

此时，你在终端里敲下这行命令并回车：
```
cp -r myproject/ myproject_backup/
```

- **复制后（瞬间克隆）：** 系统会在当前目录下瞬间生成一个名为 `myproject_backup` 的全新文件夹。它里面的结构与原版**分毫不差**：

```
myproject_backup/       <-- 新建的备份文件夹
├── data.csv            <-- 克隆的文件
├── script.py           <-- 克隆的文件
└── results/            <-- 连同子文件夹一起克隆
    └── output.txt      <-- 子文件夹里的文件也被克隆了
```
#### 2. 移动
```
# 移动/重命名（mv 既是 "move" 也是 "rename"）
$ mv myfile.txt newname.txt          # 重命名
$ mv myfile.txt ~/Documents/         # 移动到 Documents
```
#### 3. 删除
- 删空文件夹：用 `rmdir` (最安全)。
    
- 删普通文件：用 `rm`。
    
- 删有东西的文件夹：用 `rm -r`。
    
- 需要谨慎对待的强力清空工具：`rm -rf`。
```
# 删除
$ rm backup.txt                      # 删除一个文件
$ rm -r myproject_backup/            # 递归删除目录及其所有内容
$ rmdir emptydir                     # 只能删空目录
```

> [!danger] `rm` 没有回收站，没有确认提示，删了就没了！
> 安全习惯：
> 1. 删除前先 `ls` 确认路径是对的
> 2. 不确定时先 `ls` 替代 `rm`，比如 `ls -r yang/` 先看看会删掉什么
> 3. 重要文件删之前先 `cp` 备份一份

### 🧪 即时练习

```bash
# 在 home 目录下做以下练习：
$ cd ~

# 1. 创建一个叫 test_area 的目录，进去
$ mkdir test_area
$ cd test_area

# 2. 创建三个文件
$ touch a.txt b.txt c.txt

# 3. 查看文件
$ ls -l

# 4. 把 a.txt 改名为 first.txt
$ mv a.txt first.txt

# 5. 删除 b.txt
$ rm b.txt

# 6. 回到 home 目录，删掉整个 test_area
$ cd ..
$ rm -r test_area
```

---

## 1.5 遇到问题怎么办？自己查手册

Linux 自带完整文档，不需要上网搜。

### `man` — 最权威的手册

```bash
$ man ls
```

在手册里：
> [!tip] ⌨️ 基础阅读快捷键
> 
> | 按键 | 作用 |
> | :--- | :--- |
> | `↑` `↓` | 上下滚动 |
> | `/` | 搜索关键词 |
> | `n` | 下一个搜索结果 |
> | `q` | 退出 |

手册的结构（几乎每个命令都是这个格式）：

| 章节              | 内容               |
| :-------------- | :--------------- |
| NAME            | 命令名和一句话说明        |
| SYNOPSIS        | 语法格式             |
| **DESCRIPTION** | **详细说明（最重要的部分）** |
| OPTIONS         | 每个选项的含义          |

> [!tip] man 里看选项最快的方法
> 打开 man 后，按 `/` 然后输入 `-S`（你想查的选项），回车。按 `n` 跳到下一个匹配。

### `--help` — 快速参考

不想进 man 慢慢翻？直接问命令本身：

```bash
$ ls --help
```
输出（只显示了前几行）：
```text
Usage: ls [OPTION]... [FILE]...
List information about the FILEs (the current directory by default).

Mandatory arguments to long options are mandatory for short options too.
  -a, --all                  do not ignore entries starting with .
  -l                         use a long listing format
  -h, --human-readable       with -l and -s, print sizes like 1K 234M 2G
```

### `whatis` — 一句话说明

```bash
$ whatis ls
```
输出：
```text
ls (1)               - list directory contents
```

### `apropos` — 忘了命令名？搜关键词

```bash
$ apropos "list directory"
```
输出：
```text
dir (1)              - list directory contents
ls (1)               - list directory contents
ntfsls (8)           - list directory contents on an NTFS filesystem
vdir (1)             - list directory contents
```
(1)：代表“常规用户命令”（User Commands）。这是任何普通登录账户都可以随意使用的基础工具（如 ls）。

(8)：代表“系统管理命令”（System Administration Commands）。这类命令通常涉及底层系统操作，往往需要 root 管理员权限才能完整执行（如截图中的 ntfsls，专门用于读取 NTFS 格式的底层文件系统）。
### 🧪 即时练习

```bash
# 1. 用 man 查看 cp 命令，找出 -i 选项是干什么的
$ man cp
# (按 / 然后输入 -i, 回车)

# 2. 用 --help 快速查看 grep 有哪些选项
$ grep --help

# 3. 用 whatis 看看 mkdir 是什么
$ whatis mkdir

# 4. 忘了"切换目录"的命令？用 apropos 搜
$ apropos "change directory"
```

---

## 1.6 让你的效率翻倍：Shell 快捷键

> [!note] 为什么学快捷键？
> 这些快捷键一旦形成肌肉记忆，你在终端里的速度会远超鼠标操作。**先记住前 5 个**，其他的慢慢来。

### 必须记住的 5 个

| 快捷键 | 作用 | 什么时候用 |
|:---|:---|:---|
| `Ctrl+C` | **终止当前命令** | 命令卡住了、跑飞了、你打错了 |
| `Ctrl+R` | **搜索历史** | 之前敲过一条很长的命令，不想重新敲 |
| `Ctrl+L` | **清屏** | 屏幕太乱了，清理一下 |
| `Tab` | **自动补全** | 输入前几个字母，按 Tab 自动补全文件名/命令 |
| `↑` / `↓` | **历史命令** | 翻出上一条/下一条命令 |

### 进阶的 5 个

| 快捷键      | 作用            |
| :------- | :------------ |
| `Ctrl+A` | 跳到行首          |
| `Ctrl+E` | 跳到行尾          |
| `Ctrl+U` | 删除从光标到行首的所有内容 |
| `Ctrl+K` | 删除从光标到行尾的所有内容 |
| `Ctrl+W` | 删除光标前一个单词     |

### 试试 Tab 补全的威力

```bash
$ cd /e    # 按 Tab
$ cd /etc/ # 自动补全！

$ cd ~/Do  # 按 Tab（如果 Downloads 和 Documents 都存在）
$ cd ~/Do  # 按两下 Tab，显示所有匹配项
Downloads/  Documents/
```
**==`~/`  是绝对路径，是去根目录下面找==**
> [!tip] 🪄 程序员的效率魔法：Tab 键自动补全
> 
> 在 Linux 终端中输入文件路径、命令名称时，永远不要逐个字母敲完，要养成**随时按 Tab 键**的肌肉记忆。
> 
> **Tab 键的运行逻辑：**
> * **按 1 下 Tab**：
>   * **唯一匹配**：系统瞬间帮你补全剩下的所有字母。
>   * **遇阻（存在多个匹配项）**：系统只会补全到多个选项的“公共前缀”部分，然后光标停住。
> * **连按 2 下 Tab**：
>   * **查看候选项**：当按 1 下没反应时，连按 2 下可以强制终端列出当前所有符合条件的可选列表。
> 
> **实战技巧：解决冲突**
> 遇到按 Tab 无法补全时，连按两下查看列表 -> 手动多打 1~2 个字母加以区分 -> 再次按 Tab 瞬间补全！
---

## 1.7 管道的威力：把命令串起来

这是 Linux 最核心的思想：**每个命令只做一件事，用管道把多个命令串起来完成复杂任务。**

### 重定向：把输出存起来

正常情况，命令的结果显示在屏幕上：

```bash
$ echo "Hello Linux"
```
输出：
```text
Hello Linux
```

用 `>` 把它**写到文件里**而不是屏幕上：

```bash
$ echo "Hello Linux" > greeting.txt
$ cat greeting.txt
```
输出：
```text
Hello Linux
```

`>`【覆盖写入】 和 `>>` 【追加写入】的区别：

```bash
$ echo "line 1" > file.txt       # 覆盖写入（之前的全部清掉）
$ echo "line 2" >> file.txt      # 追加写入（加在末尾）
$ cat file.txt
```
输出：
```text
line 1
line 2
```

### stdout 和 stderr：有两根输出管道

Linux 每个程序有两根输出管：

| 名称     | 编号  | 用途   |
| :----- | :-- | :--- |
| stdout | 1   | 正常输出 |
| stderr | 2   | 错误信息 |
#### 1. 默认状态（管道指向屏幕）
```bash
$ ls /home        # 正常，输出到 stdout
$ ls /nonexistent # 报错，输出到 stderr
```
- **逻辑拆解**：
    
    - 查询 `/home`（存在），机器产生正常的目录列表，通过 **1 号管**流出，显示在屏幕上。
        
    - 查询 `/nonexistent`（不存在），机器产生报错信息，通过 **2 号管**流出，同样显示在屏幕上。
        
- **核心现象**：虽然在屏幕上看起来都是文字，但它们在系统内部走的是完全不同的通道
#### 2. 仅重定向正常输出（单管截流）

```bash
$ ls /home /nonexistent > out.txt        # stdout 进文件，stderr 仍显示在屏幕
```
输出（屏幕）：
```text
ls: cannot access '/nonexistent': No such file or directory
```
- **逻辑拆解**：这行命令同时查询了一个存在的目录和一个不存在的目录，因此机器会同时产生正常结果和报错信息。
    
    - 符号 `>` 在 Linux 中实际上是 **`1>`** 的隐式简写。
        
    - 这表示强行将 **1 号管**的出口从屏幕拔下，接到了 `out.txt` 这个文件里。
        
- **最终结果**：
    
    - `/home` 的正常结果（走 1 号管）被安静地写入了 `out.txt`。
        
    - 报错信息（走 2 号管）因为没有被重定向，依然遵循默认规则，被直接喷洒在了终端屏幕上（`ls: cannot access...`）。
#### 3. 合并数据流（双管合一）
```bash
$ ls /home /nonexistent > out.txt 2>&1   # stdout 和 stderr 都进文件
$ cat out.txt
```
输出：
```text
ls: cannot access '/nonexistent': No such file or directory
/home:
yang
```
- **逻辑拆解**：这是 Linux 环境中最经典的日志收集命令，分两步执行：
    
    1. `> out.txt`：首先将 1 号管接入文件。
        
    2. **`2>&1`**：这是最核心的魔法指令。它的字面含义是“将 2 号管的出口，重定向到 1 号管当前所指向的目标”。
        
- **最终结果**：两根管道完成了“合流”，共同通向 `out.txt`。此时执行命令，终端屏幕会保持绝对的安静（没有任何输出）。查看文件内容时，会发现报错信息和正常结果被混合记录在了同一个文件中。
#### 4. 丢弃报错信息（引入黑洞）
```bash
$ ls /nonexistent 2>/dev/null            # stderr 丢进黑洞（不显示也不保存）
```
- **逻辑拆解**：
    
    - `2>` 明确指定只操作 2 号管（报错信息）。
        
    - `/dev/null` 相当于 Linux 系统中的“宇宙黑洞”。任何被重定向到这里的数据都会被系统瞬间丢弃，既不会显示在屏幕上，也不会占用任何磁盘空间。
        
- **最终结果**：所有报错信息被精准拦截并销毁。
    
- **高频应用场景**：在全盘搜索文件（如使用 `find` 命令）时，系统往往会抛出大量 `Permission denied`（权限拒绝）的报错，严重干扰视线。加上 `2>/dev/null` 后，屏幕上就只会留下干净的、真正搜索到的文件路径。

> [!tip] 🚰 Linux 数据流与重定向 (stdout / stderr)
> 
> Linux 中每个程序都有两根输出管：**`stdout` (1号，正常信息)** 和 **`stderr` (2号，报错信息)**。默认它们都会输出到终端屏幕。
> 
> | 常用重定向符 | 核心作用 | 适用场景 |
> | :--- | :--- | :--- |
> | `> 文件名` | 仅将**正常输出 (1号)** 保存到文件 | 保存程序运行结果，屏幕依然会显示报错 |
> | `2> 文件名` | 仅将**报错信息 (2号)** 保存到文件 | 专门收集错误日志用于排查排错 |
> | `> 文件名 2>&1` | 将报错并入正常管，**全部**保存到文件 | 记录完整的运行日志，屏幕保持绝对安静 |
> | `2> /dev/null` | 将报错信息扔进**“黑洞”**销毁 | 搜索/执行大任务时，屏蔽满屏的烦人报错 |
> 
> **💡 黄金记忆法则：**
> `>` 默认就是 `1>` 的简写。`2>&1` 的核心逻辑是“把 2 指向 1 当前所指向的终点”。
### 管道 `|`：左边的输出 → 右边的输入

```bash
# 正常 cat 把文件内容输出到屏幕
$ cat /etc/passwd

# 加管道：cat 的输出不再到屏幕，而是传给 grep 做过滤
$ cat /etc/passwd | grep yang #找出所有含yang的文本
```
输出：
```text
yang:x:1000:1000:Yang,,,:/home/yang:/bin/bash
```

你可以一直串下去：

```bash
# 看看最近谁登录了，只看涉及 yang 用户的，取前 5 条
$ last | grep yang | head -5
```

### 一个实际例子

```bash
# 问题：/var/log/ 下哪些文件最大？（按大小排序，最大的放最后）
$ ls -lh /var/log/ | sort -k5 -h
```

拆解：
- `ls -lh` → 列出文件名和大小
- `|` → 传给下个命令
- `sort -k5 -h` → 按第 5 列（文件大小）排序，`-h` 表示能理解 K/M/G 单位

### 🧪 即时练习

```bash
# 1. 把当前目录的文件列表保存到 mylist.txt
$ ls -l > mylist.txt
$ cat mylist.txt

# 2. 在 mylist.txt 末尾追加一行 "--- DONE ---"
$ echo "--- DONE ---" >> mylist.txt
$ cat mylist.txt

# 3. 用管道组合：列出 /etc 下的文件，只看包含 "ssh" 的
$ ls /etc | grep ssh
```

---

## 🧪 本章综合练习

> [!example] 在虚拟机终端完成
> 做完后运行 `bash check.sh` 验证答案。参考答案在 `exercises/solutions/`。

1. 在 `$HOME/linux-lab/temp/` 下创建 `chapter1/test/` 目录
2. 用**一条命令**同时创建 `a.txt`、`b.txt`、`c.txt` 三个文件
3. 将 `$HOME/linux-lab/files/fruits.txt` 中所有包含 "apple" 的行提取到新文件 `apple.txt`
4. 用 `tail` 命令查看 `fruits.txt` 的**前** 3 行（不能用 `head`）
原理拆解：
```
tac fruits.txt | tail -n 3 | tac
```
1. **`tac fruits.txt`**：`tac` 实际上就是反过来的 `cat`。它的作用是将文件的内容**倒序输出**（最后一行变成第一行）。这样一来，原文件最开始的 3 行就被“推”到了输出的最底部。
    
2. **`| tail -n 3`**：接着，我们用管道符 `|` 把倒序后的内容传给 `tail`。这时 `tail -n 3` 会顺理成章地截取最底部的 3 行（也就是原文件的前 3 行，只是目前顺序是颠倒的）。
    
3. **`| tac`**：最后，我们再用一次管道和 `tac`，把截取出来的这 3 行内容重新反转一次，恢复成它们原本正常的顺序（即：第 1 行、第 2 行、第 3 行）。
    
通过这种“负负得正”的方式，就能完美绕开 `head`，利用 `tail` 完成查看文件前几行的任务

5. 用 `man ls` 找到 `-S` 选项的作用，把说明保存到 `ls_S_option.txt`
```
man ls | grep -- '-s' > option.txt
```
![[Pasted image 20260603214000.png]]
> [!tip] 卡住了？
> 1. 先查手册：`man <命令>` 或 `<命令> --help`
> 2. 检查拼写：Linux 区分大小写
> 3. 确认位置：`pwd` 看看自己是不是在正确的目录里

---

## 📋 本章学到的命令速查

| 命令 | 作用 | 常用选项 |
|:---|:---|:---|
| `pwd` | 当前在哪 | — |
| `ls` | 列出文件 | `-l` 详细, `-a` 含隐藏, `-h` 人类可读 |
| `cd` | 切换目录 | `~` 家, `..` 上级, `-` 上次 |
| `touch` | 创建空文件 | — |
| `mkdir` | 创建目录 | `-p` 递归创建 |
| `cat` | 显示全部内容 | — |
| `less` | 分页浏览 | `/` 搜索, `q` 退出 |
| `head` / `tail` | 查看头/尾 | `-n` 行数, `tail -f` 实时跟踪 |
| `cp` | 复制 | `-r` 递归复制目录 |
| `mv` | 移动/重命名 | — |
| `rm` | 删除 | `-r` 递归删除 |
| `man` | 查看手册 | — |
| `echo` | 打印文字 | — |
| `>` | 覆盖重定向 | — |
| `>>` | 追加重定向 | — |
| `\|` | 管道（连接多个命令） | — |

---

> [!info] 继续学习
> - 速查表：[[01-cli-basics/cheatsheet|Chapter 01 Cheatsheet]]
> - 下一章：[[02-file-system/README|文件系统与路径 — 理解 Linux 的目录树、文件类型和权限]]
