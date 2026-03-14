SKIPUNZIP=1

df -m /data | awk 'NR==2{if($4<30720){print "错误：/data 剩余空间不足30G"; exit 1}}' || exit 1

if ! pm path com.termux >/dev/null 2>&1; then
    echo "Termux 没有安装，中断解压"
    echo "可以打开本压缩包，里面有安装包"
    exit 1
fi

if ! pm path com.termux.x11 >/dev/null 2>&1; then
    echo "Termux:X11 没有安装，中断解压"
    echo "可以打开本压缩包，里面有安装包"
    exit 1
fi
unzip -o "$ZIPFILE" 'config.prop' -d "$MODPATH"
unzip -o "$ZIPFILE" 'module.prop' -d "$MODPATH"
unzip -o "$ZIPFILE" '备份.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" '关机.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" '解压.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" 'uninstall.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" 'action_.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" '阅读' -d "$MODPATH"

unzip -o "$ZIPFILE" 'on' -d "/data/user/0/com.termux/files/home"

source "$MODPATH/config.prop"

if [ -d "${MOUNT_POINT}/etc" ]; then
    umount ${MOUNT_POINT}/sys 2>/dev/null
    umount ${MOUNT_POINT}/proc 2>/dev/null
    umount ${MOUNT_POINT}/tmp 2>/dev/null
    umount ${MOUNT_POINT}/dev 2>/dev/null
    umount ${MOUNT_POINT}/dev/shm 2>/dev/null
    umount ${MOUNT_POINT}/dev/pts 2>/dev/null
    mv -f ${MOUNT_POINT} ${MOUNT_POINT}_old 2>/dev/null
fi

[ -d "$MOUNT_POINT" ] || mkdir -p "$MOUNT_POINT"

ln -s "$MOUNT_POINT" "$MODPATH/debian13" 2>/dev/null
ln -s "/data/user/0/com.termux/files/home" "$MODPATH/termux" 2>/dev/null

echo "一定要看本模块的阅读，打开压缩包看，或者重启去/data/adb/modules/chroot_debian13看"