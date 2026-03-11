# 组件使用指南

> 本文件记录 README.md 中使用的所有动态组件，包括接入方法、可用参数和最佳配置。
> 适合想复用这些组件构建自己主页的开发者参考。

---

## 组件总览

| 组件 | 用途 | 是否需要账号 | 可靠性 |
|------|------|------------|--------|
| [capsule-render](#capsule-render) | Header/Footer 渐变图 | 否 | ⭐⭐⭐⭐⭐ |
| [readme-typing-svg](#readme-typing-svg) | 打字动画 | 否 | ⭐⭐⭐⭐⭐ |
| [github-readme-stats](#github-readme-stats) | GitHub 统计卡片 + Pin 卡片 | 否 | ⭐⭐⭐⭐ |
| [github-readme-streak-stats](#github-readme-streak-stats) | 连续贡献统计 | 否 | ⭐⭐⭐⭐ |
| [skill-icons](#skill-icons) | 技术栈图标 | 否 | ⭐⭐⭐⭐⭐ |
| [waka-readme-stats](#waka-readme-stats) | 编程时间统计 | ✅ 需要 WakaTime | ⭐⭐⭐⭐ |
| [github-readme-activity-graph](#github-readme-activity-graph) | 贡献活动曲线图 | 否 | ⭐⭐⭐⭐ |
| [snk (Contribution Snake)](#contribution-snake) | 贡献蛇动画 | 否 | ⭐⭐⭐⭐ |

---

## capsule-render

**仓库：** <https://github.com/kyechan99/capsule-render>

### 基础用法

```markdown
![header](https://capsule-render.vercel.app/api?type=waving&color=gradient&height=200&section=header&text=njueeray&fontSize=60)
```

### 关键参数

| 参数 | 说明 | 常用值 |
|------|------|--------|
| `type` | 形状 | `waving`, `rect`, `egg`, `shark`, `cylinder` |
| `color` | 颜色 | `gradient`, `timeGradient`, `#hexcode`, `auto` |
| `height` | 高度（px） | `150` - `300` |
| `text` | 标题文字 | 你的名字或口号 |
| `fontSize` | 字号 | `40` - `80` |
| `animation` | 动画 | `fadeIn`, `twinkling`, `blinking` |

---

## readme-typing-svg

**仓库：** <https://github.com/DenverCoder1/readme-typing-svg>

### 基础用法

```markdown
[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&lines=LLM+Engineer;Full-Stack+Developer;Open+Source+Builder)](https://git.io/typing-svg)
```

### 关键参数

| 参数 | 说明 | 常用值 |
|------|------|--------|
| `font` | 字体 | `Fira+Code`, `JetBrains+Mono` |
| `lines` | 循环显示的文字（分号分隔） | `Line1;Line2;Line3` |
| `color` | 字色 | `#hex` 或 `gradient` |
| `speed` | 打字速度 | `50`（默认），越小越快 |
| `pause` | 每行暂停时间（毫秒） | `1000` |

---

## github-readme-stats

**仓库：** <https://github.com/anuraghazra/github-readme-stats>

### 基础用法

```markdown
![Stats](https://github-readme-stats.vercel.app/api?username=njueeray&show_icons=true&theme=tokyonight)
```

### 推荐暗色主题

| 主题名 | 风格描述 |
|--------|---------|
| `tokyonight` | 蓝紫渐变，最流行 |
| `radical` | 粉红+紫，赛博朋克 |
| `merko` | 绿色终端风 |
| `gruvbox` | 暖棕复古风 |
| `nord` | 冷色系极简 |
| `onedark` | VS Code 经典暗色 |

---

## github-readme-streak-stats

**仓库：** <https://github.com/DenverCoder1/github-readme-streak-stats>

```markdown
![Streak](https://streak-stats.demolab.com?user=njueeray&theme=tokyonight&hide_border=true)
```

---

## skill-icons

**仓库：** <https://github.com/tandpfun/skill-icons>

```markdown
![Skills](https://skillicons.dev/icons?i=python,cpp,ts,js,react,docker,git&theme=dark)
```

完整图标列表：<https://skillicons.dev>

---

## waka-readme-stats

**仓库：** <https://github.com/anmol098/waka-readme-stats>

> ⚠️ 需要先注册 [WakaTime](https://wakatime.com) 账号并在 VS Code 安装插件

### 接入步骤
1. 注册 WakaTime：<https://wakatime.com>
2. 安装 WakaTime VS Code 插件
3. 在 GitHub Settings → Secrets 中添加 `WAKATIME_API_KEY` + `GH_TOKEN`（PAT，需 `repo` + `user` scope）
4. 在 README.md 中添加占位注释（Actions 自动填充）

```markdown
<!--START_SECTION:waka-->
<!--END_SECTION:waka-->
```

### 本项目使用的 Action 配置

```yaml
# .github/workflows/waka-readme.yml
- uses: anmol098/waka-readme-stats@master
  with:
    WAKATIME_API_KEY: ${{ secrets.WAKATIME_API_KEY }}
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
    SHOW_OS: "True"
    SHOW_PROJECTS: "True"
    SHOW_EDITORS: "True"
    LANG_COUNT: "6"
```

> ⚠️ WakaTime 免费账号数据保留 14 天。需持续使用编辑器才有数据填充。

---

## github-readme-activity-graph

**仓库：** <https://github.com/Ashutosh00710/github-readme-activity-graph>

### 基础用法

```markdown
![Activity Graph](https://github-readme-activity-graph.vercel.app/graph?username=njueeRay&theme=github-compact&hide_border=true&area=true)
```

### 关键参数

| 参数 | 说明 | 本项目使用值 |
|------|------|------------|
| `theme` | 配色主题 | `github-compact`（深色极简） |
| `hide_border` | 隐藏边框 | `true` |
| `area` | 面积填充 | `true`（视觉更厚重） |
| `custom_title` | 自定义标题 | `Contribution Activity` |

### 推荐暗色主题

`github-compact` · `react-dark` · `xcode` · `tokyo-night`

---

## Contribution Snake

**仓库：** <https://github.com/Platane/snk>

通过 GitHub Actions 自动生成贡献蛇动画 SVG，推送到 `output` 分支。

### 本项目使用的 Action 配置

```yaml
# .github/workflows/snake.yml
- uses: Platane/snk/svg-only@v3
  with:
    github_user_name: njueeRay
    outputs: |
      dist/github-contribution-grid-snake.svg
      dist/github-contribution-grid-snake-dark.svg?palette=github-dark
```

### README 中引用

```markdown
![snake](https://raw.githubusercontent.com/njueeRay/njueeRay/output/github-contribution-grid-snake-dark.svg)
```

### 前置要求

- Actions → General → Workflow permissions → **Read and write permissions**
- 首次需手动触发 workflow（Actions 页面 → Run workflow）

---

## V2.0 新增：双模（暗/亮）兼容模式

所有可视组件使用 `<picture>` 标签实现 GitHub 原生暗/亮双版本。

### 标准模板

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="暗色版URL" />
  <img alt="组件说明文字" src="浅色版URL" />
</picture>
```

### 各组件主题对照表

| 组件 | 暗色参数 | 浅色参数 |
|------|---------|---------|
| github-readme-stats | `theme=github_dark_dimmed` | `theme=default` |
| streak-stats | `theme=github-dark-blue` | `theme=default` |
| activity-graph | `theme=github-compact` | `theme=minimal` |
| skill-icons | `theme=dark` | `theme=light` |
| contribution-snake | `*-dark.svg` | `*.svg`（无 dark 后缀） |
| capsule-render（Header） | `color=0:0d1117,100:1a1b27` | `color=0:dbeafe,100:bfdbfe` |
| capsule-render（Footer） | `color=0:1a1b27,100:0d1117` | `color=0:bfdbfe,100:dbeafe` |

---

## capsule-render 渐变分隔线（V2.0）

在区块之间插入品牌色渐变细线，作为视觉分隔器。

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://capsule-render.vercel.app/api?type=soft&color=0:0d1117,50:1a2744,100:0d1117&height=4&section=header" />
  <img alt=""
       src="https://capsule-render.vercel.app/api?type=soft&color=0:dbeafe,50:93c5fd,100:dbeafe&height=4&section=header" />
</picture>
```

参数说明：`type=soft`（圆角）、`height=4`（4px 细线）、`color` 渐变从两端的背景色过渡到中间的品牌色调。

---

## komarev 访客计数器（V2.0）

显示 Profile 页面总访问量。

```markdown
![Visitor Count](https://komarev.com/ghpvc/?username=njueeRay&style=flat-square&color=58a6ff&label=Profile+Views)
```

| 参数 | 说明 |
|------|------|
| `username` | GitHub 用户名 |
| `style` | `flat-square` / `flat` / `for-the-badge` / `plastic` |
| `color` | 徽章颜色（支持 hex，无 `#` 前缀） |
| `label` | 显示文字 |

- 无需注册，计数自动开始
- 计数第一次访问时创建，不可重置

---

## Astro 站点组件（v4.2.0 新增）

> 以下组件用于 njueeray.github.io Astro 博客站点，不是 README Profile 组件。

### BlogCard

**文件：** `src/components/BlogCard.astro`

单篇博文卡片，用于博客列表页。

| 参数 | 类型 | 说明 |
|------|------|------|
| `slug` | `string` | 文章 slug |
| `title` | `string` | 文章标题 |
| `description` | `string` | 文章描述 |
| `pubDate` | `Date` | 发布日期 |
| `contentType` | `ContentType` | 内容类型（insight / technical / member-essay / meeting）|
| `tags` | `string[]` | 标签列表（显示前 4 个）|
| `authorId` | `string` | 作者 ID |
| `authorData` | `object \| null` | 作者信息（displayName / avatar / isAgent）|

### FilterTabs

**文件：** `src/components/FilterTabs.astro`

博客分类筛选标签栏，含客户端筛选逻辑和 URL hash 深链接。

| 参数 | 类型 | 说明 |
|------|------|------|
| `counts` | `Record<'all' \| ContentType, number>` | 各分类文章数量 |

- 自动支持 `#insight` / `#technical` / `#member-essay` / `#meeting` URL hash
- 移动端 ≤480px 自动切换为水平滚动

### global.css 设计令牌

**文件：** `src/styles/global.css`

所有 CSS 自定义属性（custom properties）的唯一真实来源。通过 `import '../styles/global.css'` 在 BaseLayout 中引入。

**颜色变量：** `--color-bg`, `--color-bg-2`, `--color-bg-3`, `--color-accent`, `--color-accent-2`, `--color-text`, `--color-text-muted`, `--color-border`, `--color-green`, `--color-yellow`, `--color-purple`, `--color-orange`, `--color-pink`, `--color-red`

**间距变量：** `--space-xs` (0.25rem) ~ `--space-2xl` (3rem)

**布局变量：** `--max-w` (780px), `--max-w-wide` (900px), `--nav-h` (52px), `--radius-sm`, `--radius-md`, `--radius-pill`
