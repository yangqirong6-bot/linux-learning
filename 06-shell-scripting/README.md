# 06 — Shell 脚本编程 / Shell Scripting

> [!info] 本章目标
> 学完这一章，你将能够：编写可维护的 Shell 脚本、处理变量和参数、用条件判断和循环控制流程、调试脚本中的错误、避开最常见的脚本陷阱。
>
> **预计时间**：2-3 小时

---

## 6.1 第一个脚本

```bash
#!/bin/bash
echo "Hello Linux!"
exit 0
```

`#!/bin/bash`（shebang）告诉系统用哪个解释器来执行这个文件。`exit 0` 表示成功结束。

```bash
$ chmod +x hello.sh
$ ./hello.sh
```
输出：
```text
Hello Linux!
```

> [!warning] `./` 不能省
> Linux 出于安全考虑不会在 PATH 里搜当前目录。写 `./hello.sh` 而不是 `hello.sh`。

---

## 6.2 变量

### 定义和使用

```bash
name="Alice"                    # 等号两边不能有空格！
echo "Hello, $name"             # 双引号里 $name 会被展开
echo 'Hello, $name'             # 单引号里 $name 保持原样
echo "Hello, ${name}"           # 用 {} 明确变量边界
```

### 特殊变量

| 变量 | 含义 |
|:---|:---|
| `$0` | 脚本名 |
| `$1` ~ `$9` | 第 1~9 个参数 |
| `$#` | 参数个数 |
| `$@` | 所有参数（每个独立） |
| `$*` | 所有参数（拼成一个字符串） |
| `$?` | 上一条命令的退出码 |
| `$$` | 当前脚本的 PID |
| `$!` | 上一个后台命令的 PID |

```bash
#!/bin/bash
echo "Script name: $0"
echo "First param: $1"
echo "All params:   $@"
echo "Param count:  $#"
echo "My PID:       $$"
```

输出：
```text
$ ./vars.sh hello world
Script name: ./vars.sh
First param: hello
All params:   hello world
Param count:  2
My PID:       12345
```

---

## 6.3 安全模式：防止脚本出错

```bash
set -euo pipefail
```

| 选项 | 作用 |
|:---|:---|
| `set -e` | 任何命令失败就退出（不要让脚本带着错误继续跑） |
| `set -u` | 引用未定义的变量时报错 |
| `set -o pipefail` | 管道中任何一部分失败都算失败 |

> [!important] 几乎所有脚本都该以 `set -euo pipefail` 开头
> 这是从血的教训中总结出来的。不加这三行，你的脚本会在静默中跑出你没意识到的错误。

---

## 6.4 条件判断

### `if` 语句

```bash
#!/bin/bash
set -euo pipefail

file="/etc/passwd"

if [ -f "$file" ]; then
    echo "$file is a regular file"
else
    echo "$file does not exist or is not a regular file"
fi
```

### 常用测试条件

| 文件测试 | 含义 |
|:---|:---|
| `-f` | 是普通文件 |
| `-d` | 是目录 |
| `-e` | 文件/目录存在 |
| `-r` / `-w` / `-x` | 可读 / 可写 / 可执行 |
| `-s` | 文件非空 |
| `-L` | 是符号链接 |

| 字符串测试 | 含义 |
|:---|:---|
| `-z "$str"` | 字符串为空 |
| `-n "$str"` | 字符串非空 |
| `"$a" = "$b"` | 相等 |
| `"$a" != "$b"` | 不等 |

| 数值测试 | 含义 |
|:---|:---|
| `-eq` / `-ne` | 等于 / 不等于 |
| `-lt` / `-gt` | 小于 / 大于 |
| `-le` / `-ge` | 小于等于 / 大于等于 |

### `[[]]` vs `[]`

```bash
# [ ] 是 POSIX 兼容的，但功能有限
# [[ ]] 是 Bash 增强版，更安全（不需要引号保护），支持正则

if [[ $name =~ ^A.* ]]; then     # [[ ]] 可以匹配正则
    echo "name starts with A"
fi
```

> [!tip] 优先用 `[[ ]]`
> `[[ ]]` 不需要引号保护变量、支持正则、不会因为空变量报错。只要写 Bash 脚本（不要求 sh 兼容），就优先用 `[[ ]]`。

### `case` 多重选择

```bash
case "$1" in
    start)  echo "Starting...";;
    stop)   echo "Stopping...";;
    restart) echo "Restarting...";;
    *)      echo "Usage: $0 {start|stop|restart}"; exit 1;;
esac
```

---

## 6.5 循环

### `for` 循环

```bash
# 遍历列表
for fruit in apple banana cherry; do
    echo "Fruit: $fruit"
done

# 遍历文件
for file in /etc/*.conf; do
    echo "Config: $file"
done

# C 风格循环
for (( i=1; i<=5; i++ )); do
    echo "Iteration $i"
done
```

### `while` 和 `until`

```bash
# while：条件为真时循环
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    ((count++))
done

# until：条件为假时循环（直到为真）
until ping -c 1 google.com &>/dev/null; do
    echo "Waiting for network..."
    sleep 2
done
echo "Network is up!"
```

### 读取文件每一行

```bash
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hostname
```

