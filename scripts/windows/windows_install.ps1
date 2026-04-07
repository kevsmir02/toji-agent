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
Toji windows_install.ps1 — Windows launcher for install.sh.

Usage:
  ./windows_install.ps1 [-Source <path|url>] [-Antigravity | -Both]

Flags:
  (none)         Install GitHub Copilot support (default)
  -Antigravity   Install Antigravity support only
  -Both          Install Copilot and Antigravity support
  -Help          Show this help message

Notes:
    - Run from the target Git repository root.
    - Requires: git and bash (Git Bash or WSL).
    - Network access is needed when using a remote source.
    - This script does not modify install.sh; it forwards your flags to install.sh.
"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

if ($Antigravity -and $Both) {
    Write-Error "windows_install.ps1: -Antigravity and -Both are mutually exclusive."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Toji windows install: git is required but was not found in PATH."
    exit 1
}

$repoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) {
    Write-Error "Toji windows install: not a Git repository (no .git). Run this from your project root."
    exit 1
}

Set-Location $repoRoot

$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCmd) {
    Write-Error "Toji windows install: bash is required to execute install.sh. Install Git for Windows (Git Bash) or WSL, then retry."
    exit 1
}

$tmpDir = $null
$installPath = $null
$localInstallPath = Join-Path $Source "scripts/linux/install.sh"
$hasLocalSourceInstaller = (Test-Path -LiteralPath $Source -PathType Container) -and (Test-Path -LiteralPath $localInstallPath -PathType Leaf)

try {
    if ($hasLocalSourceInstaller) {
        $installPath = (Resolve-Path -LiteralPath $localInstallPath).Path
    }
    else {
        $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("toji-windows-install-" + [System.Guid]::NewGuid().ToString("N"))
        $null = New-Item -ItemType Directory -Path $tmpDir -Force
        $installPath = Join-Path $tmpDir "install.sh"

        $installUrl = "https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh"
        Invoke-WebRequest -Uri $installUrl -OutFile $installPath
    }

    $installArgs = @($installPath, "--source", $Source)
    if ($Antigravity) {
        $installArgs += "--antigravity"
    }
    elseif ($Both) {
        $installArgs += "--both"
    }

    & $bashCmd.Source @installArgs
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
