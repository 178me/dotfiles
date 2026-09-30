# Vue LSP 配置说明

## 概述

本配置使用了最新的Vue语言服务器配置，基于以下组件：

- **vue-language-server**: Vue 3.4+ 的官方语言服务器
- **vtsls**: 高性能的TypeScript/JavaScript语言服务器
- **nvim-lspconfig**: Neovim LSP配置框架

## 配置特点

### 1. Vue LSP (vue_ls)
- 专门处理 `.vue` 文件
- 支持Vue 3.4+ 的所有新特性
- 启用代码镜头、语义标记、链接编辑等功能
- 自动导入和智能补全

### 2. TypeScript/JavaScript LSP (vtsls)
- 处理 `.ts`, `.js`, `.tsx`, `.jsx` 文件
- 内联类型提示
- 自动导入建议
- 高性能TypeScript支持

## 安装的服务器

通过Mason自动安装：
- `vue-language-server` - 最新版本支持Vue 3.4+
- `vtsls` - 高性能TypeScript服务器

## 配置位置

主要配置文件：
- `lua/lazyvim/plugins/lsp/init.lua` - 主要LSP配置
- `lua/178me/config/vue-lsp.lua` - Vue专用配置

## 功能特性

### Vue文件支持
- ✅ 模板语法高亮和补全
- ✅ 组件自动导入
- ✅ Props类型检查
- ✅ 事件处理器补全
- ✅ 插槽语法支持
- ✅ 组合式API支持

### TypeScript支持
- ✅ 类型检查
- ✅ 自动导入
- ✅ 重构功能
- ✅ 内联类型提示
- ✅ 跳转定义

### 代码质量
- ✅ 语法错误检查
- ✅ 未使用变量警告
- ✅ 类型错误提示
- ✅ 格式化建议

## 使用建议

1. **项目设置**: 确保项目根目录有 `tsconfig.json` 或 `jsconfig.json`
2. **依赖管理**: 使用项目本地的TypeScript版本
3. **文件关联**: Vue文件会自动关联到vue_ls，TS/JS文件关联到vtsls

## 故障排除

### 常见问题

1. **LSP不启动**
   - 检查Mason是否安装了vue-language-server
   - 确认文件类型关联正确

2. **类型检查不工作**
   - 确保项目有正确的tsconfig.json
   - 检查TypeScript版本兼容性

3. **自动导入不工作**
   - 确认项目结构正确
   - 检查路径映射配置

### 调试命令

```vim
:LspInfo          " 查看当前LSP状态
:LspLog           " 查看LSP日志
:Mason            " 管理LSP服务器
```

## 更新日志

- 2024: 更新到Vue 3.4+支持
- 配置优化：分离vue_ls和vtsls职责
- 添加内联类型提示支持
- 启用Vue 3新特性支持
