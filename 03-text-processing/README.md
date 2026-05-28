# 03 — 文本处理三剑客 / grep, sed, awk

> [!info] 本章目标
> 这是 Linux 最重要的技能之一。学完本章，你将能够：用正则表达式匹配文本、用 `grep` 搜索和过滤、用 `sed` 做批量查找替换、用 `awk` 处理列式数据（日志分析、CSV 统计）、在 vim 中编辑文件并活着退出。
>
> **预计时间**：2-3 小时

---

## 3.0 为什么这三件套这么重要？

在实际工作中，你经常需要：

- **查日志**："上个月哪些 IP 访问了这个接口？哪个返回了 500 错误？"
- **批量改名**："把 200 个配置文件里的 `old-server` 全改成 `new-server`"
- **数据统计**："这个 CSV 文件第 3 列的总和是多少？各组各有多少条？"

GUI 工具做不了这些，而 grep/sed/awk 可以。

```bash
# 一个真实场景：分析 Web 服务器访问日志
$ cat ~/linux-lab/files/access.log
```
输出：
```text
192.168.1.1 - - [10/Jan/2024:13:55:36 +0000] GET /index.html 200
192.168.1.2 - - [10/Jan/2024:13:56:01 +0000] POST /login 302
10.0.0.1 - - [10/Jan/2024:13:56:45 +0000] GET /api/data 500
192.168.1.1 - - [10/Jan/2024:13:57:12 +0000] GET /about 200
10.0.0.2 - - [10/Jan/2024:13:58:00 +0000] GET / 404
```

这个文件将在本章反复使用。

---

## 3.1 正则表达式：文本匹配的"公式"

> [!note] 如果你只能学一项技能
> 正则表达式几乎在所有编程语言和工具中都通用。学会正则，你在 Linux、Python、JavaScript、VS Code 搜索中都能受益。

正则表达式就是用特殊符号来描述"什么样的文字"，比如：
- "所有以 `error` 开头的行" → `^error`
- "所有包含 3 到 5 位数字的行" → `\d{3,5}`
- "所有 .log 结尾的文件" → `\.log$`

### 第一组：匹配位置

```bash
# 准备测试数据
$ cd ~/linux-lab/files
$ cat lines.txt
```
输出：
```text
line 1
line 2
LINE 3
line 4
LINE 5
line 6
```

```bash
$ grep "line" lines.txt           # 包含 line 就行
```
输出：
```text
line 1
line 2
line 4
line 6
```

```bash
$ grep "^line" lines.txt          # ^ = 必须行首是 line
```
输出：
```text
line 1
line 2
line 4
line 6
```

```bash
$ grep "5$" lines.txt             # $ = 必须行尾是 5
```
输出：
```text
LINE 5
```

> [!tip] `^` 和 `$` 的记忆口诀
> `^` = 像一支箭的尖，指向行首。`$` = 像一个句号，放在句尾。

### 第二组：匹配字符

| 模式 | 含义 | 示例 |
|:---|:---|:---|
| `.` | 任意**一个**字符 | `l.ne` → line, lone, l9ne |
| `[abc]` | a、b、c 中的任意一个 | `[Ll]ine` → line, Line |
| `[^abc]` | 除了 a、b、c 以外的任意字符 | `[^0-9]` → 非数字 |
| `[a-z]` | 从 a 到 z 的任意一个字母 | `[A-Z]` 大写, `[0-9]` 数字 |

```bash
# 匹配 Line 或 line
$ grep "[Ll]ine" lines.txt
```
输出：
```text
line 1
line 2
LINE 3
line 4
LINE 5
line 6
```

### 第三组：匹配次数（量词）

| 模式 | 含义 | 示例 |
|:---|:---|:---|
| `*` | 前面那个东西出现 0 次或更多 | `ab*c` → ac, abc, abbc |
| `+` | 前面那个东西出现 1 次或更多 | `ab+c` → abc, abbc（不匹配 ac） |
| `?` | 前面那个东西出现 0 次或 1 次 | `colou?r` → color, colour |
| `{n}` | 正好 n 次 | `\d{3}` → 123, 456 |
| `{n,}` | 至少 n 次 | `\d{3,}` → 123, 12345 |
| `{n,m}` | n 到 m 次 | `\d{3,5}` → 123, 12345 |

```bash
# 匹配包含 3 位数字的行
$ echo -e "12\n123\n1234\n12345" | grep -E "[0-9]{3}"
```
输出：
```text
123
1234
12345
```

