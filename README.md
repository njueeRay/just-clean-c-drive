# just-clean-c-drive

> **Windows C 盘深度清理工具** — PowerShell 脚本，开箱即用，安全分阶段，支持 DryRun 预览。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/powershell/)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078d7.svg)](https://www.microsoft.com/windows)

---

## 快速开始

```powershell
# 预览模式（不删除任何东西，只显示预计释放空间）
.\clean-c-drive.ps1 -DryRun

# 交互模式（默认，每阶段询问确认）
.\clean-c-drive.ps1

# 开发者模式（额外清理 node_modules / pip cache / cargo 等）
.\clean-c-drive.ps1 -Dev

# 无人值守（自动确认所有阶段，慎用）
.\clean-c-drive.ps1 -Unattended
```

> **注意：** 脚本会自动请求管理员权限，部分阶段（如 WinSxS、休眠文件）需要管理员才能执行。

---

## 清理范围

| 阶段 | 内容 | 风险等级 |
|------|------|---------|
| 阶段 1 安全层 | Temp 文件、浏览器缓存、Windows 系统缓存、WER 报告 | 🟢 安全 |
| 阶段 2 深度层 | Windows Update 缓存、WinSxS 压缩、Shadow Copy、休眠文件、Windows.old | 🟡 需确认 |
| 阶段 3 应用层 | Teams、VSCode、JetBrains、npm/pip、微信、WPS | 🟡 需确认 |
| 阶段 4 开发者 | ESP-IDF、__pycache__、Cargo、Maven、node_modules（需 `-Dev`） | 🟠 谨慎 |

---

## 特性

- ✅ **DryRun 模式** — 扫描并预估可释放空间，不执行任何删除
- ✅ **分阶段确认** — 每个阶段开始前询问，危险操作二次确认
- ✅ **自动日志** — 每次运行保存日志到 `%TEMP%\clean-c-drive-*.log`
- ✅ **自动提权** — 检测非管理员时自动重启为管理员，保留所有参数
- ✅ **释放量统计** — 运行后显示总计释放空间（实际 vs 预览）

---

## 参数说明

| 参数 | 说明 |
|------|------|
| `-DryRun` | 仅扫描预览，不删除任何文件 |
| `-Unattended` | 无人值守，自动确认所有阶段 |
| `-Dev` | 启用开发者专项清理（阶段 4） |

---

## 要求

- Windows 10 / 11
- PowerShell 5.1+（系统自带）
- 管理员权限（脚本自动请求）

---

## License

MIT © njueeRay
