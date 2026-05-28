# 03 — 文本处理三剑客 / Text Processing: grep, sed, awk

> [!info] 本章目标
> 这是 Linux 最重要的技能之一。掌握 grep、sed、awk 以及正则表达式，你就能在终端处理几乎任何文本数据。
>
> This is one of the most important Linux skills. Master grep, sed, awk, and regex, and you can process virtually any text data in the terminal.

---

## 3.1 正则表达式速览 / Regex Crash Course

> [!note] 什么是正则？
> 正则表达式是文本匹配的**模式语言**。学会它，grep/sed/awk 的威力翻十倍。
>
> Regex is a **pattern language** for matching text. Learn it, and grep/sed/awk become 10x more powerful.

### 元字符 / Metacharacters

| 模式 Pattern | 含义 Meaning | 示例 Example |
|-------------|-------------|:-----------|
| `.` | 任意单个字符 / any single char | `h.t` → hat, hit, h3t |
| `*` | 前一个字符 0 次或多次 / 0+ of preceding | `ab*c` → ac, abc, abbc |
| `+` | 前一个字符 1 次或多次 / 1+ of preceding | `ab+c` → abc, abbc (not ac) |
| `?` | 前一个字符 0 或 1 次 / 0 or 1 | `colou?r` → color, colour |
| `^` | 行首 / start of line | `^ERROR` |
| `$` | 行尾 / end of line | `done$` |
| `[abc]` | 字符集 / character class | `[bg]at` → bat, gat |
| `[^abc]` | 不包含 / excluding | `[^0-9]` → any non-digit |
| `{n,m}` | 出现 n 到 m 次 / n to m occurrences | `\d{3,5}` → 123, 12345 |
| `()` | 捕获组 / capture group | `(foo\|bar)` → foo or bar |
| `\|` | 或 / OR | `error\|fail` |

### 字符转义 / Character Escapes

| 转义 | 等价于 | 含义 |
|-----|:------:|------|
| `\d` | `[0-9]` | 数字 / digit |
| `\w` | `[a-zA-Z0-9_]` | 单词字符 / word char |
| `\s` | `[ \t\n\r]` | 空白字符 / whitespace |
| `\D` | `[^0-9]` | 非数字 / non-digit |

> [!tip] 贪婪 vs 非贪婪
> `.*` 是贪婪匹配（尽可能多吃），`.*?` 是非贪婪（尽可能少吃）。
> 例如：`<.*>` 匹配整个 `<a>foo</a>`，而 `<.*?>` 只匹配 `<a>`。

---

## 3.2 grep — 全局正则搜索 / Global Regular Expression Print

```bash
# 基础 / Basic
grep "pattern" file.txt            # 搜索匹配行 / search matching lines
grep -i "error" file.txt           # 忽略大小写 / case insensitive
grep -v "debug" file.txt           # 反向：不匹配的行 / invert match
grep -r "TODO" /path/to/code/      # 递归搜索目录 / recursive directory search
grep -n "pattern" file.txt         # 显示行号 / show line numbers
grep -c "pattern" file.txt         # 只显示匹配行数 / count only

# 上下文 / Context
grep -B 3 "error" file.txt         # 匹配行前 3 行 / 3 lines before
grep -A 3 "error" file.txt         # 匹配行后 3 行 / 3 lines after
grep -C 3 "error" file.txt         # 前后各 3 行 / 3 lines both sides

# 高级 / Advanced
grep -E "error|fail" file.txt      # 扩展正则（ERE）/ extended regex
grep -P "\d{3}" file.txt           # Perl 兼容正则（PCRE）
grep -o "http[^ ]*" file.txt       # 只输出匹配部分 / output only matched part
grep -l "pattern" *.txt            # 只显示有匹配的文件名 / filenames only
```

### 实战：分析访问日志

```bash
# 找出所有 4xx/5xx 状态码的行
$ grep -E " (4|5)[0-9]{2} " ~/linux-lab/files/access.log

# 统计每种状态码出现次数
$ grep -oE " [0-9]{3} " ~/linux-lab/files/access.log | sort | uniq -c | sort -rn
```

> [!tip] grep 最佳实践
> - 在大型目录搜索时始终用 `grep -r` 而非 `grep *`
> - `grep -v grep` 用于过滤掉 grep 自身进程（配合 ps 使用时）
> - 不确定大小写时加 `-i`，省心

---

