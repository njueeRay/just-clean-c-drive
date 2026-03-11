# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Changed
- README 品牌化重写：新增品牌故事、量化清理数据表、与付费工具对比表

## [2.0.0] - 2026-03-11

### Added
- 四阶段清理架构（安全层 / 深度层 / 应用层 / 开发者层）
- `-DryRun` 参数：仅扫描预览，不执行任何删除
- `-Unattended` 参数：无人值守自动确认模式
- `-Dev` 参数：开发者专项清理（node_modules / pip / cargo / esp-idf）
- 自动管理员提权（保留所有参数重启）
- 自动日志输出到 `%TEMP%\clean-c-drive-*.log`
- 运行前 C 盘状态概览 + 清理计划预览
- 运行后总释放空间统计

### Changed
- 重构为参数化设计，替代旧版硬编码路径

---

[Unreleased]: https://github.com/njueeRay/just-clean-c-drive/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/njueeRay/just-clean-c-drive/releases/tag/v2.0.0