> [!tip] 注意 `-E` 参数
> `grep` 默认用 **基本正则（BRE）**，`+`、`?`、`{` 需要加反斜杠。加 `-E` 切换为 **扩展正则（ERE）**，这些符号可以直接用，更方便。很多 Linux 用户给 `grep` 设置了别名 `alias grep='grep -E'`。

### 第四组：转义与特殊字符

| 缩写 | 等价于 | 含义 |
|:---|:---|:---|
| `\d` | `[0-9]` | 数字 |
| `\w` | `[a-zA-Z0-9_]` | 单词字符 |
| `\s` | `[ \t\n\r]` | 空白字符 |
| `\D` | `[^0-9]` | 非数字 |
| `\.` | — | 真正的点（不是"任意字符"） |
| `\\` | — | 真正的反斜杠 |

> [!warning] 注意：`\d` `\w` `\s` 在 `grep -P` 下才有效
> `grep -E` 不支持 `\d` 简写，要用 `[0-9]`。`grep -P`（Perl 正则）支持 `\d`。
> ```bash
> $ echo "abc123" | grep -P "\d+"    # ✅ 匹配
> $ echo "abc123" | grep -E "\d+"    # ❌ 不匹配（BRE/ERE 不认识 \d）
> $ echo "abc123" | grep -E "[0-9]+" # ✅ 正确
> ```

### 🧪 即时练习

```bash
$ cd ~/linux-lab/files

# 1. 匹配以大写 LINE 开头的行
$ grep "^LINE" lines.txt

# 2. 匹配以数字 2 或 5 结尾的行
$ grep "[25]$" lines.txt

# 3. 匹配 fruits.txt 中所有含 "apple" 或 "banana" 的行
$ grep -E "apple|banana" fruits.txt
```

---

## 3.2 grep — 搜索大师

> [!note] grep 是什么？
> **G**lobal **R**egular **E**xpression **P**rint。在文件中按正则表达式搜索匹配行，打印出来。

### 基本用法

```bash
# 在单个文件中搜索
$ grep "error" access.log

# 在目录中递归搜索（. 表示当前目录）
$ grep -r "TODO" ~/linux-lab/

# 搜索时不区分大小写
$ grep -i "error" access.log

# 反向搜索：显示不匹配的行
$ grep -v "200" access.log
```

### 显示上下文

有时候你需要看到匹配行**周围的几行**来理解发生了什么：

```bash
# 匹配行前 3 行和后 2 行
$ grep -B 3 -A 2 "500" access.log

# 或者直接：前后各 3 行
$ grep -C 3 "500" access.log
```

`-B` = Before, `-A` = After, `-C` = Context。

### 显示行号和计数

```bash
$ grep -n "error" /var/log/syslog    # 每条匹配显示行号
$ grep -c "200" access.log           # 有多少行匹配
```
输出：
```text
2
```

### 只看匹配到的内容（不是整行）

```bash
# 从日志中提取所有 IP 地址
$ grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access.log
```
输出：
```text
192.168.1.1
192.168.1.2
10.0.0.1
192.168.1.1
10.0.0.2
```

`-o` = only matching（只输出匹配到的部分，不输出整行）。

### 显示匹配的文件名

```bash
# 哪些 .txt 文件包含 "error"？
$ grep -l "apple" *.txt           # -l = 只显示文件名
$ grep -L "apple" *.txt           # -L = 不含 "apple" 的文件
```

### 实战：分析访问日志

```bash
$ cd ~/linux-lab/files

# 谁访问了 /api/data？
$ grep "/api/data" access.log
```
输出：
```text
10.0.0.1 - - [10/Jan/2024:13:56:45 +0000] GET /api/data 500
```

```bash
# 哪些 IP 触发了 4xx 或 5xx 错误？
$ grep -E " [45][0-9]{2} " access.log | grep -oE "^[0-9.]+"
```
输出：
```text
192.168.1.2
10.0.0.1
10.0.0.2
```

### 🧪 即时练习

```bash
$ cd ~/linux-lab/files

# 1. 在 access.log 里找所有状态码为 200 的行
$ grep "200" access.log

# 2. 统计 200 状态码出现了几次
$ grep -c "200" access.log

# 3. 提取所有以 192 开头的 IP（用 -o）
$ grep -oE "192\.[0-9.]+" access.log

# 4. 在 /etc 目录下搜索所有包含 "bash" 的 .conf 文件（递归）
$ grep -rl "bash" /etc --include="*.conf" 2>/dev/null
```

