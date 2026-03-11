# ============================================================
#  C 盘深度清理脚本 v2.0
#
#  用法:
#    .\clean-c-drive.ps1              # 交互模式（默认，每阶段询问）
#    .\clean-c-drive.ps1 -DryRun      # 仅扫描预览，不删除任何东西
#    .\clean-c-drive.ps1 -Unattended  # 无人值守（你明确传入才生效）
#    .\clean-c-drive.ps1 -Dev         # 额外启用开发者专项清理
#    .\clean-c-drive.ps1 -DryRun -Dev # 组合使用
#
#  参考: Tron Script / BleachBit 设计理念
#  重构: 2026-03-11
# ============================================================
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Unattended,
    [switch]$Dev
)

# ─── 管理员权限检查（自动重启为管理员，保留所有参数）────────
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host "当前非管理员，正在请求提权并重新启动脚本..." -ForegroundColor Yellow
    # 将所有参数序列化为字符串，传给新进程
    $argStr = ""
    if ($DryRun)     { $argStr += " -DryRun" }
    if ($Unattended) { $argStr += " -Unattended" }
    if ($Dev)        { $argStr += " -Dev" }
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"$argStr" `
        -Verb RunAs
    exit
}

# ─── 全局变量 ─────────────────────────────────────────────────
$scriptVersion = "2.0"
$logFile       = "$env:TEMP\clean-c-drive-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$totalFreed    = 0
$diskBefore    = (Get-PSDrive C).Free

# ─── 工具函数 ─────────────────────────────────────────────────
function Write-Log {
    param([string]$msg, [string]$color = "White")
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $msg"
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue
}

function Get-SizeStr {
    param([long]$bytes)
    if ($bytes -ge 1GB) { return "$([math]::Round($bytes/1GB,2)) GB" }
    if ($bytes -ge 1MB) { return "$([math]::Round($bytes/1MB,1)) MB" }
    if ($bytes -ge 1KB) { return "$([math]::Round($bytes/1KB,0)) KB" }
    return "$bytes B"
}

function Ask {
    param([string]$prompt)
    if ($Unattended) { return $true }
    $ans = Read-Host "`n$prompt [Y/n]"
    return ($ans -eq '' -or $ans -match '^[Yy]$')
}

