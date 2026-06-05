# Linux 系统学习库 / Linux System Learning Lab

> [!info] 学习路线
> 从零基础到系统管理，每章包含：**概念讲解 → 实操示例 → 练习脚本（运行即反馈）→ 速查表**。
>
> From zero to system administration. Each chapter: **concept → examples → verifiable exercises → cheatsheet**.

---

## 环境要求 / Requirements

> [!tip] 你需要准备
> - Linux 虚拟机或实体机（Ubuntu 22.04+ / Debian 12+ / CentOS 9+ 均可）
> - A Linux VM or bare-metal machine (any modern distro works)

```bash
# 初始化练习环境 / Initialize lab environment
git clone https://github.com/yangqirong6-bot/linux-learning.git
cd linux-learning
bash scripts/setup-lab.sh
```

---

## 章节目录 / Chapters

| # | 章节 Chapter | 内容 Content | 状态 Status |
|---|-------------|-------------|:---:|
| 01 | [[01-cli-basics/README\|CLI 基础与 Shell 入门]] | Shell、快捷键、命令结构、man/help | ✅ |
| 02 | [[02-file-system/README\|文件系统与路径]] | 目录结构、文件类型、挂载、inode、链接 | ✅ |
| 03 | [[03-text-processing/README\|文本处理三剑客]] | grep、sed、awk、正则表达式、vim 基础 | ✅ |
| 04 | [[04-users-permissions/README\|用户与权限]] | UID/GID、文件权限、sudo、ACL、suid | ✅ |
| 05 | [[05-processes/README\|进程管理]] | ps/top/htop、信号、作业控制、nice、cgroups | ✅ |
| 06 | [[06-shell-scripting/README\|Shell 脚本编程]] | 变量、条件、循环、函数、调试、常见陷阱 | ✅ |
| 07 | [[07-systemd-services/README\|Systemd 与服务管理]] | unit 文件、journalctl、timer、target、日志 | ✅ |
| 08 | [[08-networking/README\|网络基础与服务]] | TCP/IP、ss/ip/curl、防火墙、SSH、nginx 入门 | ✅ |
| 09 | [[09-security/README\|安全加固]] | 更新策略、fail2ban、密钥管理、审计、SELinux | ✅ |
| 10 | [[10-kernel-performance/README\|内核与性能调优]] | /proc、strace、perf、内存管理、eBPF 入门 | ✅ |

---

## 使用方式 / How to Use

> [!example] 学习流程 / Workflow
> 1. **Obsidian** 里阅读教程，复制示例命令
> 2. **虚拟机终端** 里粘贴运行，**必须动手敲**
> 3. 进入 `exercises/` 目录运行 `bash check.sh` 验证
> 4. 参考答案在 `exercises/solutions/` 目录
> 5. 查阅 `cheatsheet.md` 速记

---

## 约定 / Conventions

| 符号 Symbol | 含义 Meaning |
|:-----------|:------------|
| `$` | 普通用户命令提示符 / regular user prompt |
| `#` | root 命令提示符 / root prompt |
| `[...]` | 可选参数 / optional argument |
| `<...>` | 必填参数 / required argument |

> [!warning] 重要提醒
> `rm` 没有回收站！删了就没了。Linux 假设你知道自己在做什么。
>
> There is no recycle bin. Deletions are permanent. Linux assumes you know what you're doing.
