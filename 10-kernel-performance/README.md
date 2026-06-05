# 10 — 内核与性能调优 / Kernel & Performance

> [!info] 本章目标
> 学完这一章，你将能够：通过 `/proc` 文件系统查看系统状态、理解内存和 swap、用 `strace` 追踪程序行为、用 `perf` 和 `bpftrace` 做性能分析、定位 CPU 瓶颈和内存泄漏。
>
> **预计时间**：2-2.5 小时

---

## 10.1 `/proc` 文件系统：窥探内核的窗口

`/proc` 不占磁盘空间——它是内核在内存里创建的虚拟文件系统。每个数字目录是一个进程（PID），每个普通文件是一个内核参数的实时状态。

### 系统级统计

```bash
$ cat /proc/cpuinfo | grep "model name" | head -1
$ cat /proc/meminfo | head -5
```

```bash
$ cat /proc/loadavg
```
输出：
```text
1.23 0.87 0.65 2/485 20345
```

`1.23 0.87 0.65` 是最近 1/5/15 分钟的负载平均值。`2/485` = 当前 2 个进程在运行 / 总共 485 个线程。`20345` = 最新创建的 PID。

```bash
$ cat /proc/swaps           # swap 使用
$ cat /proc/mounts           # 所有挂载
$ cat /proc/uptime           # 系统启动了多少秒
```

### 进程级信息

```bash
$ ls /proc/$$/               # 当前 Shell 的所有运行时信息
```

| 文件 | 内容 |
|:---|:---|
| `/proc/<PID>/cmdline` | 进程的完整命令行 |
| `/proc/<PID>/environ` | 环境变量 |
| `/proc/<PID>/fd/` | 打开的文件描述符 |
| `/proc/<PID>/maps` | 内存映射（哪个库用了多少内存） |
| `/proc/<PID>/status` | 人类可读的进程状态 |
| `/proc/<PID>/limits` | 资源限制 |
| `/proc/<PID>/cgroup` | cgroup 信息 |

### 🧪 即时练习

```bash
$ cat /proc/cpuinfo | head -10
$ cat /proc/meminfo | head -10
$ cat /proc/loadavg
$ ls /proc/$$/fd/
$ cat /proc/$$/limits
```

---

## 10.2 内存管理

### 物理内存 vs 虚拟内存 vs Swap

```bash
$ free -h
```
输出：
```text
               total   used    free    shared  buff/cache   available
Mem:           7.8Gi   3.2Gi   1.1Gi   450Mi   3.5Gi        4.1Gi
Swap:          2.0Gi   100Mi   1.9Gi
```

| 列 | 含义 |
|:---|:---|
| total | 总内存 |
| used | 程序真正在用 |
| buff/cache | 系统借给磁盘缓存了——**程序需要时会拿回来**，不等于被占用了 |
| available | 程序真正能用的（free + 可回收的 cache） |
| Swap | 内存不够时写到硬盘上的区域（比内存慢很多） |

> [!important] `buff/cache` 不是浪费的内存
> Linux 把空闲内存用来缓存文件（加速后续读取）。如果程序需要，它会立刻归还。看内存够不够，看 `available`，不看 `free`。

### 谁在用内存？

```bash
$ ps aux --sort=-%mem | head -10
$ top  # 按 M 排序
```

### OOM Killer：内存不够时会有人被杀死

当系统和 swap 都没内存了，OOM Killer 会选一个进程杀掉来释放内存。

```bash
$ dmesg | grep -i "killed process"     # 看看有没有被 OOM 杀掉的
$ cat /proc/<PID>/oom_score              # OOM 分数（越高越容易被选中杀）
$ echo -1000 | sudo tee /proc/<PID>/oom_score_adj   # 保护这个进程不被杀
```

### 🧪 即时练习

```bash
$ free -h
$ vmstat 1 5           # 每秒采样一次内存/IO 统计，共 5 次
$ cat /proc/meminfo
```

---

## 10.3 `strace`：追踪程序在做什么

`strace` 显示程序调用的每个系统调用（syscall）——程序跟内核之间的每一次对话。

```bash
$ strace ls /tmp
```
输出（部分）：
```text
execve("/usr/bin/ls", ["ls", "/tmp"], ...) = 0
openat(AT_FDCWD, "/tmp", O_RDONLY|... ) = 3
getdents64(3, ...)                        = 168
write(1, "file1.txt\nfile2.txt\n", 24)    = 24
close(3)                                  = 0
exit_group(0)                             = ?
```

每一步都能看到：`execve` 启动程序 → `openat` 打开目录 → `getdents64` 读取目录条目 → `write` 输出到屏幕 → `exit_group` 退出。

### 常用选项

```bash
$ strace -c ls                    # 运行结束后按系统调用统计耗时
$ strace -e openat ls             # 只看 openat 调用
$ strace -e trace=network curl google.com    # 只看网络相关调用
$ strace -p 12345                 # 附着到一个已在运行的进程
$ strace -f -o trace.log make     # 追踪子进程，输出到文件
```

### 实战：程序打不开文件？strace 一看就知

```bash
$ strace -e openat cat /nonexistent 2>&1 | tail -5
```
输出：
```text
openat(AT_FDCWD, "/nonexistent", O_RDONLY) = -1 ENOENT (No such file or directory)
```

一目了然：文件不存在。

---

## 10.4 `lsof`：谁在用什么文件

在 Linux 里，"一切皆文件"——网络连接、硬件设备、管道全都是"文件"。`lsof`（List Open Files）能看清每个进程的所有文件使用。

