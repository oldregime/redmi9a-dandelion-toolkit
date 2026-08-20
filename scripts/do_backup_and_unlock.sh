#!/bin/bash
DIR="/mnt/personal file/from w11/phone"
BACKUP_DIR="$DIR/backup_redmi9a"
mkdir -p "$BACKUP_DIR"

echo "=========================================================="
echo " Starting MediaTek BROM Listener for Redmi 9A (dandelion)"
echo " Backup destination: $BACKUP_DIR"
echo "=========================================================="

cd "$DIR/mtkclient"

echo "Step 1: Reading GPT and dumping critical partitions..."
python3 mtk.py r nvram,nvdata,proinfo,protect1,protect2,seccfg,devinfo,boot,recovery,vbmeta,md1img \
  "$BACKUP_DIR/nvram.img,$BACKUP_DIR/nvdata.img,$BACKUP_DIR/proinfo.img,$BACKUP_DIR/protect1.img,$BACKUP_DIR/protect2.img,$BACKUP_DIR/seccfg.img,$BACKUP_DIR/devinfo.img,$BACKUP_DIR/boot.img,$BACKUP_DIR/recovery.img,$BACKUP_DIR/vbmeta.img,$BACKUP_DIR/md1img.img"

echo "Step 2: Unlocking bootloader in seccfg..."
python3 mtk.py da seccfg unlock

echo "Step 3: Resetting device..."
python3 mtk.py reset