> [!warning] `IFS=` 和 `-r` 很重要
> 不用 `-r` 反斜杠会被转义；不设 `IFS=` 前后的空白会被删掉。

---

## 6.6 函数

```bash
#!/bin/bash
set -euo pipefail

# 定义
say_hello() {
    local name="$1"          # local 让变量只在函数内生效
    echo "Hello, $name!"
}

# 调用
say_hello "Alice"
say_hello "Bob"

# 返回值（只能是 0-255 的数字）
is_even() {
    if (( $1 % 2 == 0 )); then
        return 0
    else
        return 1
    fi
}

if is_even 42; then
    echo "42 is even"
fi
```

> [!tip] 函数返回字符串
> 用 `echo` 配合 `$()` 捕获：
> ```bash
> get_greeting() { echo "Hello, $1!"; }
> msg=$(get_greeting "World")
> echo "$msg"
> ```

---

## 6.7 字符串处理

```bash
str="hello-world.txt"

echo "${str%.txt}"      # hello-world     (去掉最短匹配的后缀)
echo "${str%%.*}"       # hello-world     (去掉最长匹配的后缀)
echo "${str#*-}"        # world.txt       (去掉最短匹配的前缀)
echo "${str##*-}"       # txt             (去掉最长匹配的前缀)
echo "${str/hello/hi}"  # hi-world.txt    (替换)
echo "${#str}"           # 16              (长度)

# 默认值
echo "${VAR:-default}"  # VAR 未定义或为空时用 default
echo "${VAR:=default}"  # 同上，但同时赋给 VAR
```

---

## 6.8 常见陷阱

| 陷阱 | 错误写法 | 正确写法 |
|:---|:---|:---|
| 变量被当成分隔符 | `file = $1` | `file="$1"` |
| 空格导致判断出错 | `if [$a -eq 1]` | `if [[ $a -eq 1 ]]` |
| 未定义变量 | 忘了 `$*` | `set -u` |
| 管道中失败被忽略 | `grep ... \| sort \| head` | `set -o pipefail` |
| 路径中的空格 | `rm $file` | `rm "$file"` |

> [!danger] 永远引用变量（除非你有明确理由不引用）
> ```bash
> # 坏 —— 如果 filename="my file.txt"，会被当成两个参数
> rm $filename
> # 好 —— 始终用引号
> rm "$filename"
> ```

---

## 6.9 调试

```bash
# 方法一：set -x —— 每执行一行就打印出来
set -x
# ... 你的代码 ...
set +x

# 方法二：运行脚本时启用
$ bash -x myscript.sh

# 方法三：shellcheck —— 静态检查脚本
$ sudo apt install shellcheck
$ shellcheck myscript.sh
```

---

## 6.10 实战：三个脚本模板

### 日志清理脚本

```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="${1:-/var/log}"
DAYS="${2:-30}"

echo "Deleting logs older than $DAYS days in $LOG_DIR..."
find "$LOG_DIR" -name "*.log" -mtime "+$DAYS" -delete
echo "Done."
```

### 健康检查脚本

```bash
#!/bin/bash
set -euo pipefail

check_url() {
    local url="$1"
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q 200; then
        echo "✓ $url"
    else
        echo "✗ $url FAILED"
    fi
}

check_url "https://google.com"
check_url "https://github.com"
```

### 备份脚本

```bash
#!/bin/bash
set -euo pipefail

SRC="${1:?Usage: $0 <source_dir> [dest_dir]}"
DEST="${2:-/tmp/backup}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$DEST/backup_$TIMESTAMP.tar.gz"

mkdir -p "$DEST"
tar -czf "$BACKUP_FILE" "$SRC"
echo "Backup saved to: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"
```

---

## 🧪 本章综合练习

1. 写脚本 `greet.sh`，接受一个参数（名字），输出问候语。不传参数时提示用法。
2. 写脚本 `file-check.sh`，接受文件路径，判断它是文件/目录/不存在/符号链接并输出。
3. 写脚本 `loop-dirs.sh`，遍历 `/etc` 下所有 `.d` 结尾的目录，统计数量。
4. 用 `set -x` 调试一个出错脚本，定位问题行。
5. 用 `shellcheck` 检查你写的脚本。

---

## 📋 本章命令速查

| 语法 / 命令 | 作用 |
|:---|:---|
| `#!/bin/bash` | 指定解释器 |
| `$1` `$@` `$#` `$?` `$$` | 参数 / 退出码 / PID |
| `set -euo pipefail` | 安全模式 |
| `if [[ ... ]]; then ... fi` | 条件判断 |
| `for ... in ... do ... done` | 遍历 |
| `while [[ ... ]]; do ... done` | 循环 |
| `case ... in ... esac` | 多重选择 |
| `local name="$1"` | 函数内局部变量 |
| `"${var:-default}"` | 默认值 |
| `"${var%.txt}"` | 去后缀 |
| `bash -x script` | 调试模式 |
| `shellcheck` | 静态检查 |

---

> [!info] 继续学习
> - 速查表：[[06-shell-scripting/cheatsheet|Chapter 06 Cheatsheet]]
> - 上一章：[[05-processes/README|进程管理]]
> - 下一章：[[07-systemd-services/README|Systemd 与服务管理]]
