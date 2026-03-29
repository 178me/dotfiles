---
name: style-normalizer
description: Normalize raw development notes into a consistent concise recap style. Use when the user asks to standardize wording, unify summary format, polish rough task notes, or manually triggers the skill with "$style-normalizer".
---

# Style Normalizer

## Overview

Convert mixed, informal, or scattered progress notes into a clean Chinese recap with one stable structure and tone.
Keep facts unchanged, remove repetitive wording, and emphasize result and value.

## Workflow

1. Extract concrete actions, fixes, and optimizations from the input.
2. Merge duplicated information and normalize wording.
3. Compose output using the concise recap template in `references/concise-recap-style.md`.
4. Keep unknown details explicit; do not invent data.

## Output Rules

- Write in Chinese.
- Use 3 to 6 numbered points plus one closing overall sentence.
- Keep each point in the form "action + outcome/value".
- Preserve technical terms such as `SQL`, `commit`, and `skill`.
- Use objective, concise language; avoid slogans and emojis.
- Do not add timeline or implementation details not present in the input.

## Trigger Pattern

- Primary trigger: manual invocation with `$style-normalizer`.
- Also apply when user intent is "help me standardize wording", "unify style", "整理为初使用总结", or similar.

## Response Contract

- Default response format:
  1. Title line: `初使用总结`
  2. Numbered recap points
  3. Final overall sentence
- If the user requests a different title, keep the same structure and style while replacing only the title.
