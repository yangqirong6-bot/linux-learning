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

```bash
$ whoami
```
输出（Output）:
```text
yang
```

```bash
$ hostname
```
输出（Output）:
```text
ubuntu
```

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

`-l` 选项告诉 `ls`："别只给我看名字，给我**详细信息**"。`l` = long。

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

> [!note] `touch` 名字的由来
> 如果文件已经存在，`touch` 会更新它的"最后修改时间"而不改变内容——就像"碰了一下"。但对新手来说，记住"创建空文件"就够了。

### 创建目录：`mkdir`

```bash
$ mkdir myproject                    # 创建一个目录
$ ls -l | grep myproject
```

```text
drwxr-xr-x 2 yang yang 4096 Jan 15 15:05 myproject
```

注意行首是 `d`，表示这是个目录（directory）。

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

#### `less` — 分页浏览（适合长文件）

```bash
$ less /etc/ssh/sshd_config
```

在 `less` 里：
| 按键 | 作用 |
|:---|:---|
| `↑` `↓` 或 `j` `k` | 上下滚动 |
| `Space` | 向下翻一页 |
| `b` | 向上翻一页 |
| `/` | 搜索（输入关键词，按回车） |
| `n` | 下一个搜索结果 |
| `q` | 退出 |

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

### 复制、移动、删除

```bash
# 复制
$ cp myfile.txt backup.txt           # 复制文件
$ cp -r myproject/ myproject_backup/ # 递归复制整个目录

# 移动/重命名（mv 既是 "move" 也是 "rename"）
$ mv myfile.txt newname.txt          # 重命名
$ mv myfile.txt ~/Documents/         # 移动到 Documents

# 删除
$ rm backup.txt                      # 删除一个文件
$ rm -r myproject_backup/            # 递归删除目录及其所有内容
$ rmdir emptydir                     # 只能删空目录
```

> [!danger] `rm` 没有回收站，没有确认提示，删了就没了！
> 安全习惯：
> 1. 删除前先 `ls` 确认路径是对的
> 2. 不确定时先 `ls` 替代 `rm`，比如 `ls -r dir/` 先看看会删掉什么
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
| 按键 | 作用 |
|:---|:---|
| `↑` `↓` | 上下滚动 |
| `/` | 搜索关键词 |
| `n` | 下一个搜索结果 |
| `q` | 退出 |

手册的结构（几乎每个命令都是这个格式）：

| 章节 | 内容 |
|:---|:---|
| NAME | 命令名和一句话说明 |
| SYNOPSIS | 语法格式 |
| **DESCRIPTION** | **详细说明（最重要的部分）** |
| OPTIONS | 每个选项的含义 |

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
vdir (1)             - list directory contents
```

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

| 快捷键 | 作用 |
|:---|:---|
| `Ctrl+A` | 跳到行首 |
| `Ctrl+E` | 跳到行尾 |
| `Ctrl+U` | 删除从光标到行首的所有内容 |
| `Ctrl+K` | 删除从光标到行尾的所有内容 |
| `Ctrl+W` | 删除光标前一个单词 |

### 试试 Tab 补全的威力

```bash
$ cd /e    # 按 Tab
$ cd /etc/ # 自动补全！

$ cd ~/Do  # 按 Tab（如果 Downloads 和 Documents 都存在）
$ cd ~/Do  # 按两下 Tab，显示所有匹配项
Downloads/  Documents/
```

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

`>` 和 `>>` 的区别：

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

| 名称 | 编号 | 用途 |
|:---|:---|:---|
| stdout | 1 | 正常输出 |
| stderr | 2 | 错误信息 |

```bash
$ ls /home        # 正常，输出到 stdout
$ ls /nonexistent # 报错，输出到 stderr
```

你可以控制它们各去哪：

```bash
$ ls /home /nonexistent > out.txt        # stdout 进文件，stderr 仍显示在屏幕
```
输出（屏幕）：
```text
ls: cannot access '/nonexistent': No such file or directory
```

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

```bash
$ ls /nonexistent 2>/dev/null            # stderr 丢进黑洞（不显示也不保存）
```

### 管道 `|`：左边的输出 → 右边的输入

```bash
# 正常 cat 把文件内容输出到屏幕
$ cat /etc/passwd

# 加管道：cat 的输出不再到屏幕，而是传给 grep 做过滤
$ cat /etc/passwd | grep yang
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
5. 用 `man ls` 找到 `-S` 选项的作用，把说明保存到 `ls_S_option.txt`

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
