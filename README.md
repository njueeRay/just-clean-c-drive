# just-clean-c-drive

> **你的 C 盘不需要付费才能干净。**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/powershell/)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078d7.svg)](https://www.microsoft.com/windows)
[![Typical Freed Space](https://img.shields.io/badge/典型释放空间-15~50_GB-brightgreen.svg)](#能释放多少空间)

**Windows C 盘深度清理 PowerShell 脚本** — 开源、零安装、无广告、不收集数据。  
一行命令，彻底清理那些付费软件帮你清理的"垃圾"——而这些操作，Windows 系统本身就支持。

```powershell
irm https://raw.githubusercontent.com/njueeRay/just-clean-c-drive/main/clean-c-drive.ps1 | iex
```

> 或者克隆仓库后本地运行，代码完全透明，所有行为看得见。

---

## 为什么会有这个工具

你一定遇到过这样的场景：

C 盘爆红，剩余空间不足 10 GB。打开 360、腾讯电脑管家或某某清理大师，扫描半天，  
告诉你发现了 **30 GB 垃圾**，然后弹出一个对话框：

> _"升级 VIP，一键深度清理 ▶"_

**但那 30 GB，Windows 自己就能删。**

`DISM /StartComponentCleanup`、`cleanmgr /sagerun`、`vssadmin delete shadows`、  
`powercfg -h off` —— 微软官方文档里写得清清楚楚的命令，它们收在了付费功能背后。

**just-clean-c-drive** 把这些命令整理成一个有条理、分阶段、带 DryRun 预览的脚本，  
免费，开源，不装软件，不弹广告，不上传任何数据。

---

## 能释放多少空间

以下数据来自常见 Windows 10/11 用户实测场景。每台机器情况不同，DryRun 模式可先预览你的数字。

| 清理项目 | 典型释放量 | 说明 |
|---------|-----------|------|
| 系统临时文件 (Temp) | 0.5 ~ 3 GB | 用户 %TEMP% + C:\Windows\Temp |
| 浏览器缓存（Chrome/Edge/Firefox） | 0.5 ~ 5 GB | 四大主流浏览器全覆盖 |
| Windows Update 下载缓存 | 1 ~ 5 GB | 已安装更新不受影响 |
| **DISM WinSxS 组件压缩** | **2 ~ 8 GB** | 微软官方推荐操作，最大单项 |
| **休眠文件 hiberfil.sys** | **等于你的内存大小** | 16 GB 内存 = 释放约 16 GB |
| Windows.old 升级残留 | 10 ~ 25 GB | 系统大版本升级后遗留 |
| Microsoft Teams 缓存 | 1 ~ 5 GB | 重度用户可达 10 GB+ |
| JetBrains IDE 缓存与日志 | 0.5 ~ 5 GB | IntelliJ / PyCharm / WebStorm 等 |
| VSCode 缓存与旧工作区数据 | 0.2 ~ 2 GB | 含 90 天未访问的工作区存储 |
| 微信 / QQ 缓存 | 0.2 ~ 3 GB | 视聊天量和图片接收量 |
| Shadow Copy 旧还原点 | 1 ~ 10 GB | 保留最新 1 个，删除历史 |
| **开发者模式（-Dev）**：node_modules / Cargo / Maven / __pycache__ | **5 ~ 50 GB** | 活跃开发者单次可释放更多 |

**普通用户（运行阶段 1-3）：典型释放 15 ~ 40 GB**  
**开发者（运行全部阶段）：典型释放 30 ~ 80 GB**

---

## 和付费清理工具对比

| | just-clean-c-drive | 360 安全卫士 | 腾讯电脑管家 | CCleaner Pro |
|---|---|---|---|---|
| 价格 | **免费** | 免费（VIP 功能付费） | 免费（VIP 功能付费） | ¥139/年 |
| 清理 WinSxS 组件存储 | ✅ | 🔒 付费 / 不支持 | 🔒 付费 | ✅（付费） |
| 关闭休眠释放 hiberfil.sys | ✅ | ⚠️ 隐藏入口 | ⚠️ 隐藏入口 | ❌ |
| 清理 Windows Update 缓存 | ✅ | ✅ | ✅ | ✅（付费） |
| 清理开发者依赖（node_modules 等） | ✅ | ❌ | ❌ | ❌ |
| DryRun 预览（先看后删） | ✅ | ❌ | ❌ | ❌ |
| 代码完全透明可审计 | ✅ | ❌ | ❌ | ❌ |
| 不收集用户数据 | ✅ | ⚠️ 疑问 | ⚠️ 疑问 | ⚠️ 疑问 |
| 后台常驻进程 | **无** | ✅（占内存） | ✅（占内存） | ✅（占内存） |
| 安装包大小 | **0 MB（无需安装）** | ~200 MB | ~150 MB | ~50 MB |

> WinSxS 压缩、`cleanmgr`、休眠管理 —— 这些都是 **Windows 系统内置 API**，  
> 任何工具收费提供它们，本质上是在向你销售一个调用系统命令的包装界面。

---

## 快速开始

```powershell
# 1. 先预览 — 不删除任何东西，只显示预计释放空间
.\clean-c-drive.ps1 -DryRun

# 2. 交互模式（默认） — 每阶段询问确认，推荐新用户使用
.\clean-c-drive.ps1

# 3. 开发者模式 — 额外清理 node_modules / pip cache / cargo / ESP-IDF 等
.\clean-c-drive.ps1 -Dev

# 4. 无人值守 — 自动确认所有阶段（CI/定期任务场景）
.\clean-c-drive.ps1 -Unattended
```

> 脚本自动检测权限，非管理员时一键提权重启，无需手动操作。

---

## 清理范围

| 阶段 | 内容 | 风险等级 |
|------|------|---------|
| 阶段 1 安全层 | Temp 文件、浏览器缓存、Windows 系统缓存、WER 报告、Prefetch、Delivery Optimization | 🟢 安全 |
| 阶段 2 深度层 | Windows Update 缓存、WinSxS 压缩、Shadow Copy、休眠文件、Windows.old | 🟡 每项单独确认 |
| 阶段 3 应用层 | Teams、VSCode、JetBrains、npm/pip、微信/QQ、WPS、Scoop/Chocolatey | 🟡 每项单独确认 |
| 阶段 4 开发者 | ESP-IDF 工具链、__pycache__、Cargo、Maven、node_modules（需 `-Dev`） | 🟠 谨慎，按需开启 |

---

## 核心特性

- ✅ **DryRun 模式** — 扫描并预估可释放空间，零风险预览
- ✅ **分阶段确认** — 每个阶段询问，危险操作二次确认，不偷偷删文件
- ✅ **自动日志** — 每次运行保存完整日志到 `%TEMP%\clean-c-drive-*.log`
- ✅ **自动提权** — 检测非管理员时自动重启为管理员模式，保留所有参数
- ✅ **释放量统计** — 运行结束显示总释放空间 + C 盘前后对比
- ✅ **代码可审计** — 200 行 PowerShell，没有二进制，没有网络请求，看得懂每一行

---

## 参数说明

| 参数 | 说明 |
|------|------|
| `-DryRun` | 仅扫描预览，不删除任何文件 |
| `-Unattended` | 无人值守，自动确认所有阶段 |
| `-Dev` | 启用开发者专项清理（阶段 4） |

---

## 系统要求

- Windows 10 / 11
- PowerShell 5.1+（系统自带，无需安装）
- 管理员权限（脚本自动请求）

---

## Contributing

欢迎 PR 和 Issue。常见贡献方向：

- 新增清理项目（附上路径来源说明）
- 补充 Pester 单元测试
- 适配非英文系统路径

详见 [CONTRIBUTING.md](CONTRIBUTING.md)（待补充）。

---

## License

MIT © [njueeRay](https://github.com/njueeRay) — 随便用，随便改，不要删署名就好。
