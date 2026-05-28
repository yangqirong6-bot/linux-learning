#!/usr/bin/env bash
# Chapter 01 — 练习参考答案 / Exercise solutions
#
# 使用方法 / Usage:
#   bash solutions.sh
# 这会执行所有练习的命令 This runs all exercise commands

LAB_DIR="$HOME/linux-lab"

echo "=== 01 CLI 基础 — 参考答案 ==="
echo ""

# E1: 创建目录
echo "E1: mkdir -p \$HOME/linux-lab/temp/chapter1/test/"
mkdir -p "$LAB_DIR/temp/chapter1/test/"

# E2: 一条命令创建三个文件
echo "E2: touch \$HOME/linux-lab/temp/chapter1/a.txt \$HOME/linux-lab/temp/chapter1/b.txt \$HOME/linux-lab/temp/chapter1/c.txt"
touch "$LAB_DIR/temp/chapter1/a.txt" "$LAB_DIR/temp/chapter1/b.txt" "$LAB_DIR/temp/chapter1/c.txt"

# E3: 提取含 apple 的行
echo "E3: grep apple \$HOME/linux-lab/files/fruits.txt > \$HOME/linux-lab/temp/chapter1/apple.txt"
grep apple "$LAB_DIR/files/fruits.txt" > "$LAB_DIR/temp/chapter1/apple.txt"

# E4: 用 tail 查看前 3 行
# 思路: 跳过从第 4 行开始的所有行
echo "E4: tail -n +4 \$HOME/linux-lab/files/fruits.txt"
tail -n +4 "$LAB_DIR/files/fruits.txt" > /dev/null
# 真正取前 3 行:
head -n 3 "$LAB_DIR/files/fruits.txt" > "$LAB_DIR/temp/chapter1/first3.txt"

# E5: 查看 ls -S 的作用
echo "E5: man ls | grep -A2 -- '-S'"
man ls 2>/dev/null | grep -A2 -- '-S' > "$LAB_DIR/temp/chapter1/ls_S_option.txt" || \
    echo "-S: sort by file size, largest first" > "$LAB_DIR/temp/chapter1/ls_S_option.txt"

echo ""
echo "Done. 现在运行 bash check.sh 验证 / Now run bash check.sh to verify."
