#!/usr/bin/env bash
set -euo pipefail

ZRAM_SIZE="${ZRAM_SIZE:-8G}"
ZRAM_ALGORITHM="${ZRAM_ALGORITHM:-lz4}"
ZRAM_PRIORITY="${ZRAM_PRIORITY:-100}"
SWAPFILE_PATH="${SWAPFILE_PATH:-/swapfile}"
SWAPFILE_SIZE="${SWAPFILE_SIZE:-16G}"
SWAPFILE_PRIORITY="${SWAPFILE_PRIORITY:-10}"
SWAPPINESS="${SWAPPINESS:-120}"

ZRAM_CONF_DIR="/etc/systemd/zram-generator.conf.d"
ZRAM_CONF_FILE="$ZRAM_CONF_DIR/99-local-zram.conf"
DISABLE_ZSWAP_SERVICE="/etc/systemd/system/disable-zswap.service"
SYSCTL_CONF_FILE="/etc/sysctl.d/99-local-swap.conf"

usage() {
  cat <<'EOF'
用法:
  script/setup-arch-swap.sh
  script/setup-arch-swap.sh apply
  script/setup-arch-swap.sh status

说明:
  apply   安装 zram-generator，配置 8G zram + 16G swapfile，并关闭 zswap
  status  查看当前 swap、zram、zswap 状态

可选环境变量:
  ZRAM_SIZE=8G
  ZRAM_ALGORITHM=lz4
  ZRAM_PRIORITY=100
  SWAPFILE_PATH=/swapfile
  SWAPFILE_SIZE=16G
  SWAPFILE_PRIORITY=10
  SWAPPINESS=120
EOF
}

log() {
  printf '[setup-arch-swap] %s\n' "$*"
}

zram_size_mib() {
  numfmt --from=iec --to-unit=1048576 "$ZRAM_SIZE"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "缺少命令: $cmd" >&2
    exit 1
  fi
}

require_arch() {
  if [ ! -f /etc/os-release ]; then
    echo "无法识别系统发行版" >&2
    exit 1
  fi

  if ! grep -q '^ID=arch$' /etc/os-release; then
    echo "这个脚本按 Arch Linux 编写，当前系统不是 Arch" >&2
    exit 1
  fi
}

require_supported_rootfs() {
  local rootfs
  rootfs="$(findmnt -no FSTYPE /)"

  if [ "$rootfs" != "ext4" ]; then
    echo "这个脚本当前只按 ext4 根分区验证，当前文件系统是: $rootfs" >&2
    exit 1
  fi
}

require_sudo() {
  log "请求 sudo 权限"
  sudo -v
}

write_file_as_root() {
  local target="$1"
  local mode="${2:-644}"
  local dir

  dir="$(dirname "$target")"
  sudo mkdir -p "$dir"
  local tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  sudo install -m "$mode" "$tmp" "$target"
  rm -f "$tmp"
}

install_zram_generator() {
  if pacman -Q zram-generator >/dev/null 2>&1; then
    log "zram-generator 已安装"
    return
  fi

  log "安装 zram-generator"
  sudo pacman -S --needed zram-generator
}

configure_disable_zswap_service() {
  log "写入关闭 zswap 的 systemd 服务"
  write_file_as_root "$DISABLE_ZSWAP_SERVICE" 644 <<'EOF'
[Unit]
Description=Disable zswap before swap activation
DefaultDependencies=no
After=systemd-modules-load.service
Before=swap.target
Before=systemd-zram-setup@zram0.service
ConditionPathExists=/sys/module/zswap/parameters/enabled

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo 0 > /sys/module/zswap/parameters/enabled'

[Install]
WantedBy=swap.target
EOF
}

disable_zswap_now() {
  if [ ! -e /sys/module/zswap/parameters/enabled ]; then
    log "当前内核未暴露 zswap 开关，跳过运行时关闭"
    return
  fi

  local enabled
  enabled="$(cat /sys/module/zswap/parameters/enabled)"
  if [ "$enabled" = "N" ] || [ "$enabled" = "0" ]; then
    log "zswap 已关闭"
    return
  fi

  log "运行时关闭 zswap"
  sudo /usr/bin/bash -c 'echo 0 > /sys/module/zswap/parameters/enabled'
}

