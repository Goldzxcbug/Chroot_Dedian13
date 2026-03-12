#!/system/bin/sh

MODDIR=${0%/*}
[ -f "${MODDIR}/config.prop" ] && . "${MODDIR}/config.prop"

: "${MOUNT_POINT:?请先设置 MOUNT_POINT}"

TAG_FILE="${MODDIR}/.chroot_active"

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

umount_chroot() {
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
}

mountfs() {
    mount -t sysfs sys "${MOUNT_POINT}/sys"
    mount -t proc proc "${MOUNT_POINT}/proc"
    mount -t tmpfs tmpfs "${MOUNT_POINT}/tmp"
    mount -o bind /dev "${MOUNT_POINT}/dev"
    mount --bind /data/user/0/com.termux/files/usr/tmp "${MOUNT_POINT}/tmp"
    [ -d "/dev/shm" ] || mkdir -p /dev/shm
    [ -d "/dev/pts" ] || mkdir -p /dev/pts
    [ -d "/dev/net" ] || mkdir -p /dev/net
    mount -o rw,nosuid,nodev,mode=1777 -t tmpfs tmpfs /dev/shm
    mount -o bind /dev/shm "${MOUNT_POINT}/dev/shm"
    mount -o rw,nosuid,noexec,gid=5,mode=620,ptmxmode=000 -t devpts devpts /dev/pts
    mount -o bind /dev/pts "${MOUNT_POINT}/dev/pts"
    [ -e "/dev/fd" ] || ln -s /proc/self/fd /dev/
    [ -e "/dev/stdin" ] || ln -s /proc/self/fd/0 /dev/stdin
    [ -e "/dev/stdout" ] || ln -s /proc/self/fd/1 /dev/stdout
    [ -e "/dev/stderr" ] || ln -s /proc/self/fd/2 /dev/stderr
    [ -e "/dev/tty0" ] || ln -s /dev/null /dev/tty0
    [ -e "/dev/net/tun" ] || mknod /dev/net/tun c 10 200
}

mount_and_start() {
    rm -rf "${MOUNT_POINT}_old" 2>/dev/null
    mountfs
    chroot "${MOUNT_POINT}" /bin/bash -c 'mkdir -p /run/sshd && chown root:root /run/sshd && chmod 755 /run/sshd'
    chroot "${MOUNT_POINT}" /bin/bash -c "/usr/sbin/sshd -p ${SSH_PORT}" &
    while true; do
        if [ -d "/storage/emulated/0/Android/data" ]; then
            break
        fi
        sleep 3
    done
    if [ -n "$SDCARD" ]; then
        [ -d "${MOUNT_POINT}${SDCARD}" ] || mkdir -p "${MOUNT_POINT}${SDCARD}"
        mount /storage/emulated/0 "${MOUNT_POINT}${SDCARD}"
    fi
}

update_description() {
    local state="$1"
    local prop_file="$MODDIR/module.prop"
    [ -f "$prop_file" ] || return
    case "$state" in
        on)
            sed -i 's/^description=.*/description=当前状态:开机，SSH 连接命令 - "ssh root@127.0.0.1 -p 22"：端口: 22，用户: root，密码: root，本机访问：配置挂载后可通过 \/mnt\/sdcard 访问本机 sdcard 目录，注意：删除前必须取消挂载，否则清空挂载目录！/' "$prop_file"
            ;;
        off)
            sed -i 's/^description=.*/description=现在状态是关机,若要开机，点下方执行按钮/' "$prop_file"
            ;;
    esac
}

if [ -f "$TAG_FILE" ]; then
    bllog "🔴 关机中。。。"
    umount_chroot
    rm -f "$TAG_FILE"
    bllog "${GREEN}关机成功${NC}"
    update_description "off"
    sleep 1
else
    bllog "🟢 开机中。。。"
    mount_and_start
    touch "$TAG_FILE"
    bllog "${GREEN}开机成功${NC}"
    update_description "on"
    sleep 2
fi