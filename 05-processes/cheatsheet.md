# 05 — Process Management 速查表 / Cheatsheet

## 进程查看 / Process Inspection
| 命令 | 说明 |
|:---|:---|
| `echo $$` | 当前 Shell PID |
| `ps aux` | 所有进程 |
| `ps aux --sort=-%cpu` | 按 CPU 排序 |
| `ps auxf` | 进程树 |
| `ps -eo pid,ppid,user,cmd` | 自定义输出列 |
| `pgrep <name>` | 按名查 PID |
| `top` | 实时监控 (`q` 退出, `P` CPU, `M` 内存) |
| `htop` | 彩色升级版 top |

## 信号 / Signals
| 命令 | 说明 |
|:---|:---|
| `kill <PID>` | SIGTERM 优雅终止 |
| `kill -9 <PID>` | SIGKILL 强杀 |
| `kill -HUP <PID>` | SIGHUP 重读配置 |
| `kill -STOP <PID>` | 暂停 |
| `kill -CONT <PID>` | 继续 |
| `killall <name>` | 按名字杀 |
| `pkill -f <pattern>` | 按命令行匹配杀 |

## 作业控制 / Job Control
| 命令 | 说明 |
|:---|:---|
| `<cmd> &` | 后台运行 |
| `Ctrl+Z` | 暂停前台进程 |
| `bg` | 继续在后台运行 |
| `fg` | 调到前台 |
| `fg %1` | 调到前台（指定作业号） |
| `jobs` | 查看作业列表 |
| `nohup <cmd> &` | 脱离终端运行 |
| `disown` | 作业脱离 Shell |

## 优先级 / Priority
| 命令 | 说明 |
|:---|:---|
| `nice -n 19 <cmd>` | 低优先级启动 |
| `renice -n 19 -p <PID>` | 改优先级 |
| `uptime` | 运行时间 + 负载 |

## 资源限制 / cgroups
| 命令 | 说明 |
|:---|:---|
| `systemd-run --scope -p CPUQuota=50% <cmd>` | 限制 CPU |
| `systemd-run --scope -p MemoryMax=256M <cmd>` | 限制内存 |
| `cat /proc/$$/cgroup` | 查看 cgroup |

## 进程状态 / Process States
| 状态 | 含义 |
|:---|:---|
| `R` | Running / Runnable |
| `S` | 可中断睡眠 |
| `D` | 不可中断睡眠（杀不掉） |
| `T` | 已停止 |
| `Z` | Zombie 僵尸 |

## 关停流程 / Shutdown
```bash
kill <PID>           # 1: SIGTERM
sleep 3              # 2: 等待
kill -9 <PID>        # 3: SIGKILL 最后一招
```
