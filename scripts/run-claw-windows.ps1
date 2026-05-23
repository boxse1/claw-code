param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ClawArgs
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$RustDir = Join-Path $RepoRoot "rust"
$ClawExe = Join-Path $RustDir "target\debug\claw.exe"

if (-not (Test-Path -LiteralPath $ClawExe)) {
    Push-Location $RustDir
    try {
        cargo build --workspace
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path -LiteralPath $ClawExe)) {
    throw "claw.exe was not found after build: $ClawExe"
}

Push-Location $RustDir
try {
    & $ClawExe @ClawArgs
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
