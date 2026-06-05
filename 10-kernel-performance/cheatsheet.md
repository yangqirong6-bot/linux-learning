# 10 — Kernel & Performance 速查表 / Cheatsheet

## /proc 文件系统
| 文件 | 内容 |
|:---|:---|
| `/proc/cpuinfo` | CPU 信息 |
| `/proc/meminfo` | 内存信息 |
| `/proc/loadavg` | 负载 |
| `/proc/<PID>/cmdline` | 进程命令行 |
| `/proc/<PID>/fd/` | 打开的文件描述符 |
| `/proc/<PID>/status` | 进程状态 |
| `/proc/<PID>/maps` | 内存映射 |
| `/proc/<PID>/cgroup` | cgroup |
| `/proc/<PID>/oom_score` | OOM 分数 |

## 内存 / Memory
| 命令 | 说明 |
|:---|:---|
| `free -h` | 内存用量 |
| `vmstat 1` | 内存/IO 实时采样 |
| `cat /proc/meminfo` | 详细内存 |
| `dmesg \| grep -i "killed"` | OOM 记录 |
| `echo -1000 > /proc/<PID>/oom_score_adj` | 保护进程免杀 |

## strace
| 命令 | 说明 |
|:---|:---|
| `strace <cmd>` | 追踪所有系统调用 |
| `strace -c <cmd>` | 统计耗时 |
| `strace -e openat <cmd>` | 只看文件操作 |
| `strace -e trace=network <cmd>` | 只看网络 |
| `strace -p <PID>` | 附着到进程 |
| `strace -f -o out.log <cmd>` | 含子进程，输出到文件 |

## lsof
| 命令 | 说明 |
|:---|:---|
| `lsof -p <PID>` | 进程打开了什么 |
| `lsof -u <user>` | 用户打开了什么 |
| `lsof -i :<port>` | 谁在用这个端口 |
| `lsof -i tcp` | 所有 TCP 连接 |
| `lsof /path/to/file` | 谁在访问这个文件 |

## perf
| 命令 | 说明 |
|:---|:---|
| `perf top` | CPU 函数实时排行 |
| `perf stat <cmd>` | 性能统计 |
| `perf record <cmd>` | 采样记录 |
| `perf report` | 查看记录 |
| `perf record -g -p <PID> -- sleep 10` | 采样进程 10 秒 |

## IO / Disk
| 命令 | 说明 |
|:---|:---|
| `iostat -x 1` | 磁盘 IO 统计 |
| `iotop` | 磁盘 IO 进程排行 |
| `lsblk` | 块设备列表 |
| `df -h` | 磁盘空间 |
| `du -sh dir/` | 目录大小 |

## bpftrace 一行追踪
```bash
# 追踪新进程
bpftrace -e 'tracepoint:syscalls:sys_enter_execve { printf("%s → %s\n", comm, str(args->filename)); }'

# 统计进程创建次数
bpftrace -e 'tracepoint:syscalls:sys_enter_execve { @[comm] = count(); }'

# 追踪文件打开
bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s → %s\n", comm, str(args->filename)); }'
```

## 性能瓶颈速查 / Quick Diagnosis
| 症状 | 第一步 |
|:---|:---|
| CPU 高 | `top` → `perf top` → `strace -c -p <PID>` |
| 内存持续涨 | `top -o %MEM` → `/proc/<PID>/status` |
| IO 慢 | `top` (看 %wa) → `iostat` → `iotop` |
| 程序卡住 | `strace -p <PID>` 看卡哪个调用 |
| 端口被占 | `lsof -i :port` |