```bash
$ lsof -p 12345                   # PID 12345 打开了什么？
$ lsof -u yang                    # yang 用户打开了什么？
$ lsof /var/log/syslog            # 谁在写这个日志？
$ lsof -i :80                     # 谁在占用 80 端口？
$ lsof -i tcp                     # 所有 TCP 连接
$ lsof +D /var/log                # /var/log 下所有打开的文件
```

### 实战：端口被占用，找到谁占的

```bash
$ lsof -i :3000
```
输出：
```text
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
node    12345 yang   23u  IPv4  54321      0t0  TCP *:3000 (LISTEN)
```

---

## 10.5 `perf` — CPU 性能剖析

```bash
$ sudo apt install linux-tools-common linux-tools-generic perf
```

### 实时统计

```bash
# 看当前 CPU 在忙什么
$ sudo perf top
```

`perf top` 像一个 CPU 专用的 `top`：显示哪些函数消耗 CPU 最多。

### 采样一个程序

```bash
$ sudo perf stat ls /               # 跑完显示统计
```
输出：
```text
Performance counter stats for 'ls /':
  3.25 msec  task-clock        #  0.971 CPUs utilized
    18      context-switches   #  5.538 K/sec
     1      cpu-migrations     #  0.308 K/sec
    89      page-faults        # 27.385 K/sec
    ...
```

### 采样并记录（用于事后分析）

```bash
$ sudo perf record ls /            # 记录 → 产生 perf.data
$ sudo perf report                 # 交互式查看
$ sudo perf script > trace.txt     # 文本导出
```

---

## 10.6 eBPF 和 bpftrace 入门

eBPF 是 Linux 内核里的沙箱——你可以在不修改内核的情况下，安全地往内核里注入观测代码。`bpftrace` 让你用简单的脚本语言写 eBPF 追踪。

```bash
$ sudo apt install bpftrace
```

### 一行追踪

```bash
# 追踪所有新进程的创建
$ sudo bpftrace -e 'tracepoint:syscalls:sys_enter_execve { printf("%s → %s\n", comm, str(args->filename)); }'

# 追踪所有文件打开操作
$ sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s → %s\n", comm, str(args->filename)); }'

# 统计谁在调用 read 最多
$ sudo bpftrace -e 'tracepoint:syscalls:sys_enter_read { @calls[comm] = count(); }'
# 按 Ctrl+C 停止，自动打印统计
```

> [!note] eBPF 不只是一个调试工具
> Cilium（容器网络）、Falco（安全监控）、Pixie（可观测性）这些现代基础设施工具的底层都跑在 eBPF 上。你不需要成为 eBPF 专家，但知道"内核可以安全地用 bpftrace 观测"就够了。

---

## 10.7 实战：定位性能瓶颈

### 场景一：CPU 飙升

```bash
# 1. 谁在吃 CPU？
$ top
# 2. 这进程在调用什么？
$ sudo perf top
# 3. 它卡在哪个系统调用？
$ sudo strace -c -p <PID>
# 或在运行期间采样
$ sudo perf record -g -p <PID> -- sleep 10
$ sudo perf report
```

### 场景二：内存泄漏

```bash
# 1. 谁内存持续增长？
$ top -o %MEM
# 2. 看它的内存映射
$ cat /proc/<PID>/status | grep -E "VmRSS|VmSize"
$ cat /proc/<PID>/maps | head -20
# 3. 跟踪它的内存分配（需要 bpftrace）
$ sudo bpftrace -e 'tracepoint:syscalls:sys_enter_mmap { @sizes[comm] = hist(arg2); }'
```

### 场景三：IO 很慢

```bash
# 1. 看 IO 等待
$ top    # 看 %wa（IO wait）
$ iostat -x 1
# 2. 谁在大量读写？
$ sudo iotop
# 3. strace 看来某个程序卡在哪个 read/write 上
$ sudo strace -p <PID> -e trace=read,write
```

---

## 🧪 本章综合练习

1. 查看 `/proc/meminfo` 和 `free -h`，理解 `available` vs `free`
2. 用 `strace ls /tmp` 观察一个简单命令的所有系统调用
3. 用 `lsof -i` 查看本机所有网络连接
4. 用 `perf top` 观察 CPU 消耗 Top 10 的函数（需要 root）
5. 用 `bpftrace` 追踪所有新进程的创建

---

## 📋 本章命令速查

| 命令 | 作用 |
|:---|:---|
| `cat /proc/cpuinfo` | CPU 信息 |
| `cat /proc/meminfo` | 内存信息 |
| `cat /proc/loadavg` | 负载 |
| `free -h` | 内存用量 |
| `vmstat 1` | 系统统计（实时） |
| `iostat -x 1` | 磁盘 IO 统计 |
| `iotop` | 磁盘 IO 进程排行 |
| `strace <cmd>` | 追踪系统调用 |
| `strace -c <cmd>` | 统计系统调用耗时 |
| `strace -p <PID>` | 附着到进程 |
| `lsof -p <PID>` | 进程打开的文件 |
| `lsof -i :<port>` | 占用端口的程序 |
| `perf top` | CPU 函数排行 |
| `perf stat` | 性能统计 |
| `perf record / report` | CPU 采样分析 |
| `bpftrace -e '...'` | eBPF 动态追踪 |
| `dmesg \| grep -i oom` | OOM 记录 |

---

> [!info] 继续学习
> - 速查表：[[10-kernel-performance/cheatsheet|Chapter 10 Cheatsheet]]
> - 上一章：[[09-security/README|安全加固]]
> - 🎉 **你已完成全部 10 章！**返回 [[../README|主目录]]
