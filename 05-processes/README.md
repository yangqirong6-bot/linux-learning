# 05 — 进程管理 / Process Management

> [!info] 本章目标
> 学完这一章，你将能够：查看和管理系统中的进程、理解进程状态、用信号控制进程（`kill`）、在前后台之间切换作业、监控 CPU 和内存、理解 cgroups 资源限制。
>
> **预计时间**：1.5-2 小时

---

## 5.1 什么是进程？

一个程序（program）是躺在硬盘上的二进制文件；一个进程（process）是这个程序在内存里的运行实例。你可以同时开三个终端窗口——它们运行的都是同一个 `bash` 程序，但是三个独立的进程。

```bash
$ ps aux | wc -l
```

### 每个进程的 ID：PID

每个进程启动时被分配一个数字——**PID**（Process ID）。PID 1 永远是 `systemd` 或 `init`，它是所有进程的祖先。

```bash
$ echo $$
```
输出：
```text
1843
```

```bash
$ ps -p 1 -o pid,comm
```
输出：
```text
  PID COMMAND
    1 systemd
```

### 父进程和子进程

```bash
$ ps -eo pid,ppid,comm | head -20
```
输出：
```text
  PID  PPID COMMAND
    1     0 systemd
  500     1 systemd-journal
 1843  1840 bash
 3956  1843 ps
```

`1843` (bash) 是 `3956` (ps) 的父进程。PPID 就是父进程的 PID。

### 🧪 即时练习

```bash
$ echo $$
$ ps aux | head -10
$ ps -eo pid,ppid,comm --forest | head -30
```

---

## 5.2 `ps` — 查看进程快照

```bash
$ ps aux
```
输出：
```text
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
yang      1843  0.0  0.5  10108  5316 pts/0    Ss   09:30   0:00 -bash
yang      4037  0.0  0.2  10796  2832 pts/0    R+   10:15   0:00 ps aux
root      1002  0.1  0.3 123456  3500 ?        Ssl  09:00   0:05 /usr/sbin/sshd
```

| 列 | 含义 |
|:---|:---|
| USER | 谁启动的 |
| PID | 进程 ID |
| %CPU / %MEM | CPU / 内存使用百分比 |
| VSZ / RSS | 虚拟内存 / 实际物理内存（KB） |
| TTY | 终端（`?`=后台服务, `pts/0`=终端窗口） |
| STAT | 进程状态 |
| TIME | 累计 CPU 时间 |

### 进程状态 (STAT)

| 状态 | 含义 |
|:---|:---|
| `R` | 正在运行 / 等待运行 |
| `S` | 睡眠（等待某个事件） |
| `D` | 不可中断睡眠（等磁盘 IO，**杀不掉**！） |
| `T` | 已停止（被 `Ctrl+Z` 暂停） |
| `Z` | 僵尸进程（死了但父进程还没收尸） |

附加标志：`s`=会话领导者, `l`=多线程, `+`=前台进程, `<`=高优先级, `N`=低优先级。

### 有用的 `ps` 组合

```bash
$ ps aux --sort=-%cpu | head -10     # 按 CPU 排序
$ ps aux --sort=-%mem | head -10     # 按内存排序
$ ps auxf                            # 树形显示父子关系
```

---

## 5.3 `top` / `htop` — 实时监控

`ps` 是快照。`top` 每 2 秒刷新一次：

```bash
$ top
```

| 按键 | 作用 |
|:---|:---|
| `q` | 退出 |
| `P` | 按 CPU 排序 |
| `M` | 按内存排序 |
| `k` | 杀进程（输入 PID） |
| `c` | 完整命令 |
| `1` | 展开所有 CPU 核心 |

`htop` 彩色、支持鼠标、更易用：

```bash
$ sudo apt install htop
$ htop
```

---

## 5.4 信号：和进程通信的唯一方式

### 常用信号

| 信号 | 编号 | 触发方式 | 作用 |
|:---|:---|:---|:---|
| SIGINT | 2 | `Ctrl+C` | 中断 |
| SIGTERM | 15 | `kill <PID>` | 优雅终止（"请你自己收工"） |
| SIGKILL | 9 | `kill -9 <PID>` | 暴力杀死（操作系统直接干掉） |
| SIGSTOP | 19 | `kill -STOP <PID>` | 暂停 |
| SIGCONT | 18 | `kill -CONT <PID>` | 继续 |
| SIGHUP | 1 | `kill -HUP <PID>` | 重读配置文件 |

```bash
$ kill -l
```

### SIGTERM vs SIGKILL

