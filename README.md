
# Debian 13 chroot 环境 for Android (高通设备)

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20(Qualcomm)-brightgreen)](https://developer.qualcomm.com/)
[![Downloads](https://img.shields.io/github/downloads/Goldzxcbug/Chroot_Dedian13/total)](https://github.com/Goldzxcbug/Chroot_Dedian13/releases)

在 Android 设备上通过 chroot 运行完整的 Debian 13 系统，支持 GPU 加速、Wine 以及图形化桌面。  
本项目专为 **高通骁龙处理器** 设备设计

Debian_rootfs.tar.gz 下载：

- [移动云盘下载（密码：bptz）](https://yun.139.com/shareweb/#/w/i/2tyagYDkonWij)
- [备用下载](https://cdn.goldzxcbug.top/d/%E7%A7%BB%E5%8A%A8%E4%BA%91%E7%9B%98/usb/apk/Ksu%E6%A8%A1%E5%9D%97/debian13_rootfs.tar.gz?sign=KQZ3pLoS38JSo4wANRRaJaRYl59E3lvKk-AZ3jfprXk=:0)

---

# ⚠️ 重要警告

**仅限高通处理器设备使用！**  
**仅限高通处理器设备使用！**  
**仅限高通处理器设备使用！**

若你的设备不是高通骁龙处理器，请不要尝试使用，否则可能无法正常工作。

---

# 📋 目录

- [功能特点](#功能特点)
- [硬件要求](#硬件要求)
- [快速开始](#快速开始)
  - [准备工作](#准备工作)
  - [解压文件](#解压文件)
  - [激活执行按钮](#激活执行按钮)
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

# 功能特点

- 完整的 **Debian 13 (Trixie)** 系统，基于 chroot 运行
- GPU 硬件加速，通过 **Mesa for Android Container**
- 内置 **三个 Mesa 驱动版本，可自由切换**
- **Wine (Hangover)** 支持，可运行部分 Windows 应用
- 图形化桌面（通过 **Termux-X11** 访问）
- 音频转发（AAudio / PulseAudio）
- 优化存储位置，避免拖慢开机速度

---

# 硬件要求

**处理器**

高通骁龙（Snapdragon）

**存储空间**

至少 **30GB 剩余空间**

- 解压后约 **10GB**
- 压缩包可选择删除

**已测试设备**

- OnePlus Pad 2 Pro
- OnePlus Ace 3
- Redmi K60
- Redmi Note 12 Turbo
- Xiaomi Pad 7 Pro
---

# 快速开始

## 准备工作

将分享的 `debian13_rootfs.tar.gz` 文件移动到：


/data/adb/modules/chroot_debian13/



如果目录不存在，请手动创建。

---

## 解压文件

进入目录执行解压脚本解压：
```
bash 解压.sh
```


解压完成后：

* 默认保留压缩包
* 可以手动删除压缩包释放空间

---

## 激活执行按钮

目录中存在 `action_.sh` 文件：

```bash
mv action_.sh action.sh
```

这样就可以在文件管理器中 **直接点击执行脚本**。
![](https://www.helloimg.com/i/2026/03/14/69b521fdb91a9.jpg)

---

# 模块目录结构

模块目录：

```
/data/adb/modules/chroot_debian13/
```

包含两个重要软链接：

| 软链接      | 指向路径                               | 说明            |
| -------- | ---------------------------------- | ------------- |
| debian13 | /data/media/.debian13              | 实际 chroot 根目录 |
| termux   | /data/user/0/com.termux/files/home | Termux 用户目录   |

将 rootfs 放在 `/data/media` 可以：

* 避免系统扫描
* 防止开机卡第一屏时间过长

---

# chroot 环境说明

## GPU 加速驱动

驱动路径：

```
/root/mesa-kgsl
```

内置三个版本：

| 名称   | 版本          |
| ---- | ----------- |
| usr1 | Mesa 26.1.0 |
| usr2 | Mesa 26.0.0 |
| usr3 | Mesa 24.3.0 |

切换方式：

编辑脚本：

```
/root/up
```

修改第二行选择对应版本。

驱动来源：

[Mesa for Android Container Releases](https://github.com/lfdevs/mesa-for-android-container/releases/)

如需更新：

下载新版驱动后解压到：

```
/root/mesa-kgsl
```

---

## Wine 支持

使用项目：

[**Wine-Hangover**](https://github.com/AndreRH/hangover)

特点：

* ARM64 → x86 Windows 转换
* 可以运行部分 Windows 软件

具体兼容性请参考 Hangover 官方文档。

---

# Termux 环境配置

安装组件：

```bash
pkg install x11-repo
pkg install pulseaudio termux-x11
```

默认音频后端：

```
AAudio
```

也可以修改脚本使用：

```
sles
```

---

# 启动与使用

## 启动 chroot

通过模块脚本启动 chroot。

具体方式取决于你的实现。

---

## 启动转发服务

在 Termux 中执行：

```bash
bash on
```

作用：

* 启动 PulseAudio
* 启动 X11 转发

---

## SSH 连接

连接 chroot：

```bash
ssh root@127.0.0.1
```

端口根据配置决定。

---

## 启动桌面

登录后执行：

```bash
bash up
```

---

## 打开 Termux-X11

打开 **Termux-X11 应用**。

此时应该可以看到 **Debian 图形桌面**。
![](https://www.helloimg.com/i/2026/03/14/69b524d9bd091.jpg)


---

#  常见问题排查

## 桌面左上角出现白方块
![](https://www.helloimg.com/i/2026/03/14/69b525bb67a62.jpg)

解决方法：

关闭任务栏中的：

```
xwayland to video bridge
```
![](https://www.helloimg.com/i/2026/03/14/69b525bb38d7c.jpg)

或者直接卸载该组件。

---

## 系统出现奇怪问题

例如：

* 桌面无法启动
* 卡顿
* 程序异常

执行：

```bash
rm -rf /data/media/.debian13/tmp/*
```

然后：

1. 关闭 chroot
2. 重启手机

通常可以解决。

---

## 音频无法工作

在 Termux 中：

```bash
pkill pulseaudio
bash on
```

重新启动音频服务。

---

## 桌面运行时突然卡死

原因：

Android 系统杀后台。

解决方法：

给 **Termux** 授予：

* 自启动权限
* 始终后台运行权限

避免被系统清理。

---

## 用的不是官方termux和本项目的termux

会导致$DISPLAY is not set or cannot connect to the X server.

解决方法:

打开模块目录：/data/adb/modules/chroot_debian13/（默认目录）的action.sh文件
将71行的/data/user/0/com.termux/files/usr/tmp 改成"/data/user/0/你的第三方termux包名/files/usr/tmp"（不一定在/files/usr/tmp）
![](https://www.helloimg.com/i/2026/03/14/69b52893d6199.jpg)
---

# 贡献与反馈

欢迎：

* 提交 **Issue**
* 提交 **Pull Request**

如果你在 **其他设备成功运行**，欢迎反馈，我会更新兼容设备列表。

---

# 许可证

本项目使用 **MIT License**。

