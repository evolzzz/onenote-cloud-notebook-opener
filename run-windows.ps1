$ErrorActionPreference = "Stop"

$repoRaw = "https://raw.githubusercontent.com/evolzzz/onenote-cloud-notebook-opener/main"
$scriptUrl = "$repoRaw/open-all-onenote.ps1"

function Find-Pwsh {
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $knownPath = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
    if (Test-Path $knownPath) {
        return $knownPath
    }

    return $null
}

$pwsh = Find-Pwsh

if (-not $pwsh) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {
        throw "未找到 PowerShell 7，也未找到 winget。请先安装 PowerShell 7：https://aka.ms/powershell"
    }

    Write-Host "未找到 PowerShell 7，正在通过 winget 安装..."

    & winget install --id Microsoft.PowerShell --exact --source winget --accept-package-agreements --accept-source-agreements

    $pwsh = Find-Pwsh

    if (-not $pwsh) {
        throw "PowerShell 7 已安装，但当前进程未找到 pwsh。请重新打开 Windows Terminal 后再次运行。"
    }
}

$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "open-all-onenote-$([guid]::NewGuid().ToString('N')).ps1"

try {
    Write-Host "正在下载最新版 OneNote 脚本..."
    Invoke-WebRequest -Uri $scriptUrl -OutFile $tempScript

    & $pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File $tempScript
}
finally {
    Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
}
