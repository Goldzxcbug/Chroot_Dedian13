#!/system/bin/sh

MODDIR=${0%/*}
[ -f "${MODDIR}/config.prop" ] && . "${MODDIR}/config.prop"

: "${MOUNT_POINT:?请先设置 MOUNT_POINT}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

bllog() {
    printf "%b\n" "$*"
}

safe_umount() {
    local mnt="$1"
    local desc="$2"
    if ! grep -q " $mnt " /proc/mounts; then
        return 0
    fi
    if umount "$mnt" 2>/dev/null; then
        bllog "${GREEN}✅ 已卸载 $desc${NC}"
        return 0
    fi

    sleep 1
    if umount "$mnt" 2>/dev/null; then
        bllog "${GREEN}✅ 已卸载 $desc${NC}"
        return 0
    fi

    if umount -l "$mnt" 2>/dev/null; then
        bllog "${YELLOW}⚠️ 已强制懒卸载 $desc${NC}"
        return 0
    fi

    bllog "${RED}❌ 无法卸载 $desc${NC}"
}

bllog "🔎 正在结束 chroot 内的进程..."
REAL_MP=$(readlink -f "$MOUNT_POINT")

for proc_root in /proc/[0-9]*/root; do
    [ -L "$proc_root" ] || continue
    
    target=$(readlink "$proc_root" 2>/dev/null)
    if [ "$target" = "$REAL_MP" ] || [ "$target" = "$REAL_MP/" ]; then
        pid=$(echo "$proc_root" | cut -d'/' -f3)
        
        if [ "$pid" -gt 1000 ] 2>/dev/null; then
            bllog "⚡ 结束进程 PID: $pid"
            kill -15 "$pid" 2>/dev/null
            sleep 0.1
            kill -9 "$pid" 2>/dev/null
        fi
    fi
done

bllog "📦 正在卸载挂载点..."

grep "$REAL_MP" /proc/mounts | awk '{print $2}' | sort -r | uniq | while read -r m; do
    case "$m" in
        "$REAL_MP"*) safe_umount "$m" "$m" ;;
    esac
done

bllog "✅ 全部卸载尝试完毕"