> [!important] 先发 SIGTERM(15)，不行再发 SIGKILL(9)
>
> - **SIGTERM(15)** = "请你收拾一下然后退出" —— 进程可以清理临时文件、关闭连接
> - **SIGKILL(9)** = 操作系统直接删进程 —— 无清理机会
>
> ```bash
> $ kill 1234                  # 先温柔
> $ sleep 3
> $ kill -9 1234              # 再强力
> ```

### 按名字杀进程

```bash
$ killall nginx
$ pkill -f "python app.py"
```

状态是 `D`（不可中断睡眠）的进程 **SIGKILL 都杀不掉**——它在等磁盘 IO 完成，只能等。

```bash
$ ps aux | awk '$8 ~ /D/'
```

---

## 5.5 作业控制：前台 / 后台

```bash
$ sleep 100 &               # & 直接后台运行
[1] 5678

$ sleep 100                 # 正在前台
# 按 Ctrl+Z                 # 暂停
[1]+  Stopped    sleep 100
$ bg                        # 放后台继续
$ jobs                      # 查看所有作业
[1]   Running    sleep 100 &
[2]-  Stopped    python script.py
```

```bash
$ fg %1                     # 调回前台
$ fg                        # 调当前作业（带 + 那个）
```

### 脱离终端：`nohup` / `disown`

```bash
$ nohup python long_task.py &   # 关终端也不死，输出 → nohup.out
$ python long_task.py &
$ disown                        # 已后台的作业脱离终端
```

---

## 5.6 `nice` / `renice` — 进程优先级

从 -20（最高优先级）到 19（最低优先级），默认是 0。

```bash
$ nice -n 19 gzip hugefile.tar         # 低优先级启动
$ renice -n 19 -p 5678                 # 降低已在运行的进程
$ sudo renice -n -5 -p 1234            # 提高优先级（需 root）
```

---

## 5.7 cgroups 资源限制入门

Docker、systemd 的容器资源限制底层都是 cgroups。

```bash
# 临时限制：只给 50% 单核 CPU
$ sudo systemd-run --user --scope -p CPUQuota=50% stress --cpu 1

# 限制内存：最多 256MB
$ sudo systemd-run --user --scope -p MemoryMax=256M myapp

# 查看当前进程的 cgroup
$ cat /proc/$$/cgroup
```

---

## 5.8 排查"服务器卡死了"

```bash
# 1. 谁在吃 CPU？
$ top
# 2. 谁在吃内存？
$ ps aux --sort=-%mem | head -10
# 3. 负载有多高？
$ uptime
$ cat /proc/loadavg          # 最近 1/5/15 分钟
```

> [!tip] load average 怎么看？
> - 等于 CPU 核数 → 刚好满负载
> - 远大于核数 → 严重过载，进程在排队
> - 远小于核数 → CPU 闲着
> - 4 核机器 load=4.0 正常，load=12.0 严重过载

---

## 🧪 本章综合练习

1. 用 `ps auxf` 看进程树，找出最大的那条分支
2. 开 `sleep 300 &` → 暂停 (`Ctrl+Z`) → 放后台 (`bg`) → 调回来 (`fg`) → 杀掉
3. 用 `top` 找出 CPU 占用最高的进程
4. 创建 100MB 测试文件然后用低优先级压缩：`nice -n 19 gzip testfile`
5. 用 `systemd-run` 限制一个 `stress --cpu 1` 只跑 25% CPU

---

## 📋 本章命令速查

| 命令 | 作用 |
|:---|:---|
| `echo $$` | 当前 Shell PID |
| `ps aux` | 进程快照 |
| `ps auxf` | 进程树 |
| `top` / `htop` | 实时监控 |
| `kill <PID>` | 发 SIGTERM |
| `kill -9 <PID>` | 强杀 |
| `kill -HUP <PID>` | 重读配置 |
| `killall` / `pkill` | 按名杀 |
| `Ctrl+Z` + `bg` | 暂停→后台 |
| `fg` | 前台 |
| `jobs` | 查看作业 |
| `nohup` / `disown` | 脱离终端 |
| `nice -n 19` | 低优先级 |
| `renice -n` | 改优先级 |
| `uptime` | 运行时间+负载 |
| `systemd-run` | cgroups 限制 |

---

> [!info] 继续学习
> - 速查表：[[05-processes/cheatsheet|Chapter 05 Cheatsheet]]
> - 上一章：[[04-users-permissions/README|用户与权限]]
> - 下一章：[[06-shell-scripting/README|Shell 脚本编程]]
