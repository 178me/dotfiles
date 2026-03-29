---
name: lpk-v1-v2-migrator
description: "将 LPK/LZC 项目配置从 v1 的 manifest 布局迁移到 v2 的拆分布局（`package.yml` + `lzc-manifest.yml` + `lzc-build*.yml`），遵循确定性规则与最小差异。"
---

# LPK V1 V2 迁移器

将 v1 项目配置迁移到 v2，默认保持行为不变。

## 核心原则

1. 以 release 配置为基线，优先行为保持不变。
2. 最小改动，只改迁移必需字段。
3. 包元数据仅放 `package.yml`，运行时字段仅放 `lzc-manifest.yml`。

## 迁移顺序（固定）

1. `package.yml`
2. `lzc-build.yml`
3. `lzc-build.dev.yml`
4. `lzc-manifest.yml`

## 文件迁移规则

### 1) `package.yml`

- 从 v1 manifest 提取包元数据：
  - `package`、`version`、`name`、`description`、`license`、`homepage`、`author`、`locales`。
- 不保留运行时/部署字段（如 `application`、`services`、`ext_config`）。

### 2) `lzc-build.yml`

- 以 release `lzc-build` 为基线。
- 活跃构建入口 `manifest:` 必须指向 `./lzc-manifest.yml`。
- 非必要字段不改写。

### 3) `lzc-build.dev.yml`

- 默认模板：

```yaml
envs:
  - DEV_MODE=1
buildscript: true
contentdir:
```

- 以默认模板为基线。
- 若识别到 dev manifest 的 `package`，写入 `pkg_id`，值保持一致。

### 4) `lzc-manifest.yml`

- 以 release manifest 为基础生成。
- 移除已迁移到 `package.yml` 的包元数据。
- 删除废弃字段：
  - `lzc-sdk-version`
  - `runtime_dependencies`
  - `application.background_task`

#### `application` 四字段迁移规则

仅这四个字段允许 dev/release 区分：`image`、`subdomain`、`routes`、`health_check`。

1. `image`
- DEV 来源：`lzc-build.yml.devshell.image` 或 dev manifest image（若存在）。
- RELEASE 来源：release manifest image。

2. `subdomain`
- DEV 来源：dev manifest subdomain（若存在）。
- RELEASE 来源：release manifest subdomain。

3. `routes`
- 默认仅 RELEASE。
- RELEASE 使用 release manifest routes 原值。

4. `health_check`
- 默认仅 RELEASE。
- RELEASE 使用 release manifest health_check 原值。

#### `injects` 规则（独立于四字段）

`injects` 不属于“四字段差异限制”，按以下自动检测规则生成固定转发脚本。

1. 后端 inject（`/api/*`）
- 从 release `application.routes` 检测 `/api/=exec://<port>,...`。
- 若检测到 `<port>`，生成 backend 固定转发脚本，目标为 `127.0.0.1:<port>`。
- 若检测不到端口，跳过 backend inject。

2. 前端 inject（`/*`）
- 从前端项目 `package.json` 检测端口：
  - 先看 `scripts.dev` 中显式端口（如 `--port`、`-p`、`PORT=`）。
  - 再看 `scripts.start` 中显式端口。
- 若检测到端口，生成 frontend 固定转发脚本，目标为 `127.0.0.1:<frontend_port>`。
- 若检测不到端口，跳过 frontend inject。

3. 顺序
- 若 backend/frontend 都生成，顺序固定为 backend 在前、frontend 在后。

### 5) V1 引用改写为 V2

- 活跃构建入口不再引用旧 `manifest*.yml`/`deploy/manifest*.yml`。
- 与迁移相关脚本/文档中的 v1 路径改为 v2 路径。

### 6) 旧文件清理

- 仅在新文件生成后删除旧 v1 文件（默认不做重型校验后再删）。

## 轻量校验（默认）

1. 文件存在：`package.yml`、`lzc-manifest.yml`、`lzc-build.yml`、`lzc-build.dev.yml`。
2. 关键结构正确：
- 执行顺序为 `package.yml -> lzc-build.yml -> lzc-build.dev.yml -> lzc-manifest.yml`。
- `lzc-build.yml` 的 `manifest:` 指向 `./lzc-manifest.yml`。
3. `lzc-manifest.yml` 核心正确：
- 不含废弃字段。
- `routes` 与 `health_check` 默认仅在 RELEASE 分支。
4. inject 结果正确：
- backend 端口命中则生成，未命中则跳过。
- frontend 端口命中则生成，未命中则跳过。

## 可选深度校验（按需）

仅在用户明确要求时执行：
- 字段级 diff 对比（release 基线与迁移结果）。
- 全量引用扫描（旧 v1 路径残留）。
- 详细命令日志输出。

## 输出报告（最小）

至少包含：

1. PASS/FAIL。
2. 关键变更文件。
3. 四字段迁移结果（image/subdomain/routes/health_check）。
4. backend 端口检测与 inject 结果（命中/跳过）。
5. frontend 端口检测与 inject 结果（命中/跳过）。
6. V1 引用改写结果。
7. 迁移耗时。
