# 01 — CLI 基础与 Shell 入门 / CLI Basics & Shell

> [!info] 本章目标
> 理解 Shell 是什么，掌握基本导航、文件操作、管道和重定向，学会自己查手册。这是所有后续章节的基础。

---

## 1.1 什么是 Shell？ / What is a Shell?

Shell 是用户与 Linux 内核之间的命令解释器。你输入文字命令，Shell 翻译给内核执行。

A shell is a command interpreter between you and the Linux kernel. You type text commands; the shell translates them for the kernel.

常见的 Shell：`bash`（默认）、`zsh`（增强版）、`fish`（友好版）、`sh`（POSIX 最小集）

```bash
# 查看你当前的 Shell
$ echo $SHELL

# 查看系统有哪些 Shell
$ cat /etc/shells
```

> [!note] 关键原则：一切皆文件
> 键盘、屏幕、磁盘、进程、网络连接在 Linux 中都以文件形式呈现。
>
> **Key principle: Everything is a file.** Keyboards, screens, disks, processes, network connections — all represented as files.

---

## 1.2 命令结构 / Command Anatomy

```text
command [-options] [arguments]
ls     -la       /home
```

| 部件 Part | 说明 Description | 示例 Example |
|-----------|-----------------|--------------|
| `command` | 要执行的程序 / program to run | `ls`, `cp`, `grep` |
| `options` | 以 `-` 或 `--` 开头 / starts with `-` or `--` | `-l`, `--help` |
| `arguments` | 命令操作的对象 / the target | `/home`, `file.txt` |

```bash
# 每个命令都有退出码：0 = 成功，非 0 = 失败
# Every command has an exit code: 0 = success, non-zero = failure
$ ls /nonexistent
$ echo $?     # 打印上一条命令的退出码
```

---

## 1.3 路径导航 / Path Navigation

```bash
pwd             # 打印当前工作目录 / print working directory
ls              # 列出目录内容 / list directory contents
ls -l           # 详细信息 / long format
ls -a           # 包括隐藏文件（以 . 开头）/ include hidden files
ls -lh          # 人类可读的文件大小 / human-readable sizes
cd /home        # 切换目录 / change directory
cd ~            # 回到 home 目录 / go to home
cd -            # 回到上次所在目录 / go to previous directory
cd ..           # 向上一级 / go up one level
```

### 绝对路径 vs 相对路径 / Absolute vs Relative Path

```bash
/home/user/docs/file.txt    # 绝对：从 / 开始 / starts from root
./docs/file.txt             # 相对：从当前目录开始 / starts from current dir
../docs/file.txt            # 相对：从上一级开始 / starts from parent dir
~/docs/file.txt             # 相对：从 home 开始 / starts from home
```

> [!tip] `~` 和 `.` 的区别
> - `~` = home 目录 / home directory
> - `.` = 当前目录 / current directory
> - `..` = 上一级 / parent directory
> - `-` = 上次所在的目录 / previous directory

---

## 1.4 文件操作基础 / File Operations Basics

### 创建 / Create

```bash
touch file.txt              # 创建空文件 / create empty file
mkdir mydir                 # 创建目录 / create directory
mkdir -p a/b/c              # 递归创建 / create nested directories
```

### 查看 / View

```bash
cat file.txt                # 输出全部内容 / print entire file
less file.txt               # 分页浏览（q 退出）/ page through (q to quit)
head -n 5 file.txt          # 前 5 行 / first 5 lines
tail -n 5 file.txt          # 后 5 行 / last 5 lines
tail -f file.txt            # 实时跟踪（Ctrl+C 退出）/ follow in real-time
```

### 复制、移动、删除 / Copy, Move, Remove

```bash
cp source.txt dest.txt      # 复制文件 / copy file
cp -r sourcedir/ destdir/   # 递归复制目录 / copy directory recursively
mv oldname newname          # 移动或重命名 / move or rename
rm file.txt                 # 删除文件 / remove file
rm -r dir/                  # 递归删除目录 / remove directory recursively
rmdir emptydir/             # 删除空目录 / remove empty directory only
```

> [!danger] `rm` 没有回收站！
> 删了就没了。删除前先用 `ls` 确认路径，养成好习惯。
>
> No recycle bin. Deletions are permanent. Always `ls` the path first to double-check.

