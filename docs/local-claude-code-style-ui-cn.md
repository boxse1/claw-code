# 本地 UI 改造说明

更新日期: 2026-05-24

## 目标

这次改造的目标是让本地 `claw` 终端体验更接近 Claude Code 的使用感觉:

- 启动页改成盒状欢迎面板, 显示 `Claw Code` 和 `Claude-style local agent`。
- 首屏直接显示模型, 目录, 分支, 工作区状态, 权限模式, 会话和自动保存路径。
- REPL 输入提示改成 `│ >` 样式, 更接近 Claude Code 的终端交互观感。
- 状态行改成 `status ready · model ... · provider ...`。
- 输入 `/` 或 `/?` 会打开盒状常用命令面板, 不需要先记住完整命令。
- `/help` 顶部按 Common / Workspace / Session / Keyboard 分组, 后面仍保留完整 slash command 列表。
- 工具调用框改成 `tool: name` 风格, 去掉读写/搜索 emoji。
- 等待, 完成, 失败提示改成普通文本, 减少终端噪音。

这不是复制闭源 Claude Code 的界面, 而是在当前开源 Claw Code 架构上做可维护的本地体验优化。

## 主要命令

进入 REPL 后可以直接输入:

```text
/
```

常用入口:

```text
/status
/model [model]
/permissions
/diff
/commit
/resume latest
/session list
/mcp list
/skills help
/help
/exit
```

## 验证记录

已验证:

```powershell
cargo.exe test -p rusty-claude-cli --bin claw repl_help_includes_shared_commands_and_exit
cargo.exe test -p rusty-claude-cli --bin claw repl_command_palette_surfaces_common_claude_like_shortcuts
cargo.exe test -p rusty-claude-cli --bin claw startup_banner_is_compact_and_mentions_shortcuts
cargo.exe test -p rusty-claude-cli --bin claw format_connected_line
cargo.exe build --workspace
claw status --output-format json
claw
```

真实 REPL 验证中, 启动页显示盒状欢迎面板和 `│ >` 输入提示, 输入 `/` 能显示盒状常用命令面板, 输入 `/exit` 能正常退出。

## 已知非本次处理项

- 上游已有 warning:
  - `crates/plugins/src/hooks.rs` 未使用的 `std::path::Path`
  - `crates/runtime/src/hooks.rs` 一个不必要的 `mut`
- 本次不处理工具能力, MCP, provider 协议, 模型映射或 API 凭据。
- 当前本地启动器仍按之前约定读取 `C:\Users\ROG\.claude\settings.json`, 让 `claw` 复用 Claude 配置里的模型和网关。
