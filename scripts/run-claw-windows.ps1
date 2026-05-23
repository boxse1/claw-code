param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ClawArgs
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$RustDir = Join-Path $RepoRoot "rust"
$ClawExe = Join-Path $RustDir "target\debug\claw.exe"

function Import-ClaudeSettingsEnv {
    $settingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (-not (Test-Path -LiteralPath $settingsPath)) {
        return
    }

    try {
        $settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json
    } catch {
        Write-Warning "Failed to read Claude settings env from ${settingsPath}: $($_.Exception.Message)"
        return
    }

    if (-not $settings.env) {
        return
    }

    foreach ($property in $settings.env.PSObject.Properties) {
        $name = $property.Name
        $value = [string]$property.Value
        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrEmpty($value)) {
            continue
        }

        if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name, "Process"))) {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

function Test-BroadCwd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    $broadPaths = @(
        [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\'),
        [System.IO.Path]::GetPathRoot($fullPath).TrimEnd('\')
    )

    return $broadPaths -contains $fullPath
}

function Test-HasExplicitCwdOverride {
    param(
        [string[]]$Args
    )

    return $Args -contains "--allow-broad-cwd"
}

function Set-OpenAiCompatFallbackEnv {
    $model = [Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "Process")
    if ([string]::IsNullOrWhiteSpace($model) -or -not ($model -match '^(openai/)?gpt[-_]|^gpt[-_]')) {
        return
    }

    if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "Process"))) {
        $token = [Environment]::GetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "Process")
        if ([string]::IsNullOrEmpty($token)) {
            $token = [Environment]::GetEnvironmentVariable("ANTHROPIC_API_KEY", "Process")
        }
        if (-not [string]::IsNullOrEmpty($token)) {
            [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $token, "Process")
        }
    }

    if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable("OPENAI_BASE_URL", "Process"))) {
        $baseUrl = [Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "Process")
        if (-not [string]::IsNullOrWhiteSpace($baseUrl)) {
            $baseUrl = $baseUrl.TrimEnd("/")
            if (-not ($baseUrl -match "/v1$")) {
                $baseUrl = "$baseUrl/v1"
            }
            [Environment]::SetEnvironmentVariable("OPENAI_BASE_URL", $baseUrl, "Process")
        }
    }
}

Import-ClaudeSettingsEnv
$ClawArgs = @($ClawArgs | Where-Object { -not [string]::IsNullOrEmpty($_) })
Set-OpenAiCompatFallbackEnv

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

$OriginalLocation = (Get-Location).Path
$ShouldAllowBroadCwd = (Test-BroadCwd -Path $OriginalLocation) -and -not (Test-HasExplicitCwdOverride -Args $ClawArgs)

if ($ShouldAllowBroadCwd) {
    $ClawArgs = @("--allow-broad-cwd") + $ClawArgs
}

& $ClawExe @ClawArgs
exit $LASTEXITCODE
