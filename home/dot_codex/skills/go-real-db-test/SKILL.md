---
name: go-real-db-test
description: Write or update Go backend tests that run against a real database during development validation. Use when the user wants query verification with real data, asks for tests that reuse project testutil helpers like GetTestDB or GetTestUserId, wants observable query-input/query-output logs, or needs a stricter real-DB regression test with cleanup.
---

# Go Real DB Test

Write Go backend tests that intentionally use the project's real test database.

This skill is for development validation, query debugging, and real-environment verification.
It supports two styles that can coexist in the same codebase.

## When To Use

Use this skill when the user asks for any of the following:
- A Go backend test that must connect to the real project database.
- A query verification test that should print conditions before querying and print results after querying.
- A development-phase test where the user plans to run the test manually and inspect output.
- A stricter regression-style real-DB test with assertions and cleanup.
- Reuse of project helpers such as `testutil.GetTestDB`, `testutil.GetTestUserId`, `InitTestService`, or existing test fixtures.

Do not use this skill for pure logic tests that can run without external dependencies.

## Default Decision

Choose one of these two modes based on user intent.

### 1. Observable Validation Test

Use this when the user is debugging, validating data, or says they will run the test and inspect the output themselves.

Characteristics:
- Uses the real DB.
- Reuses project `testutil` helpers.
- Prints query conditions before execution with `t.Logf`.
- Prints returned rows or key result fields after execution with `t.Logf`.
- Uses weak assertions only:
  `require.NoError`, `require.NotNil`, `require.NotEmpty`, or minimal reachability checks.
- Avoid brittle exact assertions unless the user explicitly wants them.

Typical phrasing from the user:
- “我自己跑测试看结果”
- “查询前后都打印一下”
- “只需要验证可达即可”
- “开发阶段排查一下真实查询逻辑”

### 2. Strict Real-DB Regression Test

Use this when the user wants stable verification for a known behavior.

Characteristics:
- Uses the real DB.
- Reuses project `testutil` helpers.
- Prepares isolated test data.
- Registers `t.Cleanup` to delete created records.
- Uses stronger assertions on ordering, filtering, aggregation, and returned state.
- Keeps logs only where they help diagnose failures.

Typical phrasing from the user:
- “帮我补测试覆盖这个查询行为”
- “要验证排序/过滤/聚合结果”
- “这个行为后面不能再回归”

## Workflow

1. Read the target query code and the surrounding store/business layer.
2. Inspect existing tests under the same module.
3. Locate project test helpers first:
   search for `GetTestDB`, `GetTestUserId`, `InitTestService`, `testutil`, and existing cleanup patterns.
4. Determine whether the test depends on a real remote database.
5. Prefer the smallest runnable scope:
   use `go test -run <SingleTestName>`.
6. Write the test in the module's `tests/` directory when the project conventions require it.
7. If inserting or mutating DB rows, always register `t.Cleanup` to delete them.
8. Run only the new test first.
9. If local execution hangs or the project requires a remote environment, switch to the project's approved remote shell flow and still run only the smallest scope.

## Logging Pattern For Observable Tests

For debug-style tests, prefer logs like these:

```go
 t.Logf("query userID=%s filter=%+v offset=%d limit=%d", userID, query, offset, limit)
 t.Logf("result count=%d", len(items))
 for i, item := range items {
 	t.Logf("result[%d]=id=%d type=%s title=%q path=%q", i, item.ID, item.ItemType, item.Title, item.Path)
 }
```

Keep logs high-signal.
Do not dump giant structs unless necessary.
If there are many records, print count first and then only key fields.

## Data Setup Rules

- Reuse `testutil.GetTestUserId()` first when the user explicitly asks for it.
- Otherwise prefer a unique test user identifier if the project allows it and isolation matters.
- Create only the minimum rows needed to prove the behavior.
- Clean up every inserted or updated row with `t.Cleanup`.
- If foreign data may affect the query, isolate with unique paths, titles, tmdb IDs, or user-scoped records.

## Assertions Guidance

For observable validation tests, default to:
- `require.NoError(t, err)`
- `require.NotNil(t, result)` when appropriate
- `require.NotEmpty(t, result)` only if the user expects existing data
- minimal sanity checks such as IDs or lengths when clearly stable

For strict regression tests, add exact assertions for:
- ordering
- filter inclusion/exclusion
- joined state fields
- aggregation counts
- time parsing or normalized value comparison

When time strings come back from the DB, compare parsed time equality instead of raw formatted strings if time zone rendering can differ.

## Running Rules

- Start with one test only:
  `go test ./path/to/tests -run TestName -count=1 -v`
- If the repository's test policy requires a remote shell for real DB access, follow it.
- Do not run a broad package test suite first.
- If a local run stalls during DB init or migrations, switch to the remote environment rather than waiting indefinitely.

## Output Style

When reporting back:
- State which mode you used: observable validation or strict regression.
- Mention whether the test uses real DB helpers such as `GetTestDB` and `GetTestUserId`.
- Mention the exact minimal test command you ran or prepared.
- If a test exposed a production bug in the query/store layer, say so explicitly.

## Handy Prompt Phrases

Users can invoke this skill with prompts like:
- `用 $go-real-db-test 给这个 querier 写一个真实数据库可观测测试，查询前后都打印。`
- `用 $go-real-db-test 补一个严格一点的真实库回归测试，记得 cleanup。`
- `用 $go-real-db-test 写两种版本，都保留：一个打印观察，一个严格断言。`