---

## 1.5 获取帮助 / Getting Help

```bash
# man: 命令手册（最权威）/ the authoritative manual
man ls          # q 退出, / 搜索, n 下一个

# --help: 快速查看选项 / quick option reference
ls --help

# type: 查看命令类型 / check what a command actually is
type ls         # 输出: ls is aliased to `ls --color=auto`
type cd         # 输出: cd is a shell builtin

# which: 查找命令位置 / locate a command
which python3

# apropos: 搜索手册 / search man pages by keyword
apropos "list directory"
```

> [!tip] 遇到不懂的命令？
> `man <command>` 永远是你的第一选择。比 Google 快，比 ChatGPT 权威。

---

## 1.6 Shell 快捷键 / Shell Shortcuts

| 组合键 Combo | 作用 Action |
|-------------|-------------|
| `Ctrl+A` | 跳到行首 / jump to line start |
| `Ctrl+E` | 跳到行尾 / jump to line end |
| `Ctrl+U` | 删除光标前所有内容 / delete from cursor to start |
| `Ctrl+K` | 删除光标后所有内容 / delete from cursor to end |
| `Ctrl+W` | 删除前一个单词 / delete previous word |
| `Ctrl+R` | 搜索命令历史 / search command history |
| `Ctrl+L` | 清屏 / clear screen |
| `Ctrl+C` | 终止当前命令 / kill current command |
| `Ctrl+D` | EOF（退出 shell）/ send EOF (exit shell) |
| `↑` / `↓` | 浏览命令历史 / browse history |
| `!!` | 重复上一条命令 / repeat last command |
| `!$` | 上一条命令的最后一个参数 / last arg of previous command |

> [!tip] 最值得记住的三个
> `Ctrl+R` 搜索历史、`Ctrl+A/E` 跳转行首行尾、`Ctrl+C` 终止命令。这三个每天用几十次。

---

## 1.7 重定向与管道 / Redirection & Pipes

### 重定向 / Redirection

```bash
echo "hello" > file.txt     # 覆盖写入 / overwrite
echo "world" >> file.txt    # 追加写入 / append
ls /nonexistent 2>/dev/null # 丢弃错误信息 / discard errors
command > out.txt 2>&1      # stdout 和 stderr 都写到一个文件
```

| 符号 | 含义 |
|:----|:----|
| `>` | 覆盖写入 / overwrite |
| `>>` | 追加写入 / append |
| `2>` | 重定向 stderr |
| `2>&1` | stderr 合并到 stdout |
| `/dev/null` | 黑洞，数据丢进去就没了 / data goes in, never comes out |

### 管道 / Pipes

管道把左边命令的输出变成右边命令的输入。Pipe: left output → right input.

```bash
# 经典示例 / Classic examples
cat /var/log/syslog | grep error | head -n 10
ls -l | sort -k5 -n          # 按第 5 列（文件大小）数字排序
ps aux | grep nginx          # 查找特定进程
```

> [!note] Do One Thing Well
> Linux 命令遵循 "做一件事并做好" 的哲学。每个命令只做一件事，用管道组合起来完成复杂任务。
>
> Each command does one thing well. Combine them with pipes for complex tasks.

---

## 🧪 练习 / Exercises

> [!example] 在虚拟机终端完成以下练习
> 进入 `exercises/` 目录，运行 `bash check.sh` 验证你的答案。
> 参考答案见 `exercises/solutions/`。

1. 在 `$HOME/linux-lab/temp/` 下创建目录 `chapter1/test/`
2. 用**一条命令**创建文件 `a.txt`、`b.txt`、`c.txt`
3. 将 `$HOME/linux-lab/files/fruits.txt` 中所有包含 "apple" 的行提取到新文件
4. 用 `tail` 查看 `fruits.txt` 的**前** 3 行（提示：不能用 `head`）
5. 查看 `ls` 命令的手册页，找到 `-S` 选项的作用

---

> [!info] 相关资源
> - 速查表 / Cheatsheet: [[01-cli-basics/cheatsheet|Chapter 01 Cheatsheet]]
> - 下一章 / Next: [[02-file-system/README|文件系统与路径]]