## 3.3 sed — 流编辑器 / Stream Editor

> [!note] sed 的理念
> sed 逐行处理文本，适合做批量替换、删除、提取。它**默认不修改原文件**（除非加 `-i`）。
>
> sed processes text line-by-line. It does **not** modify the original file unless you use `-i`.

### 替换 / Substitution

```bash
# 语法：s/pattern/replacement/flags
sed 's/cat/dog/' file.txt           # 替换每行第一个匹配 / replace first per line
sed 's/cat/dog/g' file.txt          # 全局替换 / replace all (g = global)
sed 's/cat/dog/2' file.txt          # 只替换每行第 2 个匹配 / 2nd occurrence only
sed 's/^/PREFIX: /' file.txt        # 行首加前缀 / prefix each line
sed 's/$/ :SUFFIX/' file.txt        # 行尾加后缀 / suffix each line
```

### 删除 / Deletion

```bash
sed '3d' file.txt                   # 删除第 3 行 / delete line 3
sed '3,5d' file.txt                 # 删除第 3-5 行 / delete lines 3-5
sed '/^$/d' file.txt                # 删除空行 / delete blank lines
sed '/debug/d' file.txt             # 删除含 debug 的行 / delete matching lines
```

### 范围操作 / Range

```bash
sed -n '10,20p' file.txt            # 只打印第 10-20 行 / print lines 10-20 only
sed -n '/start/,/end/p' file.txt    # 打印 start 到 end 之间的内容
sed '/start/,/end/s/foo/bar/g'      # 在 start 到 end 之间替换
```

### 原地修改 / In-place Edit

```bash
sed -i.bak 's/old/new/g' file.txt   # 备份为 .bak，然后修改原文件
sed -i 's/old/new/g' file.txt       # 不备份直接改 / edit in place, no backup
```

### 实战：清理配置文件

```bash
# 删除注释行和空行，方便查看有效配置
$ sed -e '/^#/d' -e '/^$/d' /etc/ssh/sshd_config

# 提取 /etc/passwd 中所有用户名
$ sed 's/:.*//' /etc/passwd
```

---

## 3.4 awk — 文本处理语言 / The Text Processing Language

> [!note] awk 的理念
> awk 按**字段（列）**处理数据，是处理结构化文本（日志、CSV、表格数据）的利器。
>
> awk processes data by **fields (columns)** — ideal for structured text like logs, CSV, tabular data.

### 基本结构

```bash
# 语法：awk '条件 { 动作 }' 文件
# Syntax: awk 'condition { action }' file
```

### 字段变量 / Field Variables

```bash
awk '{print $1}' file.txt           # 第 1 列 / column 1
awk '{print $1, $3}' file.txt       # 第 1 和第 3 列 / columns 1 & 3
awk '{print $NF}' file.txt          # 最后一列 ($NF = number of fields)
awk '{print $(NF-1)}' file.txt      # 倒数第二列
awk '{print $0}' file.txt           # 整行 ($0 = whole line)
```

### 内置变量 / Built-in Variables

| 变量 | 含义 |
|-----|------|
| `NR` | 当前行号 / current line number |
| `NF` | 当前行的字段数 / number of fields |
| `FS` | 输入字段分隔符（默认空白）/ input field separator |
| `OFS` | 输出字段分隔符 / output field separator |
| `$0` | 整行 / entire line |

```bash
awk '{print NR, $0}' file.txt       # NR = 行号 / line number
awk '{print NF, $0}' file.txt       # NF = 字段数 / number of fields
awk -F: '{print $1, $3}' /etc/passwd  # -F 指定分隔符 / set field separator
```

### 条件过滤 / Conditional Filtering

```bash
awk '$3 > 1000' data.txt            # 第 3 列大于 1000 的行
awk '/error/' log.txt               # 包含 error 的行
awk 'NR >= 5 && NR <= 10' file.txt  # 第 5-10 行
awk 'length($0) > 80' file.txt      # 长度超过 80 字符的行
```

### 计算 / Calculations

```bash
# 第 1 列求和 / Sum of column 1
awk '{sum += $1} END {print sum}' data.txt

# 第 1 列平均值 / Average of column 1
awk '{sum += $1} END {print sum/NR}' data.txt

# 计算并输出新列 / Compute and output
awk '{print $1, ($2+$3)/2}' data.txt
```

