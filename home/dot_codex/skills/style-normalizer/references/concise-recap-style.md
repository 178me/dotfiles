# Concise Recap Style

## Goal

Transform raw work notes into a compact, consistent recap with clear action and outcome.

## Default Template

```text
初使用总结

1. [Action], [outcome/value].
2. [Action], [outcome/value].
3. [Action], [outcome/value].

整体来看，[overall effect or value].
```

## Writing Rules

- Keep each point to one sentence.
- Prefer concrete verbs: "修复", "优化", "调整", "落地", "实现".
- Keep technical terms unchanged when needed: `SQL`, `commit`, `skill`, `版本号逻辑`.
- Remove repetition and filler words.
- Do not add facts that are not in the source text.

## Example

Input notes:

```text
修了工具版本号问题，改动不大但很快搞定。
优化了人物相册查询 SQL，补齐筛选排序细节，最后达预期。
默认封面策略也调了，优先高像素图片。
另外做了一个根据暂存区自动生成 commit 的 skill。
```

Output:

```text
初使用总结

1. 完成工具版本号逻辑修复，以较小改动快速解决问题。
2. 优化人物相册查询 SQL，补齐筛选与排序细节并达到预期效果。
3. 调整人物相册默认封面策略，优先使用高像素图片提升展示稳定性。
4. 落地自动生成 commit 的 skill，实现基于暂存区内容的提交文案规范化。

整体来看，相关优化覆盖了修复、查询能力和流程自动化，协作效率有明显提升。
```
