#requires -Version 7.0

param(
    [int]$DelayMs = 800
)

$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

if ($IsWindows) {
    chcp 65001 > $null
}

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== OneNote Cloud Notebook Opener ==="
Write-Host ""

$moduleName = "Microsoft.Graph.Authentication"

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Write-Host "正在安装 $moduleName ..."

    if (Get-Command Install-PSResource -ErrorAction SilentlyContinue) {
        Install-PSResource -Name $moduleName -Scope CurrentUser -TrustRepository
    }
    else {
        Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber
    }
}

Import-Module $moduleName

Write-Host "正在登录 Microsoft 账号..."
Connect-MgGraph -Scopes "Notes.Read" -NoWelcome

$context = Get-MgContext

Write-Host ""
Write-Host "当前账号: $($context.Account)"
Write-Host ""

function Get-AllNotebooks {
    $uri = "https://graph.microsoft.com/v1.0/me/onenote/notebooks"
    $result = @()

    while ($uri) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri

        if ($response.value) {
            $result += @($response.value)
        }

        $uri = $response.'@odata.nextLink'
    }

    return $result
}

Write-Host "正在获取自己的 OneNote 云笔记本..."

$rawNotebooks = Get-AllNotebooks
$notebookMap = @{}

foreach ($notebook in $rawNotebooks) {
    if ([string]::IsNullOrWhiteSpace($notebook.id)) {
        continue
    }

    $url = $notebook.links.oneNoteClientUrl.href

    if ([string]::IsNullOrWhiteSpace($url)) {
        continue
    }

    $notebookMap[$notebook.id] = [PSCustomObject]@{
        Id   = $notebook.id
        Name = $notebook.displayName
        Url  = $url
    }
}

$notebooks = @(
    $notebookMap.Values |
        Sort-Object Name
)

Write-Host ""
Write-Host "找到 $($notebooks.Count) 个自己的笔记本。"
Write-Host ""

if ($notebooks.Count -eq 0) {
    Write-Warning "没有找到可打开的 OneNote 笔记本。"
    exit 0
}

$i = 1

foreach ($notebook in $notebooks) {
    Write-Host ("[{0}/{1}] 打开: {2}" -f $i, $notebooks.Count, $notebook.Name)

    try {
        if ($IsWindows) {
            Start-Process -FilePath $notebook.Url
        }
        elseif ($IsMacOS) {
            & /usr/bin/open $notebook.Url
        }
        else {
            throw "当前只支持 Windows 和 macOS。"
        }
    }
    catch {
        Write-Warning "打开失败: $($notebook.Name)"
        Write-Warning $_.Exception.Message
    }

    Start-Sleep -Milliseconds $DelayMs
    $i++
}

Write-Host ""
Write-Host "完成，共打开 $($notebooks.Count) 个笔记本。"
