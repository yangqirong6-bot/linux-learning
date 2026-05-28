# 03 — 文本处理三剑客 / Text Processing: grep, sed, awk

Linux 的威力很大程度来自文本处理能力。这三个工具组合起来可以处理几乎任何文本数据。

Linux's power comes largely from text processing. These three tools combined can handle almost any text data.

---

## 3.1 正则表达式速览 / Regex Crash Course

正则表达式是文本匹配的模式语言。Regex is a pattern language for matching text.

| 模式 Pattern | 含义 Meaning | 示例匹配 Example |
|-------------|-------------|-----------------|
| `.` | 任意单个字符 any single char | `h.t` → hat, hit, h3t |
| `*` | 前一个字符 0 次或多次 0+ of preceding | `ab*c` → ac, abc, abbc |
| `+` | 前一个字符 1 次或多次 1+ of preceding | `ab+c` → abc, abbc (not ac) |
| `?` | 前一个字符 0 或 1 次 0 or 1 | `colou?r` → color, colour |
| `^` | 行首 start of line | `^ERROR` |
| `$` | 行尾 end of line | `done$` |
| `[abc]` | 字符集 character class | `[bg]at` → bat, gat |
| `[^abc]` | 不包含 excluding | `[^0-9]` → any non-digit |
| `\d` | 数字 digit (0-9) | `\d+` → 123, 42 |
| `\s` | 空白 whitespace | `foo\s+bar` |
| `\w` | 单词字符 word char [a-zA-Z0-9_] | `\w+` → hello_world |
| `{n,m}` | 出现 n 到 m 次 n to m occurrences | `\d{3,5}` → 123, 12345 |
| `()` | 捕获组 capture group | `(foo|bar)` → foo or bar |
| `|` | 或 OR | `error|fail` |

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
grep -l "pattern" *.txt            # 只显示文件名 / show only filenames

# 实战 / Practical
# 分析访问日志：找出所有 4xx/5xx 状态码
grep -E " (4|5)[0-9]{2} " access.log
# 统计每种状态码出现次数
grep -oE " (4|5)[0-9]{2} " access.log | sort | uniq -c | sort -rn
```

---

## 3.3 sed — 流编辑器 / Stream Editor

sed 逐行处理文本，适合做替换、删除、提取。sed processes text line-by-line, great for substitution, deletion, extraction.

```bash
# 替换 / Substitution (s/pattern/replacement/flags)
sed 's/cat/dog/' file.txt           # 替换每行第一个匹配 / replace first per line
sed 's/cat/dog/g' file.txt          # 全局替换 / replace all (g = global)
sed 's/^/PREFIX: /' file.txt        # 行首加前缀 / prefix each line
sed 's/$/ :SUFFIX/' file.txt        # 行尾加后缀 / suffix each line

# 删除 / Deletion
sed '3d' file.txt                   # 删除第 3 行 / delete line 3
sed '/^$/d' file.txt                # 删除空行 / delete blank lines
sed '/debug/d' file.txt             # 删除含 debug 的行 / delete matching lines
sed '2,5d' file.txt                 # 删除第 2-5 行 / delete lines 2-5

# 原地修改（备份）/ In-place edit (with backup)
sed -i.bak 's/old/new/g' file.txt   # 备份为 .bak，修改原文件 / backup to .bak, edit original
sed -i 's/old/new/g' file.txt       # 不备份直接改 / edit in place, no backup

# 范围操作 / Range addressing
sed -n '10,20p' file.txt            # 只打印第 10-20 行 / print lines 10-20 only
sed '/start/,/end/s/foo/bar/g'      # 在 start 到 end 之间替换 / replace between patterns

# 实战 / Practical
# 提取 /etc/passwd 中所有用户名
sed 's/:.*//' /etc/passwd
# 删除注释行和空行 / Remove comments and blank lines
sed -e '/^#/d' -e '/^$/d' /etc/ssh/sshd_config
```

---

## 3.4 awk — 文本处理语言 / The Text Processing Language

awk 按**字段**处理数据，是处理结构化文本（日志、CSV、列数据）的利器。

awk processes data by **fields** — the go-to tool for structured text like logs, CSV, columnar data.

```bash
# 基本结构 / Basic structure
# awk '条件 {动作}' 文件 / awk 'condition { action }' file

# 字段变量 / Field variables
awk '{print $1}' file.txt           # 第 1 列 / column 1
awk '{print $1, $3}' file.txt       # 第 1 和第 3 列 / columns 1 & 3
awk '{print $NF}' file.txt          # 最后一列 ($NF) / last column
awk '{print $(NF-1)}' file.txt      # 倒数第二列 / second to last