# 核心清理函数：支持通配符路径、DryRun、逐项确认
function Remove-Files {
    param(
        [string]$Label,
        [string[]]$Paths,
        [switch]$RequireConfirm,
        [string]$ConfirmMsg = ""
    )
    if ($RequireConfirm) {
        $msg = if ($ConfirmMsg) { $ConfirmMsg } else { "清理: $Label" }
        if (-not (Ask $msg)) {
            Write-Log "  [跳过] $Label（用户取消）" "DarkGray"
            return
        }
    }
    Write-Log ">>> 清理: $Label" "Cyan"
    $freed = 0
    foreach ($rawPath in $Paths) {
        $p = [System.Environment]::ExpandEnvironmentVariables($rawPath)
        $items = @()
        if ($p -match '\*') {
            $parent  = Split-Path $p -Parent
            $pattern = Split-Path $p -Leaf
            if (Test-Path $parent) {
                $items = Get-ChildItem $parent -Force -ErrorAction SilentlyContinue |
                         Where-Object { $_.Name -like $pattern }
            }
        } elseif (Test-Path $p) {
            $items = @(Get-Item $p -Force -ErrorAction SilentlyContinue)
        }
        foreach ($item in $items) {
            try {
                $sz = if ($item.PSIsContainer) {
                    (Get-ChildItem $item.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                } else { $item.Length }
                $sz = [long]$(if ($sz) { $sz } else { 0 })
                if (-not $DryRun) {
                    Remove-Item $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                }
                $freed += $sz
                $tag = if ($DryRun) { "[预览]" } else { "[OK]" }
                Write-Log "  $tag $($item.FullName)  (-$(Get-SizeStr $sz))" "Green"
            } catch {
                Write-Log "  [跳过] $($item.FullName)  (占用中或无权限)" "DarkGray"
            }
        }
    }
    $script:totalFreed += $freed
    Write-Log "  小计: $(Get-SizeStr $freed)" "Yellow"
}

# ═════════════════════════════════════════════════════════════
# 阶段 0：启动横幅 + C 盘预扫描报告
# ═════════════════════════════════════════════════════════════
$modeStr = @()
if ($DryRun)     { $modeStr += "DryRun(仅预览)" }
if ($Unattended) { $modeStr += "Unattended(无人值守)" }
if ($Dev)        { $modeStr += "Dev(开发者模式)" }
if (-not $modeStr) { $modeStr += "Interactive(交互确认)" }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║      C 盘深度清理脚本 v$scriptVersion  —  $(Get-Date -Format 'yyyy-MM-dd HH:mm')        ║" -ForegroundColor Magenta
Write-Host "║  模式: $($modeStr -join ' | ')" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Log "日志: $logFile" "DarkGray"

# C 盘容量概况
$cDrive  = Get-PSDrive C
$totalGB = [math]::Round(($cDrive.Used + $cDrive.Free) / 1GB, 1)
$usedGB  = [math]::Round($cDrive.Used  / 1GB, 1)
$freeGB  = [math]::Round($cDrive.Free  / 1GB, 1)
$usePct  = [math]::Round($cDrive.Used  / ($cDrive.Used + $cDrive.Free) * 100, 1)
$freeColor = if ($freeGB -lt 10) { "Red" } elseif ($freeGB -lt 30) { "Yellow" } else { "Green" }

Write-Host ""
Write-Host "─── C 盘当前状态 ──────────────────────────────────────────" -ForegroundColor DarkYellow
Write-Host "  总容量: $totalGB GB   已用: $usedGB GB ($usePct%)   剩余: $freeGB GB" -ForegroundColor $freeColor

# 清理计划概览（不递归扫描，即时显示）
Write-Host ""
Write-Host "─── 本次清理计划 ──────────────────────────────────────────" -ForegroundColor DarkYellow
Write-Host "  阶段 1 [安全]   Temp · 浏览器缓存 · Windows系统缓存 · WER报告" -ForegroundColor White
Write-Host "               崩溃转储(单独确认) · 回收站 · cleanmgr" -ForegroundColor DarkGray
Write-Host "  阶段 2 [深度]   Windows Update缓存 · DISM WinSxS(2~8 GB)" -ForegroundColor White
Write-Host "               Shadow Copy还原点 · 休眠文件 · Windows.old" -ForegroundColor DarkGray
Write-Host "  阶段 3 [应用]   Teams · VSCode · JetBrains · npm/pip · 微信/WPS" -ForegroundColor White
if ($Dev) {
    Write-Host "  阶段 4 [开发者] ESP-IDF · __pycache__ · Cargo · Maven · node_modules" -ForegroundColor White
}
Write-Host ""
Write-Host "  每个阶段开始前询问，标注[单独确认]的危险项会再次弹出确认。" -ForegroundColor DarkGray

Write-Host ""
if (-not (Ask "确认开始清理")) {
    Write-Log "用户取消，退出。" "Yellow"
    exit
}

# ═════════════════════════════════════════════════════════════
# 阶段 1：安全层  —  Temp / 浏览器 / Windows 系统缓存
# ═════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  阶段 1：安全层（Temp / 浏览器缓存 / Windows 系统缓存）" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan

if (Ask "执行阶段 1（安全，可放心清理）") {

    # 1-1 临时文件
    Remove-Files "用户临时文件 (%TEMP%)"           @("$env:TEMP\*")
    Remove-Files "系统临时文件 (C:\Windows\Temp)"  @("C:\Windows\Temp\*")

    # 1-2 浏览器缓存
    Remove-Files "Chrome 缓存" @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache\*"
    )
    Remove-Files "Edge 缓存" @(
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache\*"
    )
    Remove-Files "Firefox 缓存" @(
        "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*",
        "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*"
    )
    Remove-Files "Opera 缓存" @(
        "$env:APPDATA\Opera Software\Opera Stable\Cache\*",
        "$env:APPDATA\Opera Software\Opera GX Stable\Cache\*"
    )

    # 1-3 Windows 系统缓存
    Remove-Files "缩略图缓存" @(
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
    )
    Remove-Files "字体缓存" @(
        "$env:LOCALAPPDATA\Microsoft\Windows\FontCache\*"
    )
    Remove-Files "Windows 错误报告" @(
        "$env:LOCALAPPDATA\Microsoft\Windows\WER\*",
        "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*",
        "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*"
    )
    Remove-Files "Prefetch 预读文件" @("C:\Windows\Prefetch\*.pf")
    Remove-Files "Delivery Optimization 缓存" @(
        "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*"
    )
    Remove-Files "Windows 日志文件" @(
        "C:\Windows\Logs\*",
        "C:\Windows\inf\*.log"
    )
    Remove-Files "系统崩溃转储 (Minidump / MEMORY.DMP) [单独确认]" @(
        "C:\Windows\Minidump\*",
        "C:\Windows\MEMORY.DMP",
        "C:\Windows\LiveKernelReports\*.dmp"
    ) -RequireConfirm -ConfirmMsg "清理系统崩溃转储文件（.dmp）？调试完成后可安全删除"
    Remove-Files ".NET 临时文件" @(
        "C:\Windows\Microsoft.NET\Framework\*\Temporary ASP.NET Files\*",
        "C:\Windows\Microsoft.NET\Framework64\*\Temporary ASP.NET Files\*"
    )
    Remove-Files "IIS 日志 [单独确认]" @("C:\inetpub\logs\LogFiles\*") `
        -RequireConfirm -ConfirmMsg "清理 IIS 日志文件？（如果你不部署 Web 服务可安全删除）"

    # 1-4 回收站
    Write-Log ">>> 清理: 回收站" "Cyan"
    if (-not $DryRun) {
        try   { Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Write-Log "  [OK] 回收站已清空" "Green" }
        catch { Write-Log "  [跳过] 回收站清空失败" "DarkGray" }
    } else { Write-Log "  [预览] 将清空回收站" "Green" }

    # 1-5 Windows 内置磁盘清理（cleanmgr 静默模式）
    Write-Log ">>> 调用 Windows 磁盘清理工具（cleanmgr /sagerun）..." "Cyan"
    if (-not $DryRun) {
        $sageset = 99
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
        @(
            "Active Setup Temp Folders","BranchCache","Downloaded Program Files",
            "Internet Cache Files","Memory Dump Files","Offline Pages Files",
            "Old ChkDsk Files","Recycle Bin","Service Pack Cleanup",
            "Setup Log Files","System error memory dump files",
            "System error minidump files","Temporary Files","Temporary Setup Files",
            "Thumbnail Cache","Update Cleanup","Upgrade Discarded Files",
            "Windows Defender","Windows Error Reporting Archive Files",
            "Windows Error Reporting Queue Files","Windows ESD installation files",
            "Windows Upgrade Log Files"
        ) | ForEach-Object {
            $rp = "$regPath\$_"
            if (Test-Path $rp) {
                Set-ItemProperty -Path $rp -Name "StateFlags$sageset" -Value 2 -Type DWORD -ErrorAction SilentlyContinue
            }
        }
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:$sageset" -Wait -ErrorAction SilentlyContinue
        Write-Log "  [OK] cleanmgr 完成" "Green"
    } else {
        Write-Log "  [预览] 将执行 cleanmgr /sagerun:99" "Green"
    }
} else {
    Write-Log "阶段 1 已跳过" "DarkGray"
}

# ═════════════════════════════════════════════════════════════
# 阶段 2：系统深度层  —  DISM / 更新缓存 / Shadow Copy / 休眠
# ═════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  阶段 2：系统深度层（DISM / 更新缓存 / Shadow Copy）" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Yellow

if (Ask "执行阶段 2（不可逆操作较多，每项会单独询问）") {

    # 2-1 Windows Update 下载缓存
    Remove-Files "Windows Update 下载缓存（已安装更新不受影响）" @(
        "C:\Windows\SoftwareDistribution\Download\*",
        "C:\Windows\SoftwareDistribution\DataStore\Logs\*"
    ) -RequireConfirm -ConfirmMsg "清理 Windows Update 下载缓存（SoftwareDistribution\Download）？"

    # 2-2 DISM WinSxS 组件存储清理（官方推荐，可释放 2~8 GB）
    Write-Log ">>> DISM WinSxS 组件存储清理" "Cyan"
    if (Ask "执行 DISM /StartComponentCleanup（可释放 2~8 GB，耗时约 5~15 分钟）") {
        if (-not $DryRun) {
            Write-Log "  正在分析组件存储..." "White"
            & Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
            Write-Log "  正在清理组件存储..." "White"
            & Dism.exe /Online /Cleanup-Image /StartComponentCleanup
            Write-Log "  [OK] DISM 清理完成" "Green"
        } else {
            Write-Log "  [预览] 将执行: Dism /Online /Cleanup-Image /StartComponentCleanup" "Green"
            & Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
        }
    }

    # 2-3 Shadow Copy 旧系统还原点
    Write-Log ">>> Shadow Copy 系统还原点清理" "Cyan"
    $shadowCount = (vssadmin list shadows 2>$null | Select-String "Shadow Copy Volume").Count
    Write-Log "  当前还原点数量: $shadowCount" "White"
    if ($shadowCount -gt 1) {
        if (Ask "删除除最新 1 个外的所有旧还原点（共 $shadowCount 个）") {
            if (-not $DryRun) {
                vssadmin Delete Shadows /For=C: /Oldest /Quiet
                Write-Log "  [OK] 已删除旧还原点" "Green"
            } else {
                Write-Log "  [预览] 将删除 $($shadowCount - 1) 个旧还原点" "Green"
            }
        }
    } else {
        Write-Log "  还原点数量 <= 1，无需清理" "DarkGray"
    }

    # 2-4 Hibernate 休眠文件（可选，不强制）
    $hibFile = "C:\hiberfil.sys"
    if (Test-Path $hibFile) {
        $hibSize = (Get-Item $hibFile -Force -ErrorAction SilentlyContinue).Length
        Write-Host ""
        Write-Host "  ⚠  发现休眠文件 hiberfil.sys ($(Get-SizeStr $hibSize))" -ForegroundColor Red
        Write-Host "     关闭休眠 = 立即释放该空间，但【快速启动】功能将被禁用。" -ForegroundColor Yellow
        Write-Host "     若平时用正常关机（不用休眠/快速启动），关闭是安全的。" -ForegroundColor Yellow
        if (Ask "关闭休眠功能并释放 hiberfil.sys ($(Get-SizeStr $hibSize))") {
            if (-not $DryRun) {
                powercfg -h off
                Write-Log "  [OK] 休眠已关闭，空间将在重启后完全释放" "Green"
                $script:totalFreed += $hibSize
            } else {
                Write-Log "  [预览] 将执行 powercfg -h off，释放 $(Get-SizeStr $hibSize)" "Green"
            }
        } else {
            Write-Log "  [保留] hiberfil.sys（用户选择保留）" "DarkGray"
        }
    }

    # 2-5 Windows.old 升级残留
    if (Test-Path "C:\Windows.old") {
        $woldSize = (Get-ChildItem "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        if (Ask "发现 C:\Windows.old（系统升级残留，$(Get-SizeStr $woldSize)），确认删除") {
            if (-not $DryRun) {
                cmd /c "rd /s /q C:\Windows.old" 2>$null
                Write-Log "  [OK] C:\Windows.old 已删除" "Green"
                $script:totalFreed += $woldSize
            } else {
                Write-Log "  [预览] 将删除 C:\Windows.old ($(Get-SizeStr $woldSize))" "Green"
            }
        }
    }
} else {
    Write-Log "阶段 2 已跳过" "DarkGray"
}

# ═════════════════════════════════════════════════════════════
# 阶段 3：应用层缓存
# ═════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  阶段 3：应用层缓存（Teams / VSCode / JetBrains / ...）" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Green

if (Ask "执行阶段 3（应用层缓存）") {

    # Microsoft Teams（最常见大户，1~5 GB）
    Remove-Files "Microsoft Teams 缓存" @(
        "$env:APPDATA\Microsoft\Teams\blob_storage\*",
        "$env:APPDATA\Microsoft\Teams\Cache\*",
        "$env:APPDATA\Microsoft\Teams\databases\*",
        "$env:APPDATA\Microsoft\Teams\GPUCache\*",
        "$env:APPDATA\Microsoft\Teams\IndexedDB\*",
        "$env:APPDATA\Microsoft\Teams\Local Storage\*",
        "$env:APPDATA\Microsoft\Teams\tmp\*"
    )

    # VSCode 主缓存
    Remove-Files "VSCode 缓存与日志" @(
        "$env:APPDATA\Code\logs\*",
        "$env:APPDATA\Code\CachedData\*",
        "$env:APPDATA\Code\Cache\*",
        "$env:APPDATA\Code\CachedExtensions\*",
        "$env:APPDATA\Code\CachedExtensionVSIXs\*"
    )

    # VSCode workspaceStorage：清理 90 天未访问的旧工作区存储
    Write-Log ">>> 清理: VSCode 旧工作区存储（>90 天未访问）" "Cyan"
    $wsPath = "$env:APPDATA\Code\User\workspaceStorage"
    if (Test-Path $wsPath) {
        $cutoff  = (Get-Date).AddDays(-90)
        $oldWS   = Get-ChildItem $wsPath -Directory -Force -ErrorAction SilentlyContinue |
                   Where-Object { $_.LastAccessTime -lt $cutoff }
        $wsFreed = 0
        foreach ($ws in $oldWS) {
            $sz = (Get-ChildItem $ws.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                   Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sz = [long]$(if ($sz) { $sz } else { 0 })
            if (-not $DryRun) { Remove-Item $ws.FullName -Recurse -Force -ErrorAction SilentlyContinue }
            $wsFreed += $sz
            Write-Log "  $(if($DryRun){'[预览]'}else{'[OK]'}) $($ws.FullName)  (-$(Get-SizeStr $sz))" "Green"
        }
        Write-Log "  小计: $(Get-SizeStr $wsFreed) ($($oldWS.Count) 个旧工作区)" "Yellow"
        $script:totalFreed += $wsFreed
    }

    # JetBrains IDEs
    Remove-Files "JetBrains IDE 缓存与日志" @(
        "$env:LOCALAPPDATA\JetBrains\*\caches\*",
        "$env:LOCALAPPDATA\JetBrains\*\log\*",
        "$env:APPDATA\JetBrains\*\caches\*"
    )

    # npm / pip
    Remove-Files "npm 缓存" @(
        "$env:APPDATA\npm-cache\_npx\*",
        "$env:LOCALAPPDATA\npm-cache\*"
    )
    Remove-Files "pip 缓存" @("$env:LOCALAPPDATA\pip\cache\*")

    # Scoop / Chocolatey
    Remove-Files "Scoop 包缓存" @("$env:USERPROFILE\scoop\cache\*")
    Remove-Files "Chocolatey 残留包" @("C:\ProgramData\chocolatey\lib-bad\*")

    # 微信 / QQ
    Remove-Files "微信 / QQ 缓存" @(
        "$env:APPDATA\Tencent\WeChat\*\Cache\*",
        "$env:APPDATA\Tencent\QQ\Misc\Cache\*"
    )

    # WPS
    Remove-Files "WPS 缓存" @(
        "$env:LOCALAPPDATA\Kingsoft\WPS Office\*\update\*",
        "$env:APPDATA\kingsoft\wps office\*\cache\*"
    )
} else {
    Write-Log "阶段 3 已跳过" "DarkGray"
}

# ═════════════════════════════════════════════════════════════
# 阶段 4：开发者专项（仅 -Dev 模式启用）
# ═════════════════════════════════════════════════════════════
if ($Dev) {
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  阶段 4：开发者专项清理（-Dev 模式）" -ForegroundColor Magenta
    Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Magenta

    if (Ask "执行阶段 4（开发者专项，扫描可能较慢）") {

        # 4-1 ESP-IDF 工具链下载缓存
        $espDist  = "$env:USERPROFILE\.espressif\dist"
        $espTools = "$env:USERPROFILE\.espressif\tools"

        if (Test-Path $espDist) {
            Remove-Files "ESP-IDF 工具链下载包缓存 (.espressif\dist)" @("$espDist\*") `
                -RequireConfirm -ConfirmMsg "清理 ESP-IDF dist 下载缓存（不影响已安装工具链）？"
        }

        # 4-2 ESP-IDF 旧版工具链（每个工具保留最新版，删旧版）
        if (Test-Path $espTools) {
            Write-Log ">>> 扫描 ESP-IDF 旧版工具链（保留每个工具的最新版本）" "Cyan"
            $toolDirs = Get-ChildItem $espTools -Directory -ErrorAction SilentlyContinue
            foreach ($tool in $toolDirs) {
                $versions = Get-ChildItem $tool.FullName -Directory -ErrorAction SilentlyContinue |
                            Sort-Object Name
                if ($versions.Count -le 1) { continue }
                $oldVersions = $versions | Select-Object -SkipLast 1
                foreach ($v in $oldVersions) {
                    $sz = (Get-ChildItem $v.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                           Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    $sz = [long]$(if ($sz) { $sz } else { 0 })
                    if (Ask "删除 ESP-IDF 旧版工具: $($v.FullName) ($(Get-SizeStr $sz))") {
                        if (-not $DryRun) { Remove-Item $v.FullName -Recurse -Force -ErrorAction SilentlyContinue }
                        Write-Log "  $(if($DryRun){'[预览]'}else{'[OK]'}) $($v.FullName) (-$(Get-SizeStr $sz))" "Green"
                        $script:totalFreed += $sz
                    }
                }
            }
        }

        # 4-3 Python __pycache__ 扫描（用户目录）
        Write-Log ">>> 扫描 Python __pycache__（范围: C:\Users\$env:USERNAME）" "Cyan"
        if (Ask "扫描并清理所有 __pycache__ 目录（可能需 1~2 分钟）") {
            $pcDirs = Get-ChildItem "C:\Users\$env:USERNAME" -Recurse -Directory -Force `
                      -Filter "__pycache__" -ErrorAction SilentlyContinue
            $pcFreed = 0
            foreach ($pc in $pcDirs) {
                $sz = (Get-ChildItem $pc.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                       Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                $sz = [long]$(if ($sz) { $sz } else { 0 })
                if (-not $DryRun) { Remove-Item $pc.FullName -Recurse -Force -ErrorAction SilentlyContinue }
                $pcFreed += $sz
            }
            Write-Log "  [OK] 清理 $($pcDirs.Count) 个 __pycache__，释放 $(Get-SizeStr $pcFreed)" "Green"
            $script:totalFreed += $pcFreed
        }

        # 4-4 Cargo / Rust
        Remove-Files "Cargo 注册表缓存 (.cargo\registry)" @(
            "$env:USERPROFILE\.cargo\registry\cache\*",
            "$env:USERPROFILE\.cargo\registry\src\*"
        ) -RequireConfirm -ConfirmMsg "清理 Cargo 注册表缓存（不影响已编译 crate）？"

        # 4-5 Maven / Gradle
        Remove-Files "Maven 本地仓库 (.m2)" @("$env:USERPROFILE\.m2\repository\*") `
            -RequireConfirm -ConfirmMsg "清理 Maven 本地仓库（需要时会重新下载）？"
        Remove-Files "Gradle 缓存与包装器" @(
            "$env:USERPROFILE\.gradle\caches\*",
            "$env:USERPROFILE\.gradle\wrapper\dists\*"
        ) -RequireConfirm -ConfirmMsg "清理 Gradle 缓存？"

        # 4-6 孤儿 node_modules 扫描
        Write-Log ">>> 扫描孤儿 node_modules（无 package.json 的上级目录）" "Cyan"
        if (Ask "扫描 C:\Users\$env:USERNAME 下的孤儿 node_modules（可能需 2~5 分钟）") {
            $nmDirs = Get-ChildItem "C:\Users\$env:USERNAME" -Recurse -Directory -Force `
                      -Filter "node_modules" -ErrorAction SilentlyContinue
            $orphans = $nmDirs | Where-Object {
                -not (Test-Path (Join-Path $_.Parent.FullName "package.json"))
            }
            if ($orphans) {
                Write-Log "  发现 $($orphans.Count) 个可能的孤儿 node_modules：" "Yellow"
                $orphans | ForEach-Object { Write-Log "    $($_.FullName)" "White" }
                if (Ask "删除以上 $($orphans.Count) 个孤儿 node_modules") {
                    $nmFreed = 0
                    foreach ($nm in $orphans) {
                        $sz = (Get-ChildItem $nm.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                               Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                        $sz = [long]$(if ($sz) { $sz } else { 0 })
                        if (-not $DryRun) { Remove-Item $nm.FullName -Recurse -Force -ErrorAction SilentlyContinue }
                        $nmFreed += $sz
                        Write-Log "  $(if($DryRun){'[预览]'}else{'[OK]'}) $($nm.FullName) (-$(Get-SizeStr $sz))" "Green"
                    }
                    Write-Log "  小计: $(Get-SizeStr $nmFreed)" "Yellow"
                    $script:totalFreed += $nmFreed
                }
            } else {
                Write-Log "  未发现孤儿 node_modules" "DarkGray"
            }
        }

    } else {
        Write-Log "阶段 4 已跳过" "DarkGray"
    }
}

# ═════════════════════════════════════════════════════════════
# 收尾：前后磁盘对比 + 汇总
# ═════════════════════════════════════════════════════════════
$diskAfter   = (Get-PSDrive C).Free
$actualFreed = $diskAfter - $diskBefore

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║                     清理完成！                          ║" -ForegroundColor Yellow
Write-Host "╠══════════════════════════════════════════════════════════╣" -ForegroundColor Yellow
Write-Host ("║  脚本统计释放: {0,-42}║" -f (Get-SizeStr $totalFreed))  -ForegroundColor Yellow
Write-Host ("║  磁盘实际变化: {0,-42}║" -f (Get-SizeStr $actualFreed)) -ForegroundColor Yellow
Write-Host ("║  清理前剩余:   {0,-42}║" -f (Get-SizeStr $diskBefore))  -ForegroundColor Yellow
Write-Host ("║  清理后剩余:   {0,-42}║" -f (Get-SizeStr $diskAfter))   -ForegroundColor Yellow
Write-Host ("║  日志文件:     {0,-42}║" -f $logFile)                   -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

if ($DryRun) {
    Write-Host ""
    Write-Host "  [DryRun 模式] 以上为预览，未实际删除任何文件。" -ForegroundColor Magenta
    Write-Host "  去掉 -DryRun 参数重新运行以执行实际清理。" -ForegroundColor Magenta
}

Write-Host ""
pause
