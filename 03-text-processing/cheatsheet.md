# 03 — Text Processing 速查表 / Cheatsheet

## grep
| 命令 | 说明 |
|------|------|
| `grep "pat" file` | 搜索 pattern / search |
| `grep -i "pat" file` | 忽略大小写 / ignore case |
| `grep -v "pat" file` | 反向匹配 / invert |
| `grep -r "pat" dir/` | 递归 / recursive |
| `grep -n "pat" file` | 显示行号 / line numbers |
| `grep -E "(a|b)" file` | 扩展正则 / extended regex |
| `grep -o "pat" file` | 只输出匹配 / only match |
| `grep -A3 -B2 "pat" file` | 上下文 / context |

## sed
| 命令 | 说明 |
|------|------|
| `sed 's/old/new/g'` | 全局替换 / global replace |
| `sed '/pat/d' file` | 删除匹配行 / delete line |
| `sed '/^$/d' file` | 删除空行 / delete blanks |
| `sed -n '5,10p' file` | 打印 5-10 行 / print lines |
| `sed -i 's/a/b/g' file` | 原地修改 / in-place edit |
| `sed 's/:.*//'` | 删除 `:` 及之后所有 / delete from : |

## awk
| 命令 | 说明 |
|------|------|
| `awk '{print $1}' file` | 第 1 列 / column 1 |
| `awk -F: '{print $1,$3}'` | 自定义分隔符 / custom FS |
| `awk '$3 > 100' file` | 条件过滤 / conditional |
| `awk '{s+=$1} END {print s}'` | 第 1 列求和 / sum col 1 |
| `awk '{a[$1]++} END {for(k in a) print a[k],k}'` | 分组统计 / group count |
| `awk 'NR>=5 && NR<=10' file` | 行范围 / line range |

## 组合工具 Combo Tools
| 命令 | 说明 |
|------|------|
| `sort -n` | 数字排序 / numeric |
| `sort -rn` | 数字倒序 / reverse numeric |
| `sort -u` | 去重 / unique |
| `uniq -c` | 计数去重 / count & dedup |
| `cut -d: -f1` | 按分隔符切列 / cut by delimiter |
| `wc -l` | 统计行数 / count lines |
| `xargs` | stdin→命令参数 / to args |
| `tee` | 输出到屏幕+文件 / to stdout & file |