---

## 3.3 sed — 流编辑器

> [!note] sed 是什么？
> **S**tream **ED**itor。它把文件一行一行地读进来，按你给的规则处理每一行，然后把结果输出。**默认不修改原文件**（除非加 `-i`）。

### 替换：最常用的操作

```bash
# 语法：s/要找什么/替换成什么/标志
$ sed 's/apple/APPLE/' fruits.txt
```
输出：
```text
APPLE
banana
cherry
APPLE pie
pineapple         ← 注意：pineapple 里的 apple 也变了！
```

> [!warning] sed 默认只替换每行的**第一个**匹配
> 看看区别：
> ```bash
> $ echo "apple and apple" | sed 's/apple/APPLE/'
> # 输出：APPLE and apple
> 
> $ echo "apple and apple" | sed 's/apple/APPLE/g'
> # 输出：APPLE and APPLE   ← g = global 全局替换
> ```

### 常用替换场景

```bash
# 删除行首空白
$ sed 's/^ *//' file.txt

# 删除行尾空白
$ sed 's/ *$//' file.txt

# 给每行加前缀
$ sed 's/^/PREFIX: /' fruits.txt
```
输出：
```text
PREFIX: apple
PREFIX: banana
PREFIX: cherry
PREFIX: apple pie
PREFIX: pineapple
```

```bash
# 把行尾的 dos 换行符 (\r) 去掉（Windows→Linux 格式转换）
$ sed 's/\r$//' windows_file.txt
```

### 删除

```bash
# 删除第 3 行
$ sed '3d' fruits.txt
```
输出：
```text
apple
banana
apple pie
pineapple
```

```bash
# 删除空行
$ sed '/^$/d' file.txt

# 删除所有包含 debug 的行
$ sed '/debug/d' /var/log/syslog

# 删除第 2 到第 4 行
$ sed '2,4d' fruits.txt
```

### 提取（打印特定行）

```bash
# 只打印第 2 到第 4 行（-n = 默认不输出，p = 这些行除外）
$ sed -n '2,4p' fruits.txt
```
输出：
```text
banana
cherry
apple pie
```

### 原地修改文件

```bash
# 不备份，直接改
$ sed -i 's/apple/APPLE/g' file.txt

# 先备份再改（习惯更好）
$ sed -i.bak 's/apple/APPLE/g' file.txt
# 生成 file.txt.bak（原文件备份）和 file.txt（改后）
```

> [!danger] `sed -i` 没有撤销！
> 跟 `rm` 一样，没有回收站。不确定时先不用 `-i`，看输出确认无误再加。
> ```bash
> # 安全做法
> $ sed 's/old/new/g' file.txt        # 先看看输出
> $ sed -i.bak 's/old/new/g' file.txt # 确认无误再原地改（带备份）
> ```

### 实战例子

```bash
# 删除 /etc/ssh/sshd_config 中的注释行和空行，方便查看有效配置
$ sed -e '/^#/d' -e '/^$/d' /etc/ssh/sshd_config
```

`-e` 表示"接下一个表达式"。这里两个操作：`/^#/d` 删注释行，`/^$/d` 删空行。

```bash
# 改变输出格式：从 passwd 格式提取用户名
$ sed 's/:.*//' /etc/passwd | head -5
```
输出：
```text
root
daemon
bin
sys
sync
```

### 🧪 即时练习

```bash
$ cd ~/linux-lab/files

# 1. 把 fruits.txt 中所有的 "apple" 替换成 "MANGO"（不修改原文件）
$ sed 's/apple/MANGO/g' fruits.txt

# 2. 删除 fruits.txt 的第 2 行
$ sed '2d' fruits.txt

# 3. 在 access.log 的每行前面加上行号
$ sed = access.log | sed 'N; s/\n/: /'
# （先想想怎么更简单？用 awk 一行搞定：awk '{print NR": "$0}' access.log）

# 4. 把 access.log 中的 IP 10.0.0.1 改为 172.16.0.1
$ sed 's/10\.0\.0\.1/172.16.0.1/g' access.log
```

---

## 3.4 awk — 文本处理的瑞士军刀

