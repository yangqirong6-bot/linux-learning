# 06 — Shell Scripting 速查表 / Cheatsheet

## 脚本基础 / Basics
```bash
#!/bin/bash
set -euo pipefail     # 安全模式（所有脚本都加）
```
| 命令 | 说明 |
|:---|:---|
| `bash script.sh` | 运行脚本 |
| `bash -x script.sh` | 调试模式（每行打印） |
| `shellcheck script.sh` | 静态检查 |

## 变量 / Variables
| 语法 | 说明 |
|:---|:---|
| `name="value"` | 定义（等号两边无空格） |
| `"$name"` | 使用（双引号里展开） |
| `'$name'` | 不展开（单引号原样） |
| `"${name:-default}"` | 默认值 |
| `"${name%.txt}"` | 去后缀 |
| `"${name#prefix}"` | 去前缀 |

## 特殊变量 / Special Vars
| 变量 | 含义 |
|:---|:---|
| `$1` `$2` ... | 位置参数 |
| `$@` | 所有参数（独立） |
| `$#` | 参数个数 |
| `$?` | 上条命令退出码 |
| `$$` | 脚本 PID |

## 条件判断 / Conditionals
```bash
if [[ condition ]]; then
    ...
elif [[ condition ]]; then
    ...
else
    ...
fi
```
| 文件测试 | 字符串测试 | 数值测试 |
|:---|:---|:---|
| `-f` 普通文件 | `-z` 为空 | `-eq` 等于 |
| `-d` 目录 | `-n` 非空 | `-ne` 不等于 |
| `-e` 存在 | `=` 相等 | `-lt` 小于 |
| `-x` 可执行 | `!=` 不等 | `-gt` 大于 |
| `-r` 可读 | `=~` 匹配正则 | `-le`/`-ge` ≤/≥ |

## 循环 / Loops
```bash
for item in list; do ...; done
for (( i=0; i<10; i++ )); do ...; done
while [[ cond ]]; do ...; done
while IFS= read -r line; do ...; done < file
```

## 函数 / Functions
```bash
func() {
    local name="$1"
    echo "Hello, $name!"
}
result=$(func "Alice")   # 捕获输出
```

## 调试 / Debugging
| 方法 | 说明 |
|:---|:---|
| `set -x` | 开启逐行打印 |
| `bash -x script.sh` | 运行时调试 |
| `set -euo pipefail` | 遇错即停 |
| `shellcheck` | 静态分析 |
| `trap 'echo $LINENO' ERR` | 出错时打印行号 |

## 常见陷阱 / Pitfalls
- 变量**必须引号**：`rm "$file"` ✅  `rm $file` ❌
- 等号**不能有空格**：`a=1` ✅  `a = 1` ❌
- 条件用 `[[ ]]` 不是 `[ ]`
- `-aG` 不要忘记 `-a`（否则覆盖）
