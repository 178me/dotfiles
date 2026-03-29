---
name: appstore-release-changelog
description: "Generate release changelogs from Git commits using the latest `chore: publish appstore v*` commit as the boundary. Use when the user asks to create or update `changelog.txt` and `changelog.en.txt`, summarize post-release commits, draft user-facing notes in grouped format, and write files only after explicit confirmation."
---

# Appstore Release Changelog

Generate release notes from Git history with a fixed boundary rule and confirmation-first workflow.

## Workflow

1. Locate boundary commit.
- Find the latest commit matching `^chore: publish appstore v`.
- Treat that commit as the formal release boundary.

2. Collect release-scope commits.
- Summarize commits in range: `boundary..HEAD`.
- Use no-merge summary for content extraction.

3. Draft Chinese user changelog first.
- Prioritize user-visible value.
- Group related items under one module.
- Keep single independent items as single-line bullets.

4. Confirm before writing.
- Do not edit `changelog.txt` or `changelog.en.txt` until the user explicitly confirms write-in.
- If user asks for format/style revisions, iterate on draft only.

5. Write bilingual files after confirmation.
- Write approved Chinese content to `changelog.txt`.
- Write matching English version to `changelog.en.txt`.
- Keep semantic alignment between Chinese and English items.

## Content Rules

1. Keep user-facing scope by default.
- Include new features and user-perceived improvements.
- Exclude internal debug/refactor/chore/test details unless user asks.

2. Apply temporary exclusions only when user specifies.
- Treat exclusions such as "hide module X this release" as one-time release instructions.
- Do not hardcode one-time exclusions into permanent behavior.

3. Preserve explicit entry paths and key UX details when provided.
- Example: `PC(设置 -> 图库管理)` and `移动端(我的 -> 图库管理)`.

## Output Template

Use this structure by default:

```md
- 图库管理
  - 支持将 /Pictures 之外的目录加入懒猫相册，兼容远程挂载与外接硬盘
  - 支持自动扫描开关、自动扫描间隔配置，以及 .gitignore 风格排除规则
  - 图库入口：PC(设置 -> 图库管理)；移动端(我的 -> 图库管理)

- PC 端复制图片逻辑优化

- 实况图支持长按空白区域播放，预览交互更自然

感谢您对本次更新的关注与支持，我们会持续优化产品体验，如有问题或建议欢迎随时反馈。
```

## Recommended Commands

Use these commands to build the draft quickly:

```bash
git log --oneline --decorate --grep='^chore: publish appstore v' -n 30
git log --no-merges --pretty=format:'%h %s' <boundary>..HEAD
```

If writing is confirmed:

```bash
# write changelog.txt
# write changelog.en.txt
```