> [!note] awk 是什么？
> awk 把每一行自动拆成**列**（fields），然后你可以对每一列做筛选、计算、格式化。理解 awk 的最好方式是把它想象成**终端的 Excel**。

### 基本概念：每一行自动分列

awk 默认用空白（空格/Tab）分隔列：

```bash
$ awk '{print $1}' access.log
```
输出：
```text
192.168.1.1
192.168.1.2
10.0.0.1
192.168.1.1
10.0.0.2
```

| 变量 | 含义 |
|:---|:---|
| `$1` | 第 1 列 |
| `$2` | 第 2 列 |
| `$NF` | 最后一列 |
| `$(NF-1)` | 倒数第二列 |
| `$0` | 整行 |

用 access.log 验证：

```bash
$ awk '{print $1, $NF}' access.log
```
输出：
```text
192.168.1.1 200
192.168.1.2 302
10.0.0.1 500
192.168.1.1 200
10.0.0.2 404
```

### 自定义分隔符

不是所有文件都用空格分隔。`-F` 指定分隔符：

```bash
# /etc/passwd 用冒号分隔
$ awk -F: '{print $1, $3}' /etc/passwd | head -5
```
输出：
```text
root 0
daemon 1
bin 2
sys 3
sync 4
```

### 内置变量速查

| 变量 | 含义 |
|:---|:---|
| `NR` | 当前是第几行（整体行号） |
| `FNR` | 当前文件内行号（处理多文件时有区别） |
| `NF` | 当前行有几列（字段数） |
| `$0` | 整行内容 |
| `FS` | 输入字段分隔符（等价 `-F`） |
| `OFS` | 输出字段分隔符（默认空格） |

```bash
# 给每行加行号
$ awk '{print NR, $0}' fruits.txt
```
输出：
```text
1 apple
2 banana
3 cherry
4 apple pie
5 pineapple
```

### 条件过滤：只处理符合条件的行

```bash
# 状态码大于 400 的行
$ awk '$NF > 400' access.log
```
输出：
```text
10.0.0.1 - - [10/Jan/2024:13:56:45 +0000] GET /api/data 500
10.0.0.2 - - [10/Jan/2024:13:58:00 +0000] GET / 404
```

```bash
# 包含 POST 的行
$ awk '/POST/' access.log
```
输出：
```text
192.168.1.2 - - [10/Jan/2024:13:56:01 +0000] POST /login 302
```

```bash
# 第 5 到第 10 行
$ awk 'NR >= 5 && NR <= 10' file.txt

# 长度超过 80 个字符的行
$ awk 'length($0) > 80' file.txt
```

### 数学运算：awk 真正强在这里

```bash
# 求第一列的和
$ seq 1 10 | awk '{sum += $1} END {print sum}'
```
输出：
```text
55
```

```bash
# 求第一列的平均值
$ seq 1 10 | awk '{sum += $1} END {print sum/NR}'
```
输出：
```text
5.5
```

> [!tip] `BEGIN` 和 `END` 块
> `BEGIN { ... }` → 在处理任何行之前执行（打印表头、初始化变量）
> `{ ... }` → 每行都执行
> `END { ... }` → 所有行处理完后执行（打印汇总结果）
>
> ```bash
> $ awk 'BEGIN {print "Name\tUID"} {print $1,"\t",$3} END {print "--- END ---"}' /etc/passwd | head -5
> ```
> 输出：
> ```text
> Name    UID
> root    0
> daemon  1
> bin     2
> --- END ---
> ```

### 分组统计（关联数组）

awk 里可以用**关联数组**进行分组统计：

```bash
# 每个 IP 发了多少个请求？（访问量排行）
$ awk '{count[$1]++} END {for (ip in count) print count[ip], ip}' access.log | sort -rn
```
输出：
```text
2 192.168.1.1
1 192.168.1.2
1 10.0.0.1
1 10.0.0.2
```

解读：
- `{count[$1]++}` → 以 IP 为键，每遇到一次就 +1
- `END {for (ip in count) print count[ip], ip}` → 遍历 count 数组，打印次数和 IP
- `| sort -rn` → 按数字倒序（最多的排最前）

```bash
# 每个状态码出现了多少次？
$ awk '{count[$NF]++} END {for (code in count) print count[code], code}' access.log | sort -rn
```
输出：
```text
2 200
1 500
1 404
1 302
```

### 实战：一行命令分析日志

