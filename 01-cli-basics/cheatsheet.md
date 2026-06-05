# 01 — CLI Basics 速查表 / Cheatsheet

## 导航 / Navigation
| 命令 | 说明 |
|------|------|
| `pwd` | 当前目录 / print working directory |
| `ls -la` | 详细列表含隐藏文件 / long list with hidden |
| `cd <dir>` | 切换目录 / change directory |
| `cd ~` | 回 home / go home |
| `cd -` | 回上次目录 / previous dir |

## 文件操作 / File Ops
| 命令                  | 说明                                 |     |
| ------------------- | ---------------------------------- | --- |
| `touch <file>`      | 创建空文件 / create empty               |     |
| `mkdir -p <a/b/c>`  | 递归建目录 / nested mkdir               |     |
| `cp -r <src> <dst>` | 递归复制 / copy recursively            |     |
| `mv <src> <dst>`    | 移动/重命名 / move or rename            |     |
| `rm <file>`         | 删除**文件**（不可恢复）/ delete (permanent) |     |
| `rm -r <dir>`       | 递归删除 / recursive delete            |     |

## 查看文件 / Viewing
| 命令                 | 说明                    |
| ------------------ | --------------------- |
| `cat <file>`       | 输出全部 / print all      |
| `less <file>`      | 分页 / page through     |
| `head -n N <file>` | 前 N 行 / first N lines |
| `tail -n N <file>` | 后 N 行 / last N lines  |
| `tail -f <file>`   | 实时跟踪 / follow live    |

## 管道与重定向 / Pipe & Redirect
| 符号 | 说明 |
|------|------|
| `>` | 覆盖写入 / overwrite |
| `>>` | 追加写入 / append |
| `2>/dev/null` | 丢弃 stderr / discard errors |
| `2>&1` | stderr 合并到 stdout |
| `\|` | 管道 / pipe |

## 帮助 / Help
| 命令 | 说明 |
|------|------|
| `man <cmd>` | 手册页 / manual page |
| `<cmd> --help` | 快速选项 / quick options |
| `type <cmd>` | 命令类型 / cmd type |
| `which <cmd>` | 命令位置 / cmd location |
| `apropos <kw>` | 搜索手册 / search man pages |
