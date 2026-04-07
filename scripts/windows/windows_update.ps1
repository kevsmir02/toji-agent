[CmdletBinding()]
param(
    [string]$Source = "https://github.com/kevsmir02/toji-agent.git",
    [switch]$DryRun,
    [switch]$Antigravity,
    [switch]$Both,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Toji windows_update.ps1 — Windows launcher for update.sh.

Usage:
    ./windows_update.ps1 [-Source <path|url>] [-DryRun] [-Antigravity | -Both]

Flags:
  (none)         Sync GitHub Copilot bundle (default)
  -DryRun        Show planned update actions without changing files
  -Antigravity   Sync Antigravity files only
  -Both          Sync Copilot and Antigravity files
  -Help          Show this help message

Notes:
  - Run from the target Git repository root.
  - Requires: git and bash (Git Bash or WSL).
  - Network access is needed when using a remote source.
  - This script does not modify update.sh; it forwards your flags to update.sh.
"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

if ((@($Antigravity, $Both) | Where-Object { $_ }).Count -gt 1) {
    Write-Error "windows_update.ps1: -Antigravity and -Both are mutually exclusive."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Toji windows update: git is required but was not found in PATH."
    exit 1
}

$repoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) {
    Write-Error "Toji windows update: not a Git repository (no .git). Run this from your project root."
    exit 1
}

Set-Location $repoRoot

$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCmd) {
    Write-Error "Toji windows update: bash is required to execute update.sh. Install Git for Windows (Git Bash) or WSL, then retry."
    exit 1
}

$tmpDir = $null
$updatePath = $null
$localUpdatePath = Join-Path $Source "scripts/linux/update.sh"
$hasLocalSourceUpdater = (Test-Path -LiteralPath $Source -PathType Container) -and (Test-Path -LiteralPath $localUpdatePath -PathType Leaf)

try {
    if ($hasLocalSourceUpdater) {
        $updatePath = (Resolve-Path -LiteralPath $localUpdatePath).Path
    }
    else {
        $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("toji-windows-update-" + [System.Guid]::NewGuid().ToString("N"))
        $null = New-Item -ItemType Directory -Path $tmpDir -Force
        $updatePath = Join-Path $tmpDir "update.sh"

        $updateUrl = "https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh"
        Invoke-WebRequest -Uri $updateUrl -OutFile $updatePath
    }

    $updateArgs = @($updatePath, "--source", $Source)
    if ($DryRun) {
        $updateArgs += "--dry-run"
    }
    if ($Both) {
        $updateArgs += "--both"
    }
    elseif ($Antigravity) {
        $updateArgs += "--antigravity"
    }

    & $bashCmd.Source @updateArgs
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