```bash
# 哪些 IP 触发了错误（状态码 >= 400）？按次数排序
$ awk '$NF >= 400 {err[$1]++} END {for (ip in err) print err[ip], ip}' access.log | sort -rn
```
输出：
```text
1 10.0.0.1
1 10.0.0.2
1 192.168.1.2
```

### 🧪 即时练习

```bash
$ cd ~/linux-lab/files

# 1. 打印 access.log 的第 1 列和第最后一列
$ awk '{print $1, $NF}' access.log

# 2. 统计 access.log 有多少行
$ awk 'END {print NR}' access.log

# 3. 求出 fruits.txt 每行的字符数
$ awk '{print length($0), $0}' fruits.txt

# 4. 用 awk 从 /etc/passwd 提取所有用户名和 Shell（以冒号分隔）
$ awk -F: '{print $1, $NF}' /etc/passwd | head -10
```

---

## 3.5 工具链组合：1+1+1 > 3

Linux 文本处理真正的威力在于**把工具串起来**。

### 辅助工具速览

| 命令 | 作用 | 典型用法 |
|:---|:---|:---|
| `cut` | 按分隔符切列 | `cut -d: -f1 /etc/passwd` |
| `sort` | 排序 | `sort -n`（数字）、`-r`（倒序）、`-u`（去重） |
| `uniq -c` | 合并重复行并计数 | `sort | uniq -c | sort -rn` |
| `wc -l` | 数行数 | `wc -l file.txt` |
| `tee` | 一边存文件一边看输出 | `command | tee output.txt` |
| `xargs` | 把标准输入变成命令行参数 | `find . -name "*.tmp" | xargs rm` |

### 经典管道链

几乎所有日志分析都遵循这个模式：

```text
grep 过滤 → awk 提取/计算 → sort | uniq -c | sort -rn 排序计数
```

实战：**找出 access.log 中访问次数最多的 IP**

```bash
# 第一步：提取所有 IP（awk 取第 1 列）
$ awk '{print $1}' access.log
```
输出：
```text
192.168.1.1
192.168.1.2
10.0.0.1
192.168.1.1
10.0.0.2
```

```bash
# 第二步：排序（uniq 计数前必须排序）
$ awk '{print $1}' access.log | sort
```
输出：
```text
10.0.0.1
10.0.0.2
192.168.1.1
192.168.1.1
192.168.1.2
```

```bash
# 第三步：去重 + 计数
$ awk '{print $1}' access.log | sort | uniq -c
```
输出：
```text
      1 10.0.0.1
      1 10.0.0.2
      2 192.168.1.1
      1 192.168.1.2
```

```bash
# 第四步：按次数倒序（最多的排最上）
$ awk '{print $1}' access.log | sort | uniq -c | sort -rn
```
输出：
```text
      2 192.168.1.1
      1 192.168.1.2
      1 10.0.0.2
      1 10.0.0.1
```

> [!tip] 这个模式万物皆可分析
> 把 "提取 IP" 换成 "提取状态码"、"提取用户名"、"提取 URL" —— 一样的方法。

### 🧪 即时练习

```bash
$ cd ~/linux-lab/files

# 1. 统计 access.log 中每个状态码的出现次数
$ awk '{print $NF}' access.log | sort | uniq -c | sort -rn

# 2. 统计 fruits.txt 中每个单词的出现次数
$ grep -oE "[a-z]+" fruits.txt | sort | uniq -c | sort -rn

# 3. 找出 /etc 下最大的 5 个 .conf 文件
$ find /etc -name "*.conf" -exec ls -l {} \; 2>/dev/null | awk '{print $5, $NF}' | sort -rn | head -5
```

---

## 3.6 Vim：你会需要的终端编辑器

> [!warning] 总有一天你会在服务器上遇到 vim
> 服务器没有 VS Code、没有 Sublime、没有鼠标。知道怎么在 vim 里打开文件、编辑、保存、退出就够了。

### 先打开内置教程（30 分钟，值得）

```bash
$ vimtutor
```

这个互动教程会带你一步步操作。下面只讲**生存必备的 7 个操作**。

### 生存模式：7 个必须知道的操作

打开 vim 练习：

```bash
$ vim ~/linux-lab/files/fruits.txt
```

#### 1. 进入编辑模式

按 `i`。左下角出现 `-- INSERT --`。现在你可以像普通记事本一样打字了。

#### 2. 退出编辑模式

按 `Esc`。`-- INSERT --` 消失。你又回到了"命令模式"。

