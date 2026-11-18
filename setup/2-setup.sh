#!/bin/sh
# Bước 2 — chạy trong Git Bash, từ folder kit: cài plugin, tải thư viện, cài package (core + voice + music), rồi kiểm tra.
# Lần đầu mất khoảng 10–20 phút (Chromium headless, model Kokoro, Whisper). Chạy lại nhiều lần không sao.
set -e
cd "$(dirname "$0")/.."
export PYTHONUTF8=1 PYTHONIOENCODING=utf-8

command -v claude >/dev/null || { echo "✗ chưa có Claude Code: chạy setup/1-install-windows.ps1 trước"; exit 1; }

echo "→ plugin lemo-opuscar"
claude plugin marketplace add lemomo-ai/lemo-opuscar 2>/dev/null || claude plugin marketplace update lemolab || true
claude plugin install lemo-opuscar@lemolab || true

# script setup của plugin; nếu không thấy thì dùng bản nằm trong thư viện (sau lần clone đầu)
LIB=${LEMO_OPUSCAR_HOME:-$HOME/lemo-opuscar}
SETUP=$(find "$HOME/.claude/plugins" -path '*lemo-opuscar/scripts/setup.sh' 2>/dev/null | head -1)
[ -n "$SETUP" ] || SETUP="$LIB/plugin/skills/lemo-opuscar/scripts/setup.sh"
[ -f "$SETUP" ] || { echo "✗ không tìm thấy setup.sh của plugin. Thử: claude plugin install lemo-opuscar@lemolab"; exit 1; }

echo "→ thư viện style"
sh "$SETUP"
echo "→ package core + voice + music"
sh "$SETUP" deps voice music

sh setup/3-check.sh