configure_zram_generator() {
  local zram_mib
  zram_mib="$(zram_size_mib)"

  log "写入 zram-generator 配置"
  write_file_as_root "$ZRAM_CONF_FILE" 644 <<EOF
[zram0]
zram-size = $zram_mib
compression-algorithm = $ZRAM_ALGORITHM
swap-priority = $ZRAM_PRIORITY
EOF
}

configure_sysctl() {
  log "写入 swappiness 配置"
  write_file_as_root "$SYSCTL_CONF_FILE" 644 <<EOF
vm.swappiness = $SWAPPINESS
EOF
  sudo sysctl --load "$SYSCTL_CONF_FILE" >/dev/null
}

swapfile_size_bytes() {
  numfmt --from=iec "$SWAPFILE_SIZE"
}

current_file_size_bytes() {
  local file="$1"
  stat -c '%s' "$file"
}

ensure_swapfile() {
  local target_size
  target_size="$(swapfile_size_bytes)"

  if [ -e "$SWAPFILE_PATH" ]; then
    local current_size
    current_size="$(current_file_size_bytes "$SWAPFILE_PATH")"

    if [ "$current_size" != "$target_size" ]; then
      log "现有 swapfile 大小与目标不一致，准备重建"
      if swapon --show=NAME --noheadings | tr -d ' ' | grep -Fxq "$SWAPFILE_PATH"; then
        sudo swapoff "$SWAPFILE_PATH"
      fi
      sudo rm -f "$SWAPFILE_PATH"
    fi
  fi

  if [ ! -e "$SWAPFILE_PATH" ]; then
    log "创建 swapfile: $SWAPFILE_PATH ($SWAPFILE_SIZE)"
    sudo fallocate -l "$SWAPFILE_SIZE" "$SWAPFILE_PATH"
    sudo chmod 600 "$SWAPFILE_PATH"
    sudo mkswap "$SWAPFILE_PATH"
  else
    log "swapfile 已存在，保留现有文件"
    sudo chmod 600 "$SWAPFILE_PATH"
  fi

  if ! swapon --show=NAME --noheadings | tr -d ' ' | grep -Fxq "$SWAPFILE_PATH"; then
    log "启用 swapfile"
    sudo swapon -p "$SWAPFILE_PRIORITY" "$SWAPFILE_PATH"
  fi

  log "写入 /etc/fstab 中的 swapfile 条目"
  sudo sed -i "\|^[[:space:]]*${SWAPFILE_PATH}[[:space:]]|d" /etc/fstab
  printf '%s\n' "$SWAPFILE_PATH none swap defaults,pri=$SWAPFILE_PRIORITY 0 0" |
    sudo tee -a /etc/fstab >/dev/null
}

restart_zram() {
  log "刷新 systemd 并启用 zram"
  sudo systemctl daemon-reload
  sudo systemctl enable --now disable-zswap.service

  if systemctl is-active --quiet systemd-zram-setup@zram0.service; then
    sudo systemctl restart systemd-zram-setup@zram0.service
  else
    sudo systemctl start systemd-zram-setup@zram0.service
  fi
}

show_status() {
  echo
  echo '== swapon --show =='
  swapon --show
  echo
  echo '== free -h =='
  free -h
  echo
  echo '== zramctl =='
  zramctl || true
  echo
  echo '== zswap =='
  if [ -e /sys/module/zswap/parameters/enabled ]; then
    printf 'enabled=%s\n' "$(cat /sys/module/zswap/parameters/enabled)"
    printf 'compressor=%s\n' "$(cat /sys/module/zswap/parameters/compressor)"
    printf 'max_pool_percent=%s\n' "$(cat /sys/module/zswap/parameters/max_pool_percent)"
  else
    echo 'zswap sysfs 参数不存在'
  fi
}

apply() {
  require_arch
  require_supported_rootfs

  require_command sudo
  require_command pacman
  require_command findmnt
  require_command fallocate
  require_command mkswap
  require_command swapon
  require_command swapoff
  require_command zramctl
  require_command numfmt
  require_command systemctl

  require_sudo

  install_zram_generator
  configure_disable_zswap_service
  disable_zswap_now
  configure_zram_generator
  configure_sysctl
  ensure_swapfile
  restart_zram

  log "配置完成，当前状态如下"
  show_status
}

main() {
  local action="${1:-apply}"

  case "$action" in
    apply)
      apply
      ;;
    status)
      show_status
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      echo "未知参数: $action" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
