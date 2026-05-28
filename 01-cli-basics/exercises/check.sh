#!/usr/bin/env bash
# Chapter 01 — 练习验证脚本 / Exercise verification script
set -euo pipefail

LAB_DIR="$HOME/linux-lab"
PASS=0
FAIL=0
TOTAL=5

green() { echo -e "\033[0;32m$1\033[0m"; }
red()   { echo -e "\033[0;31m$1\033[0m"; }
check() {
    local desc="$1"; shift
    if "$@"; then
        green "  [PASS] $desc"
        ((PASS++))
    else
        red   "  [FAIL] $desc"
        ((FAIL++))
    fi
}

echo "============================================"
echo " Chapter 01 — CLI 基础练习检查"
echo "============================================"
echo ""

# Exercise 1
check "E1: 创建目录 chapter1/test/" \
    test -d "$LAB_DIR/temp/chapter1/test/"

# Exercise 2
check "E2: 创建文件 a.txt, b.txt, c.txt" \
    test -f "$LAB_DIR/temp/chapter1/a.txt" -a \
         -f "$LAB_DIR/temp/chapter1/b.txt" -a \
         -f "$LAB_DIR/temp/chapter1/c.txt"

# Exercise 3
check "E3: 提取含 apple 的行到 apple.txt" \
    test -f "$LAB_DIR/temp/chapter1/apple.txt" -a \
         "$(wc -l < "$LAB_DIR/temp/chapter1/apple.txt")" -ge 1

# Exercise 4
check "E4: 用 tail 查看前 3 行（反向实现）" \
    test -f "$LAB_DIR/temp/chapter1/first3.txt"

# Exercise 5
check "E5: man ls 查到了 -S 选项" \
    test -f "$LAB_DIR/temp/chapter1/ls_S_option.txt"

echo ""
echo "============================================"
echo " 结果 / Results: $PASS/$TOTAL 通过 (passed)"
if [ $FAIL -gt 0 ]; then
    red "  $FAIL 项未通过 / failed"
    echo "  参考 solutions/ 目录查看答案"
else
    green "  全部通过! / All passed!"
fi
echo "============================================"
