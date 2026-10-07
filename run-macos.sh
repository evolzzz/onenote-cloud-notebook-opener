#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/evolzzz/onenote-cloud-notebook-opener/main"
SCRIPT_URL="$REPO_RAW/open-all-onenote.ps1"

if ! command -v pwsh >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "未找到 Homebrew。请先安装 Homebrew："
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi

  echo "未找到 PowerShell，正在通过 Homebrew 安装..."
  brew install powershell
fi

TMP_SCRIPT="$(mktemp -t open-all-onenote)"
trap 'rm -f "$TMP_SCRIPT"' EXIT

echo "正在下载最新版 OneNote 脚本..."
curl -fsSL "$SCRIPT_URL" -o "$TMP_SCRIPT"

pwsh -NoLogo -NoProfile -File "$TMP_SCRIPT" "$@"
