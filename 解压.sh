#!/system/bin/sh

MODDIR=${0%/*}
[ -f "${MODDIR}/config.prop" ] && . "${MODDIR}/config.prop"
: "${MOUNT_POINT:?请先设置 MOUNT_POINT}"
[ -f "${MODDIR}/module.prop" ] && . "${MODDIR}/module.prop"
: "${id:?请先设置 id}"

TMP="/data/adb/modules/$id"  

mkdir -p "$MOUNT_POINT"

if [ ! -f "$TMP/debian13_rootfs.tar.gz" ]; then
    echo "错误：找不到 $TMP/debian13_rootfs.tar.gz"
    exit 1
fi
echo "解压中，大概需要30s，解压目录 $MOUNT_POINT"
if tar xzf "$TMP/debian13_rootfs.tar.gz" -C "$MOUNT_POINT"; then
    echo "解压成功，请前往解压目录 $MOUNT_POINT 查看,确保解压成功"
else
    echo "解压失败，请检查权限和空间"
    exit 1
fi