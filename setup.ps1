[CmdletBinding()]
param([string]$Python = 'py')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
function Run-Python {
    param([string]$Exe, [string[]]$Arguments)
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" }
}
if (-not (Test-Path '.venv\Scripts\python.exe')) {
    if ($Python -eq 'py') {
        Run-Python 'py' @('-3.12', '-m', 'venv', '.venv')
    } else {
        Run-Python $Python @('-m', 'venv', '.venv')
    }
}
$vp = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
Run-Python $vp @('-c', 'import sys; assert sys.version_info[:2] == (3,12), "Python 3.12 required"')
Run-Python $vp @('-m', 'pip', 'install', '--upgrade', 'pip', 'setuptools', 'wheel')
Run-Python $vp @('-m', 'pip', 'install', 'torch', 'torchaudio', '--index-url', 'https://download.pytorch.org/whl/cpu')
Run-Python $vp @('-m', 'pip', 'install', '-r', 'requirements.txt')
Run-Python $vp @('-m', 'pip', 'check')
Run-Python $vp @('-m', 'playwright', 'install', 'chromium')
foreach ($d in @('draft','tmp','state','logs')) { New-Item -ItemType Directory -Force $d | Out-Null }
if (-not (Test-Path 'config.json')) { Copy-Item 'config.example.json' 'config.json' }
Write-Host 'Setup finished. Configure config.json, prepare a voice WAV, then run run.bat.'
Write-Host 'VB-CABLE is a separate driver. This script does not install drivers or reboot Windows.'
