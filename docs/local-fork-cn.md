# 本地 Fork 使用说明

这个目录是用户账号下的 `boxse1/claw-code` fork，本机路径是：

```text
E:\AI-Forks\claw-code
```

远程仓库关系：

```text
origin   = https://github.com/boxse1/claw-code.git
upstream = https://github.com/ultraworkers/claw-code.git
```

## 当前安装状态

- 已从 `boxse1/claw-code` 克隆到 E 盘。
- 已添加 `upstream` 指向原始仓库，方便后续同步官方更新。
- 已在 `rust/` 目录执行 `cargo build --workspace`。
- 当前可执行文件位于 `rust\target\debug\claw.exe`。
- 已验证 `claw.exe --help` 和 `claw.exe status --output-format json` 可以运行。

## 启动方式

从仓库根目录运行：

```powershell
.\scripts\run-claw-windows.ps1 --help
.\scripts\run-claw-windows.ps1 status --output-format json
.\scripts\run-claw-windows.ps1 doctor
```

这个脚本不会修改系统 PATH。如果 `claw.exe` 不存在，它会先在 `rust/` 目录执行一次构建。

## 开发建议

后续二次开发建议从新分支开始：

```powershell
git switch -c codex/windows-provider-tooling
```

同步上游时使用：

```powershell
git fetch upstream
git merge upstream/main
```

如果只想先研究，不要替换当前 Claude Code 或 Codex 主环境。先在这个 E 盘 fork 里做构建、工具调用和 provider 兼容性测试，确认稳定后再考虑做启动器或桥接。

## 后续优先改造方向

1. Windows 友好的启动器和配置检查。
2. OpenAI-compatible / Anthropic-compatible 工具调用转换测试。
3. 对 GPT-5.5 类中转 API 增加 tool-call 强制烟测，避免只会聊天但工具空转。
4. 增加中文故障说明和日志定位命令。
5. 做一个不会污染主环境的 release 目录，例如 `E:\AI-Forks\claw-code\dist-local`。
