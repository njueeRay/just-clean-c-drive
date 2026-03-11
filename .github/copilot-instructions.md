# GitHub Copilot 项目指令

> 这是 just-clean-c-drive 项目的 AI 协作指南。
> 本文件在每次 Copilot Agent 会话中自动生效，无需重复说明。

> **团队来源：** Agent 定义、Skills、Playbook 统一维护于 [`njueeRay/ai-team`](https://github.com/njueeRay/ai-team)（submodule 路径：`.team/`）。
> 更新团队：`git submodule update --remote .team` → `.\.team\bootstrap.ps1`

---

## 项目目标

**核心目标：** 构建一个**开箱即用的 Windows C 盘深度清理 PowerShell 工具**，以开源方式发布。

**定位关键词：** 安全 · 分阶段 · DryRun 预览 · 自动提权 · 日志记录

**当前版本：** v2.0.0（已有基础实现，进入开源完善阶段）

**开源目标：** 遵循一流工程规范（README / CHANGELOG / CONTRIBUTING / LICENSE / 测试）

---

## 哲学锚点 — AI-native person

njueeRay 是一个 **AI-native person**：能力单位是"人类判断力 × AI 执行力"的共生体。
**AI-native 的健康标准：用户的判断力有没有随着 AI 能力的增强而同步成长？**

---

## 个人信息（供 Agent 参考）

```jsonc
{
  "username": "njueeray",
  "name": "Ray Huang",
  "github_url": "https://github.com/njueeray",
  "license": "MIT",
  "language_preference": "中文（所有原创内容默认中文，技术符号保持英文）"
}
```

---

## 强制规范

1. **主脚本为 `clean-c-drive.ps1`**，保持向后兼容
2. **破坏性操作必须有 `-DryRun` 安全检查**，不得绕过
3. **每次新增/修改功能**，同步更新 `CHANGELOG.md`（Keep a Changelog 格式）
4. **commit message 语义化格式**：`feat/fix/docs/style/chore: 描述`
5. **Co-authorship**：所有 Copilot 协作提交末尾附加 `Co-authored-by: GitHub Copilot <copilot@github.com>`

---

## Agent 权限与工作机制

### Agent 团队分工

| Agent | 核心职责 |
|-------|---------|
| `brain` | 战略协调中枢，用户唯一汇报窗口 |
| `pm` | Sprint 规划、DoD 执行、版本管理 |
| `dev` | PowerShell 脚本实现、测试、CI |
| `researcher` | 技术调研（Pester 测试、清理方案等） |
| `code-reviewer` | 质量审查（安全性、破坏性操作复查） |

> 完整 Agent 定义见 `.github/agents/` · Playbook 见 `.team/docs/governance/team-playbook.md`

---

## 当前协作协议

**三段式会话协议：**
1. **Recall** — 确认当前最高优先级任务
2. **Execute** — 只做那一件事，做完
3. **Ship** — 更新 CHANGELOG，触发对外动作（如有）
