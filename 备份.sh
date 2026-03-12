#!/usr/bin/env bash

# === 路径配置 ===
SOURCE_DIR="/data/media/.debian13"                 #要备份的区域
DEST_DIR="/data/adb/modules/chroot_debian13"       #备份后输出的文件
FILE_NAME="debian13_by1.tar.gz"                      #文件名
BACKUP_DEST="$DEST_DIR/$FILE_NAME"

# === 权限检查 ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ 错误: 请先输入 tsu"
  exit 1
fi

mkdir -p "$DEST_DIR"

echo "🚀 即将开始全文件备份 "
echo "需要时间一般10min以上，请耐心等待"
echo "📍 目标: $BACKUP_DEST"
echo "----------------------------------"
sleep 5
cd "$SOURCE_DIR" || exit
ALL_ITEMS=$(ls -A)

tar -cpzvf "$BACKUP_DEST" \
    --one-file-system \
    -C "$SOURCE_DIR" $ALL_ITEMS

if [ -f "$BACKUP_DEST" ] && [ $(stat -c%s "$BACKUP_DEST") -gt 10240 ]; then
    echo "----------------------------------"
    echo "✅ 全量克隆完成！"
    echo "📊 实际大小: $(du -h "$BACKUP_DEST" | cut -f1)"
else
    echo "----------------------------------"
    echo "❌ 备份失败！文件过小或未生成。请检查磁盘空间。"
fi
