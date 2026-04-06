[CmdletBinding()]
param(
    [string]$Source = "https://github.com/kevsmir02/toji-agent.git",
    [string]$Target = ".",
    [switch]$DryRun,
    [switch]$Antigravity,
    [switch]$CopilotCli,
    [switch]$Both,
    [switch]$All,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Toji windows_uninstall.ps1 — Windows launcher for uninstall.sh.

Usage:
    ./windows_uninstall.ps1 [-Source <path|url>] [-Target <path>] [-DryRun] [-Antigravity | -CopilotCli | -Both | -All]

Flags:
  -Target        Target project directory (default: current directory)
  -DryRun        Show what would be removed without changing files
  -Antigravity   Remove Antigravity Toji files only
    -CopilotCli    Remove Copilot CLI instruction surfaces only
  -Both          Remove Copilot and Antigravity bundles
    -All           Remove Copilot, Copilot CLI, and Antigravity bundles
  -Help          Show this help message

Notes:
  - Requires: bash (Git Bash or WSL).
  - Network access is needed when using a remote source.
  - This script does not modify uninstall.sh; it forwards your flags to uninstall.sh.
"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

if ((@($Antigravity, $CopilotCli, $Both, $All) | Where-Object { $_ }).Count -gt 1) {
    Write-Error "windows_uninstall.ps1: -Antigravity, -CopilotCli, -Both, and -All are mutually exclusive."
    exit 1
}

$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCmd) {
    Write-Error "Toji windows uninstall: bash is required to execute uninstall.sh. Install Git for Windows (Git Bash) or WSL, then retry."
    exit 1
}

if (-not (Test-Path -LiteralPath $Target)) {
    Write-Error "Toji windows uninstall: target directory does not exist: $Target"
    exit 1
}

$targetPath = (Resolve-Path -LiteralPath $Target).Path

$tmpDir = $null
$uninstallPath = $null
$localUninstallPath = Join-Path $Source "scripts/linux/uninstall.sh"
$hasLocalSourceUninstaller = (Test-Path -LiteralPath $Source -PathType Container) -and (Test-Path -LiteralPath $localUninstallPath -PathType Leaf)

try {
    if ($hasLocalSourceUninstaller) {
        $uninstallPath = (Resolve-Path -LiteralPath $localUninstallPath).Path
    }
    else {
        $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("toji-windows-uninstall-" + [System.Guid]::NewGuid().ToString("N"))
        $null = New-Item -ItemType Directory -Path $tmpDir -Force
        $uninstallPath = Join-Path $tmpDir "uninstall.sh"

        $uninstallUrl = "https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/uninstall.sh"
        Invoke-WebRequest -Uri $uninstallUrl -OutFile $uninstallPath
    }

    $uninstallArgs = @($uninstallPath, "--target", $targetPath)
    if ($DryRun) {
        $uninstallArgs += "--dry-run"
    }
    if ($All) {
        $uninstallArgs += "--all"
    }
    elseif ($Both) {
        $uninstallArgs += "--both"
    }
    elseif ($Antigravity) {
        $uninstallArgs += "--antigravity"
    }
    elseif ($CopilotCli) {
        $uninstallArgs += "--copilot-cli"
    }

    & $bashCmd.Source @uninstallArgs
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