> [!tip] BEGIN 和 END
> `BEGIN { ... }` 在处理任何行之前运行（适合打印表头）。
> `END { ... }` 在处理完所有行之后运行（适合打印汇总）。
> ```bash
> awk 'BEGIN {print "--- START ---"} {print $0} END {print "--- END ---"}' file.txt
> ```

### 实战：分析访问日志

```bash
# 每个 IP 的请求次数（降序）/ Request count per IP
$ awk '{count[$1]++} END {for (ip in count) print count[ip], ip}' \
    ~/linux-lab/files/access.log | sort -rn

# HTTP 状态码分布 / HTTP status code distribution
$ awk '{print $9}' ~/linux-lab/files/access.log | sort | uniq -c | sort -rn
```

---

## 3.5 组合之道 / Combining Them

> [!note] 经典模式
> `grep 过滤 → sed 清理 → awk 计算` 然后管道到 `sort | uniq -c | sort -rn` 做统计。

### 辅助工具链 / The Supporting Cast

| 命令 | 作用 | 示例 |
|------|------|------|
| `cut` | 按分隔符切列 | `cut -d: -f1 /etc/passwd` |
| `sort` | 排序 | `sort -n`（数字）、`-r`（倒序）、`-u`（去重） |
| `uniq` | 去重/计数 | `uniq -c`（计数）、`uniq -d`（只显示重复） |
| `wc` | 统计 | `wc -l`（行数）、`wc -w`（单词数） |
| `tee` | 输出到屏幕+文件 | `command | tee output.txt` |
| `xargs` | stdin → 命令参数 | `find . -name "*.tmp" | xargs rm` |

### 完整示例

```bash
# 找出 /var/log/syslog 中 ERROR 出现次数最多的前 5 个进程
$ grep ERROR /var/log/syslog | sed 's/.*\[//;s/\].*//' | sort | uniq -c | sort -rn | head -5
```

---

## 3.6 Vim 生存模式 / Vim Survival Mode

> [!warning] 你总会遇到 vim
> 服务器没有 VS Code。至少要学会 vim 的基本操作：**打开文件 → 编辑 → 保存 → 退出**。

```bash
vimtutor   # vim 内置教程（30 分钟，强烈推荐）
```

### 四种模式 / Four Modes

| 模式 Mode | 进入方式 | 作用 |
|-----------|---------|------|
| Normal | `Esc` | 导航和执行命令 |
| Insert | `i`, `a`, `o` | 输入文本 |
| Visual | `v`, `V` | 选择文本 |
| Command | `:` | 保存、退出、替换等 |

### 生存命令 / Survival Commands

```text
i       进入编辑模式 / enter insert mode
Esc     退出编辑模式 / return to normal mode
:w      保存 / save
:q      退出 / quit
:wq     保存并退出 / save and quit (or ZZ)
:q!     强制退出不保存 / force quit without saving
dd      删除当前行 / delete current line
yy      复制当前行 / yank (copy) current line
p       粘贴 / paste
u       撤销 / undo
Ctrl+R  重做 / redo
/text   搜索 / search (n 下一个 / next, N 上一个 / previous)
:%s/old/new/g   全局替换 / global replace
```

> [!tip] 记住这个就够了
> 如果你只记 5 个键：`i`（编辑）、`Esc`（退出编辑）、`:w`（保存）、`:q`（退出）、`u`（撤销）。够你活下来了。

---

## 🧪 练习 / Exercises

> [!example] 在虚拟机终端完成
> 进入 `exercises/` 目录运行 `bash check.sh`。

1. 用 `grep` 从 `~/linux-lab/files/access.log` 中提取所有 4xx 和 5xx 状态码的行
2. 用 `sed` 将 `~/linux-lab/files/fruits.txt` 中所有 "apple" 替换为 "APPLE"（不修改原文件）
3. 用 `awk` 计算 `access.log` 中每个 IP 的请求次数，按次数降序输出
4. 用管道组合：从 `access.log` 中找出 200 状态码的行 → 提取 IP → 去重 → 按请求次数排序
5. 在终端完成 `vimtutor` 的至少前 3 章

---

> [!info] 相关资源
> - 速查表 / Cheatsheet: [[03-text-processing/cheatsheet|Chapter 03 Cheatsheet]]
> - 上一章 / Prev: [[02-file-system/README|文件系统与路径]]
> - 下一章 / Next: [[04-users-permissions/README|用户与权限]]