#### 3. 保存

在命令模式下：
```
:w
```
按回车。看到 `"fruits.txt" written` 说明保存成功。

#### 4. 退出

```
:q
```
（`w` = write 保存, `q` = quit 退出）

#### 5. 保存并退出

```
:wq
```
（或者直接 `ZZ`，大写）

#### 6. 不保存强制退出

```
:q!
```
加上 `!` 表示"强制执行"。

#### 7. 撤销

在命令模式下按 `u`。跟 `Ctrl+Z` 一样。

### 其他常用快捷键

| 操作 | 按键 |
|:---|:---|
| 删除当前行 | `dd` |
| 复制当前行 | `yy` |
| 粘贴 | `p` |
| 搜索单词 | `/关键词` → `n` 下一个 |
| 全局替换 | `:%s/old/new/g` |
| 跳到文件开头 | `gg` |
| 跳到文件末尾 | `G` |
| 跳到行首 | `0` 或 `^` |
| 跳到行尾 | `$` |

> [!tip] vim 的学习曲线
> 第 1 天：只会 `i`、`Esc`、`:wq` —— 能活下来
> 第 1 周：加上 `dd`、`yy`、`p` —— 开始有感觉了
> 第 1 月：上 `ci"`、`di(`、宏录制 —— 效率飞升

---

## 🧪 本章综合练习

> [!example] 在虚拟机终端完成

1. 用 `grep` 从 `~/linux-lab/files/access.log` 中提取所有状态码为 4xx 或 5xx 的行
2. 用 `sed` 将 `~/linux-lab/files/fruits.txt` 中所有 "apple" 替换为 "APPLE"（不修改原文件，只输出结果）
3. 用 `awk` 计算 `access.log` 中每个 IP 的请求次数，按次数降序排列
4. 用管道组合：从 `access.log` 中找出 200 状态码的行 → 提取 IP → 去重排序
5. 在终端完成 `vimtutor` 前 3 章（大约 15 分钟）

---

## 📋 本章命令速查

### grep

| 命令 | 作用 |
|:---|:---|
| `grep "pat" file` | 搜索 |
| `grep -i "pat" file` | 忽略大小写 |
| `grep -v "pat" file` | 反向（不包含） |
| `grep -r "pat" dir/` | 递归搜索目录 |
| `grep -n "pat" file` | 带行号 |
| `grep -c "pat" file` | 计数 |
| `grep -o "pat" file` | 只输出匹配部分 |
| `grep -A3 -B2 "pat" file` | 上下文 |
| `grep -E "(a\|b)" file` | 扩展正则 |
| `grep -l "pat" *.txt` | 只显示文件名 |

### sed

| 命令 | 作用 |
|:---|:---|
| `sed 's/old/new/g'` | 全局替换 |
| `sed '/pat/d'` | 删除匹配行 |
| `sed '/^$/d'` | 删除空行 |
| `sed -n '5,10p'` | 打印 5-10 行 |
| `sed -i.bak 's/a/b/g'` | 原地修改（备份） |
| `sed 's/:.*//'` | 删除冒号及之后 |

### awk

| 命令 | 作用 |
|:---|:---|
| `awk '{print $1}'` | 第 1 列 |
| `awk -F: '{print $1,$3}'` | 自定义分隔符 |
| `awk '$3 > 100'` | 条件过滤 |
| `awk '{s+=$1} END {print s}'` | 第 1 列求和 |
| `awk '{a[$1]++} END {for(k in a) print a[k],k}'` | 分组统计 |
| `awk 'NR>=5 && NR<=10'` | 行范围 |
| `awk 'length($0) > 80'` | 行长度筛选 |

### 辅助工具

| 命令 | 作用 |
|:---|:---|
| `sort -n` / `sort -rn` | 数字排序 / 倒序 |
| `uniq -c` | 去重并计数 |
| `cut -d: -f1` | 按分隔符切列 |
| `wc -l` / `wc -w` | 计数行 / 计数词 |
| `tee file.txt` | 同时输出到屏幕和文件 |
| `xargs command` | stdin → 命令行参数 |

---

> [!info] 继续学习
> - 速查表：[[03-text-processing/cheatsheet|Chapter 03 Cheatsheet]]
> - 上一章：[[02-file-system/README|文件系统与路径]]
> - 下一章：[[04-users-permissions/README|用户与权限]]
