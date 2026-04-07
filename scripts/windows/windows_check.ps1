[CmdletBinding()]
param(
    [string]$Source = "https://github.com/kevsmir02/toji-agent.git",
    [switch]$Antigravity,
    [switch]$Both,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Toji windows_check.ps1 — Windows launcher for check.sh.

Usage:
  ./windows_check.ps1 [-Source <path|url>] [-Antigravity | -Both]

Flags:
  (none)         Check Copilot install (default)
  -Antigravity   Check Antigravity install
  -Both          Check Copilot and Antigravity install
  -Help          Show this help message

Notes:
  - Run from the target Git repository root.
  - Requires: git and bash (Git Bash or WSL).
  - Network access is needed when using a remote source.
  - This script does not modify check.sh; it forwards your flags to check.sh.
"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

if ($Antigravity -and $Both) {
    Write-Error "windows_check.ps1: -Antigravity and -Both are mutually exclusive."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Toji windows check: git is required but was not found in PATH."
    exit 1
}

$repoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) {
    Write-Error "Toji windows check: not a Git repository (no .git). Run this from your project root."
    exit 1
}

Set-Location $repoRoot

$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCmd) {
    Write-Error "Toji windows check: bash is required to execute check.sh. Install Git for Windows (Git Bash) or WSL, then retry."
    exit 1
}

$tmpDir = $null
$checkPath = $null
$localCheckPath = Join-Path $Source "scripts/linux/check.sh"
$hasLocalSourceChecker = (Test-Path -LiteralPath $Source -PathType Container) -and (Test-Path -LiteralPath $localCheckPath -PathType Leaf)

try {
    if ($hasLocalSourceChecker) {
        $checkPath = (Resolve-Path -LiteralPath $localCheckPath).Path
    }
    else {
        $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("toji-windows-check-" + [System.Guid]::NewGuid().ToString("N"))
        $null = New-Item -ItemType Directory -Path $tmpDir -Force
        $checkPath = Join-Path $tmpDir "check.sh"

        $checkUrl = "https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/check.sh"
        Invoke-WebRequest -Uri $checkUrl -OutFile $checkPath
    }

    $checkArgs = @($checkPath)
    if ($Antigravity) {
        $checkArgs += "--antigravity"
    }
    elseif ($Both) {
        $checkArgs += "--both"
    }

    & $bashCmd.Source @checkArgs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    if ($tmpDir -and (Test-Path $tmpDir)) {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

exit 0
