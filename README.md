# Linux 系统学习库 / Linux System Learning Lab

从零基础到系统管理，每章包含：**概念讲解 → 实操示例 → 练习脚本（运行即反馈）→ 速查表**。

From zero to system administration. Each chapter: **concept → examples → verifiable exercises → cheatsheet**.

## 环境要求 / Requirements

- Linux 虚拟机或实体机（Ubuntu 22.04+ / Debian 12+ / CentOS 9+ 均可）
- A Linux VM or bare-metal machine (any modern distro works)

```bash
# 初始化练习环境 / Initialize lab environment
git clone https://github.com/yangqirong6-bot/linux-learning.git
cd linux-learning
bash scripts/setup-lab.sh
```

## 章节目录 / Chapters

| # | 章节 Chapter | 内容 Content | 状态 |
|---|-------------|-------------|------|
| 01 | [CLI 基础与 Shell 入门](01-cli-basics/README.md) | Shell、快捷键、命令结构、man/help | |
| 02 | [文件系统与路径](02-file-system/README.md) | 目录结构、文件类型、挂载、inode、链接 | |
| 03 | [文本处理三剑客](03-text-processing/README.md) | grep、sed、awk、正则表达式、vim 基础 | |
| 04 | [用户与权限](04-users-permissions/README.md) | UID/GID、文件权限、sudo、ACL、suid | |
| 05 | [进程管理](05-processes/README.md) | ps/top/htop、信号、作业控制、nice、cgroups | |
| 06 | [Shell 脚本编程](06-shell-scripting/README.md) | 变量、条件、循环、函数、调试、常见陷阱 | |
| 07 | [Systemd 与服务管理](07-systemd-services/README.md) | unit 文件、journalctl、timer、target、日志 | |
| 08 | [网络基础与服务](08-networking/README.md) | TCP/IP、ss/ip/curl、防火墙、SSH、nginx 入门 | |
| 09 | [安全加固](09-security/README.md) | 更新策略、fail2ban、密钥管理、审计、SELinux | |
| 10 | [内核与性能调优](10-kernel-performance/README.md) | /proc、strace、perf、内存管理、eBPF 入门 | |

## 使用方式 / How to Use

1. 按顺序阅读每章的 README.md
2. 在终端中跟着示例敲命令（**必须动手**）
3. 进入 `exercises/` 目录运行验证脚本：`bash check.sh`
4. 参考答案在 `exercises/solutions/` 目录
5. 查阅 `cheatsheet.md` 速记

Read each chapter's README.md in order. Type the examples in your terminal. Run `bash check.sh` in each exercises directory to verify your work. Solutions are in `exercises/solutions/`.

## 约定 / Conventions

- `$` 表示普通用户命令提示符 / denotes regular user prompt
- `#` 表示 root 命令提示符 / denotes root prompt
- `[...]` 表示可选参数 / denotes optional argument
- `<...>` 表示必填参数 / denotes required argument