# 内置变量 / Built-in variables
awk '{print NR, $0}' file.txt       # NR = 行号 / line number
awk '{print NF, $0}' file.txt       # NF = 字段数 / number of fields
awk -F: '{print $1, $3}' /etc/passwd  # -F 指定分隔符 / set field separator

# 条件过滤 / Conditional filtering
awk '$3 > 1000' data.txt            # 第 3 列大于 1000 的行
awk '/error/' log.txt               # 包含 error 的行
awk 'NR >= 5 && NR <= 10' file.txt   # 第 5-10 行
awk 'length($0) > 80' file.txt       # 长度超过 80 个字符的行

# 计算 / Calculations
awk '{sum += $1} END {print sum}' data.txt     # 第 1 列求和 / sum of column 1
awk '{sum += $1} END {print sum/NR}' data.txt  # 第 1 列平均值 / average
awk '{print $1, ($2+$3)/2}' data.txt           # 计算并输出 / compute and print

# BEGIN 和 END 块 / BEGIN and END blocks
awk 'BEGIN {print "--- START ---"} {print $0} END {print "--- END ---"}' file.txt

# 实战：分析访问日志 / Practical: analyze access log
# 每个 IP 的请求数 / Request count per IP
awk '{count[$1]++} END {for (ip in count) print count[ip], ip}' access.log | sort -rn
# 统计 HTTP 状态码分布 / HTTP status code distribution
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

---

## 3.5 组合之道 / Combining Them

```bash
# 经典模式：grep 过滤 → sed 清理 → awk 计算
# Classic pattern: grep filter → sed clean → awk compute

# 示例：找出 /var/log/syslog 中 ERROR 出现最多的前 5 个进程
grep ERROR /var/log/syslog | sed 's/.*\[//;s/\].*//' | sort | uniq -c | sort -rn | head -5

# 组合工具速查 / Quick reference for combining tools:
#   cut  - 按列切分 / cut by delimiter    cut -d: -f1 /etc/passwd
#   sort - 排序 / sort                      sort -n (数字), sort -r (倒序), sort -u (去重)
#   uniq - 去重/计数 / dedup/count          uniq -c (计数), uniq -d (只显示重复)
#   wc   - 统计 / count                     wc -l (行), wc -w (词), wc -c (字节)
#   tee  - 同时输出到文件和管道 / output to file AND pipe
#   xargs - 将 stdin 转为命令参数 / convert stdin to command arguments
```

---

## 3.6 Vim 基础 / Vim Basics

> 有时你不得不在没有 GUI 的服务器上编辑文件。至少要学会 vim 的生存模式。
> Sometimes you must edit files on a server with no GUI. Learn vim survival mode at minimum.

```bash
vimtutor   # vim 内置教程（30 分钟） / vim's built-in tutorial (30 min)
```

| 模式 Mode | 进入方式 Enter | 作用 |
|-----------|---------------|------|
| Normal | `Esc` | 导航和执行命令 / navigate and command |
| Insert | `i`, `a`, `o` | 输入文本 / type text |
| Visual | `v`, `V`, `Ctrl+V` | 选择文本 / select text |
| Command | `:` | 执行 ex 命令 / ex commands |

**生存命令 / Survival Commands:**

```text
i       进入编辑模式 / enter insert mode
Esc     退出编辑模式 / return to normal mode
:w      保存 / save
:q      退出 / quit
:wq     保存并退出 / save and quit  (or ZZ)
:q!     强制退出不保存 / force quit without saving
dd      删除当前行 / delete current line
yy      复制当前行 / yank (copy) current line
p       粘贴 / paste
u       撤销 / undo
Ctrl+R  重做 / redo
/text   搜索 / search (n 下一个, N 上一个)
:%s/old/new/g   全局替换 / global replace
```

---

## 练习 / Exercises

进入 `exercises/` 目录运行 `bash check.sh`。

1. 用 `grep` 从 `access.log` 中提取所有 4xx 和 5xx 状态码的行
2. 用 `sed` 将 `fruits.txt` 中所有 "apple" 替换为 "APPLE"
3. 用 `awk` 计算 `access.log` 中每个 IP 的请求次数，按次数降序输出
4. 用管道组合：从 `access.log` 中找出 200 状态码的行，提取 IP，去重并按请求次数排序
5. 在终端完成 `vimtutor` 的至少前 3 章（Chapter 1-3）
