---
name: codex-session-daily-report
description: Read Codex session files for a target date, summarize completed work from assistant final answers, and produce a concise daily report. Use when the user asks to summarize today's Codex activity, generate a daily report from `~/.codex/sessions`, or review completed outcomes across sessions.
---

# Codex Session Daily Report

Produce a daily report from local Codex sessions.

## Workflow

1. Resolve target date.
- If user says `today`, use an absolute date (e.g. `2026-03-02`).

2. Read session files for that date.

```bash
ls -1 ~/.codex/sessions/2026/03/02/*.jsonl
```

3. Extract completed assistant outputs only (`final_answer`).

```bash
for f in ~/.codex/sessions/2026/03/02/*.jsonl; do
  jq -r 'select(.type=="response_item" and .payload.type=="message" and .payload.role=="assistant" and .payload.phase=="final_answer")
    | .timestamp + "\t" + ((.payload.content // [])
    | map(select(.type=="output_text") | .text)
    | join(" ") | gsub("[\n\r\t]+";" ") | gsub(" +";" "))' "$f"
done
```

4. Summarize by theme and result.
- Merge similar tasks into one topic line.
- Write `今日业务事项` in plain business language: describe what was done and what problem/progress it represents.
- Keep technical evidence (file paths, tests, commit hashes) in `关键产出`, not in `今日业务事项`.
- Keep neutral language and avoid guessing.

5. Output daily report only (not logs).

## Rewrite Rules for `今日业务事项`

- Use plain Chinese that non-engineers can understand.
- Focus on actions and outcomes: `做了什么` + `带来什么结果`.
- Avoid technical tokens: file path, class/function names, shell command, stack trace, low-level error text.
- If a technical term is unavoidable, add a short explanation in simple words.

Examples:
- `修复 smart_album 软删 cover_id 返回空` -> `修好了人物相册删除后封面显示异常的问题`.
- `修正 makefile 构建上下文` -> `把镜像构建流程调整正确，避免构建时找不到依赖`.

## Output Format

Use this structure:

1. 日期：`YYYY-MM-DD`
2. 今日业务事项（大白话）：按主题列 2-6 条，每条一句
3. 关键产出：代码改动/测试结论/提交哈希
4. 风险与待办：未完成项、潜在误判点

## Constraints

- Prefer `assistant final_answer` over commentary.
- Do not output raw JSONL unless user explicitly asks.
- Keep report concise and factual.
- If no completed entries are found, state that clearly.
