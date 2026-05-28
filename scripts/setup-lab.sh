#!/usr/bin/env bash
# Linux 学习环境初始化 / Lab environment setup
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Linux 学习环境初始化 / Lab Setup ===${NC}"
echo ""

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO="unknown"
fi

echo "Detected distribution: $DISTRO"

# Create lab working directory
LAB_DIR="$HOME/linux-lab"
if [ ! -d "$LAB_DIR" ]; then
    mkdir -p "$LAB_DIR"/{files,logs,scripts,backup,temp}
    echo -e "${GREEN}Created lab directory: $LAB_DIR${NC}"
else
    echo -e "${YELLOW}Lab directory already exists: $LAB_DIR${NC}"
fi

# Install common tools (adjust per distro)
install_tools() {
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update -qq
            sudo apt-get install -y -qq vim curl wget tree htop sysstat \
                iotop strace ltrace tcpdump ngrep jq shellcheck \
                man-db manpages manpages-dev > /dev/null 2>&1
            ;;
        centos|rhel|fedora|rocky|almalinux)
            sudo dnf install -y -q vim curl wget tree htop sysstat \
                iotop strace ltrace tcpdump jq ShellCheck \
                man-db man-pages > /dev/null 2>&1
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm --quiet vim curl wget tree htop sysstat \
                strace ltrace tcpdump jq shellcheck man-db man-pages > /dev/null 2>&1
            ;;
        *)
            echo -e "${YELLOW}Unknown distro, skipping tool installation${NC}"
            ;;
    esac
}

echo ""
echo "Installing lab tools..."
install_tools
echo -e "${GREEN}Tools installed.${NC}"

# Populate lab files for exercises
echo "Hello Linux World" > "$LAB_DIR/files/hello.txt"
echo -e "apple\nbanana\ncherry\napple pie\npineapple" > "$LAB_DIR/files/fruits.txt"
echo -e "line 1\nline 2\nLINE 3\nline 4\nLINE 5\nline 6" > "$LAB_DIR/files/lines.txt"
echo -e "user1:x:1001:1001::/home/user1:/bin/bash\nuser2:x:1002:1002::/home/user2:/bin/sh\nuser3:x:1003:1003::/home/user3:/bin/bash\nroot:x:0:0::/root:/bin/bash" > "$LAB_DIR/files/passwd.txt"
echo -e "192.168.1.1 - - [10/Jan/2024:13:55:36 +0000] GET /index.html 200\n192.168.1.2 - - [10/Jan/2024:13:56:01 +0000] POST /login 302\n10.0.0.1 - - [10/Jan/2024:13:56:45 +0000] GET /api/data 500\n192.168.1.1 - - [10/Jan/2024:13:57:12 +0000] GET /about 200\n10.0.0.2 - - [10/Jan/2024:13:58:00 +0000] GET / 404" > "$LAB_DIR/files/access.log"

# Create a simple script to modify
cat > "$LAB_DIR/scripts/hello.sh" << 'SCRIPT'
#!/bin/bash
echo "Hello, this is a test script"
echo "Current date: $(date)"
echo "Current user: $USER"
SCRIPT
chmod +x "$LAB_DIR/scripts/hello.sh"

echo ""
echo -e "${GREEN}=== Setup complete! ===${NC}"
echo ""
echo "Lab directory: $LAB_DIR"
echo ""
echo "Next step: Start with Chapter 01"
echo "  cd $(pwd)/../01-cli-basics"
echo "  cat README.md"
