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

已经额外安装了 PATH 启动器，日常直接运行：

```powershell
claw
claw --help
claw status --output-format json
claw doctor
claw prompt "只回复 OK"
```

备用命令：

```powershell
claw-code
```

也可以从仓库根目录运行源码脚本：

```powershell
.\scripts\run-claw-windows.ps1 --help
.\scripts\run-claw-windows.ps1 status --output-format json
.\scripts\run-claw-windows.ps1 doctor
```

这个脚本不会修改系统 PATH。如果 `claw.exe` 不存在，它会先在 `rust/` 目录执行一次构建。脚本会把 `C:\Users\ROG\.claude\settings.json` 里的 `env` 配置注入到当前子进程环境中，方便复用现有 Claude/ClawGod 凭据，但不会打印或持久化密钥。

如果从 `C:\Users\ROG` 或磁盘根目录这种过大的目录直接运行 `claw`，启动器会自动追加 `--allow-broad-cwd`，保持当前目录不变。这是为了让它更接近 `claude` 的启动体验。

做具体项目时，先进入项目目录再运行 `claw`，例如：

```powershell
cd F:\洪荒
claw
```

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
