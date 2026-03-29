---
name: git-commit-from-staged
description: Create a Git commit strictly from currently staged changes. Use when the user asks to "commit staged files", "commit current index", "write commit message from git add results", or wants a clean commit without including unstaged/untracked files.
---

# Git Commit From Staged

Create precise commits from `git diff --cached` only. Keep commit boundaries strict and avoid staging additional files unless the user explicitly asks.

## Workflow

1. Check staged state.
- Run `git status --short`.
- Run `git diff --cached --stat` and `git diff --cached`.
- If there are no staged changes, stop and tell the user no commit can be created from the index.

2. Infer commit intent from staged diff.
- Group files by concern (feature, refactor, fix, docs, tests, chore).
- Prefer a single commit theme. If staged scope is mixed, still create one best-effort commit message for the current staged set unless the user explicitly asks to split.

3. Inspect recent commit style.
- Run `git log --oneline -n 15`.
- Infer dominant style from recent commits: commit type format, language (Chinese/English), and summary tone.
- Keep the current commit semantically accurate; align style without copying old summaries.
- If style is mixed, prioritize consistency with the latest 5 commits.

4. Compose commit message.
- Use `<type>: <summary>` by default.
- Use common types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`.
- Match recent style unless the user specifies a different format.
- Keep summary concise and behavior-focused.

5. Commit only staged files.
- Run `git commit -m "<message>"`.
- Do not run `git add` unless the user explicitly requests staging adjustments.
- Do not ask whether unstaged/untracked files should be included; they are always out of scope for this skill.

6. Report result.
- Return commit hash, subject line, and staged file list included in the commit.
- Default to silent mode for unstaged/untracked files. Only report remaining workspace changes if the user explicitly asks for workspace status.

## Guardrails

- Respect the user's staged boundary: staged in, unstaged out.
- Treat unstaged/untracked files as informational only; never block commit flow to ask inclusion questions.
- Do not proactively mention unstaged/untracked leftovers in final output unless the user asks.
- Never amend (`--amend`) unless the user explicitly asks.
- Never use destructive git commands (`reset --hard`, checkout restore) for commit prep.
- If staged diff is unexpectedly empty after checks, re-run `git status --short` once and stop with a clear explanation.
- Do not invent scope or ticket IDs unless they are present in staged changes or explicitly requested.

## Command Snippets

```bash
git status --short
git diff --cached --stat
git diff --cached
git log --oneline -n 15
git commit -m "refactor: improve person album query and ordering"
git show --name-only --oneline --no-patch HEAD
```

Use this skill whenever the user asks to commit "what is already staged".
