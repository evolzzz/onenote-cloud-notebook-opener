# OneNote Cloud Notebook Opener

一键批量打开当前 Microsoft 账号自己拥有的全部 OneNote 云笔记本。

- Windows 10/11
- macOS
- Microsoft Graph /me/onenote/notebooks
- 只请求 Notes.Read 权限
- 按 Notebook ID 去重
- 不读取 getRecentNotebooks，因此不会把近期共享笔记本混进来
- Windows / macOS 共用同一个 PowerShell 7 主脚本

## macOS 一键运行

在 Terminal 执行：

~~~bash
curl -fsSL https://raw.githubusercontent.com/evolzzz/onenote-cloud-notebook-opener/main/run-macos.sh | bash
~~~

如果已经安装 Homebrew，但没有 PowerShell，启动脚本会自动执行：

~~~bash
brew install powershell
~~~

如果 Homebrew 也没有安装，脚本会显示官方 Homebrew 安装命令。

## Windows 一键运行

在 PowerShell / Windows Terminal 执行：

~~~powershell
irm https://raw.githubusercontent.com/evolzzz/onenote-cloud-notebook-opener/main/run-windows.ps1 | iex
~~~

如果没有 PowerShell 7，启动脚本会尝试通过 winget 安装：

~~~powershell
winget install --id Microsoft.PowerShell --exact --source winget
~~~

## 直接运行主脚本

已有 PowerShell 7 时：

~~~powershell
pwsh ./open-all-onenote.ps1
~~~

调整每个笔记本之间的打开间隔：

~~~powershell
pwsh ./open-all-onenote.ps1 -DelayMs 300
~~~

默认间隔为 800 ms。

## 工作原理

1. 安装/加载轻量模块 Microsoft.Graph.Authentication
2. 使用 Notes.Read 登录 Microsoft Graph
3. 分页请求：

~~~text
GET https://graph.microsoft.com/v1.0/me/onenote/notebooks
~~~

4. 按 Notebook id 去重
5. 获取每个 Notebook 的 links.oneNoteClientUrl.href
6. Windows 使用系统 URI Handler 打开
7. macOS 使用 open 调起 OneNote

## 权限

脚本只请求：

~~~text
Notes.Read
~~~

不会请求写入或删除 OneNote 内容的权限。

## 文件

~~~text
open-all-onenote.ps1   主脚本
run-macos.sh           macOS 一键启动器
run-windows.ps1        Windows 一键启动器
README.md              使用说明
~~~

## 关于远程一键命令

curl | bash 和 irm | iex 会直接执行 GitHub 上的脚本。如果你希望先检查内容，可以先打开本仓库查看对应脚本，再执行。
