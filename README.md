
# Debian 13 chroot 环境 for Android (高通设备)

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20(Qualcomm)-brightgreen)]()
[![Status](https://img.shields.io/badge/Status-Active-success)]()

在 Android 设备上通过 chroot 运行完整的 Debian 13 系统，支持 GPU 加速、Wine 以及图形化桌面。  
本项目专为**高通骁龙处理器**设备优化，已在 **一加 Pad 2 Pro** 和 **一加 Ace 3** 上通过测试。

---

## ⚠️ 重要警告

**仅限高通处理器设备使用！**  
**仅限高通处理器设备使用！**  
**仅限高通处理器设备使用！**  

若你的设备不是高通骁龙处理器，请不要尝试使用，否则可能无法正常工作。

---

## 📋 目录

- [功能特点](#功能特点)
- [硬件要求](#硬件要求)
- [快速开始](#快速开始)
  - [1. 准备工作](#1-准备工作)
  - [2. 解压文件](#2-解压文件)
  - [3. （可选）激活执行按钮](#3-可选激活执行按钮)
- [模块目录结构](#模块目录结构)
- [chroot 环境说明](#chroot-环境说明)
  - [GPU 加速驱动](#gpu-加速驱动)
  - [Wine 支持](#wine-支持)
- [Termux 环境配置](#termux-环境配置)
- [启动与使用](#启动与使用)
- [常见问题排查](#常见问题排查)
- [贡献与反馈](#贡献与反馈)
- [许可证](#许可证)

---

## ✨ 功能特点

- 完整的 Debian 13 (Trixie) 系统，基于 chroot 运行
- GPU 硬件加速，通过 Mesa for Android Container 提供
- 内置三个 Mesa 驱动版本，可自由切换
- Wine (Hangover) 支持，可运行部分 Windows 应用程序
- 图形化桌面（通过 Termux-X11 访问）
- 音频转发（AAudio / PulseAudio）
- 优化存储位置，避免拖慢开机速度

---

## 📱 硬件要求

- **处理器：** 高通骁龙（Snapdragon）  
- **存储空间：** 至少 30 GB 剩余空间（解压后占用约 10 GB，压缩包可选保留）  
- **已测试设备：** 一加 Pad 2 Pro、一加 Ace 3

---

## 🚀 快速开始

### 1. 准备工作
将分享的 `debian13_rootfs.tar.gz` 文件移动到手机以下目录：

/data/modules/chroot_debian13/


> 如果目录不存在，请手动创建。

### 2. 解压文件
进入目标目录并解压：
```bash
cd /data/modules/chroot_debian13/
tar -xzf debian13_rootfs.tar.gz
```

解压完成后，你可以选择保留或删除原始压缩包。

3. （可选）激活执行按钮

如果目录中有 action_.sh 文件，将其重命名为 action.sh，即可在文件管理器中直接点击执行：

```bash
mv action_.sh action.sh
```

---

🔗 模块目录结构

模块目录（/data/modules/chroot_debian13/）包含两个重要的软链接：

软链接 指向路径 说明
debian13 /data/media/.debian13 实际 chroot 根目录。放在 /data/media 避免开机卡在第一屏。
termux /data/user/0/com.termux/files/home Termux 用户目录，方便文件交换。

---

🧩 chroot 环境说明

GPU 加速驱动

· 驱动存放路径：/root/mesa-kgsl
· 内置三个版本，可通过 /root/up 脚本的第二行切换：
  · usr1：最新版 26.1.0
  · usr2：版本 26.0.0
  · usr3：较老版本 24.3.0
· 驱动来源：mesa-for-android-container Releases
· 如需更新驱动，下载新版驱动并解压覆盖到 /root/mesa-kgsl 即可。

Wine 支持

· 使用 Hangover 项目，可运行部分 Windows 应用程序。
· 具体兼容性请参考 Hangover 官方文档。

---

📱 Termux 环境配置

在 Termux 中执行以下命令安装必要组件：

```bash
pkg install x11-repo
pkg install pulseaudio termux-x11
```

音频后端默认使用 AAudio 模块，你也可以自行尝试 sles（修改相关脚本）。

---

▶️ 启动与使用

1. 确保 chroot 已开机
      通过模块脚本或其他方式启动 chroot 环境（具体取决于你的实现）。
2. 在 Termux 中开启转发服务
      执行以下命令开启音频和 X11 转发：
   ```bash
   bash on
   ```
3. SSH 连接到 chroot 环境
      例如：
   ```bash
   ssh root@127.0.0.1
   ```
   （具体端口请根据你的实际配置调整）
4. 在 chroot 内启动桌面
      登录后执行：
   ```bash
   bash up
   ```
5. 打开 Termux-X11 应用
      此时应能看到 Debian 桌面界面。

---

🛠️ 常见问题排查

Q1: 进入桌面后左上角出现白方块

解决方法： 打开任务栏，找到 xwayland to vido bridge 并将其关闭，或者直接卸载该组件。

Q2: 遇到其他奇怪问题（无法启动、卡顿等）

解决方法：

```bash
# 清除临时文件
rm -rf /data/media/.debian13/tmp/*
# 关闭 chroot 环境
# 重启手机
```

重启后问题大概率解决。

Q3: 音频无法正常工作

解决方法： 在 Termux 中杀掉后台进程，重新执行 bash on。

Q4: 桌面使用过程中突然卡住

解决方法： 给 Termux 应用授予 自启动权限 和 始终后台运行权限，避免被系统清理。

---

🤝 贡献与反馈

欢迎提交 Issues 和 Pull Requests。
如果你有其他设备成功运行，也欢迎告知，我会更新兼容设备列表。

---
