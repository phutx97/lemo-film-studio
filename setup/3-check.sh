#!/bin/sh
# Bước 3 — kiểm tra môi trường, ghi kết quả vào .setup-status (Claude đọc file này đầu mỗi phiên).
cd "$(dirname "$0")/.."; KIT=$(pwd)
export PYTHONUTF8=1 PYTHONIOENCODING=utf-8
LIB=${LEMO_OPUSCAR_HOME:-$HOME/lemo-opuscar}
OUT=.setup-status
: > "$OUT"
row() { printf '%-16s %-5s %s\n' "$1" "$2" "$3" | tee -a "$OUT"; }
major() { sed -n '1s/[^0-9]*\([0-9][0-9]*\).*/\1/p'; }

echo "Kiểm tra lúc $(date '+%Y-%m-%d %H:%M')  LIB=$LIB" | tee -a "$OUT"

v=$(node -v 2>/dev/null); m=$(echo "$v" | major)
[ -n "$m" ] && [ "$m" -ge 20 ] && row node OK "$v" || row node FAIL "cần Node 20+ (có: ${v:-không}) → 1-install-windows.ps1"

v=$(ffmpeg -version 2>/dev/null | head -1 | sed 's/ffmpeg version n\{0,1\}//; s/ .*//'); m=$(echo "$v" | major)
[ -n "$m" ] && [ "$m" -ge 7 ] && row ffmpeg OK "$v" || row ffmpeg FAIL "cần ffmpeg 7+ (có: ${v:-không}) → 1-install-windows.ps1"

command -v claude >/dev/null && row claude OK "$(claude --version 2>/dev/null)" || row claude FAIL "chưa cài Claude Code"
claude plugin list 2>/dev/null | grep -q lemo-opuscar && row plugin OK lemo-opuscar@lemolab || row plugin FAIL "chạy setup/2-setup.sh"

[ -f "$LIB/AGENTS.md" ] && row library OK "$LIB" || row library FAIL "chưa có thư viện → setup/2-setup.sh"
n=$(printf %s "$LIB" | wc -c)
[ "$n" -lt 120 ] && row path OK "$n byte" || row path FAIL "$n byte, quá dài cho espeak → đặt LEMO_OPUSCAR_HOME=C:/lemo/lib rồi chạy lại 2-setup.sh"

PY="$LIB/.venv/bin/python"
v=$("$PY" -V 2>/dev/null) && row python OK "$v (venv)" || row python FAIL "chưa có venv → setup/2-setup.sh"
[ -f "$LIB/node_modules/.lemo-ok" ] && row node-pkgs OK installed || row node-pkgs FAIL "→ setup/2-setup.sh"
[ -f "$LIB/core/tts/kokoro-v1.0.onnx" ] && row kokoro OK "model có sẵn" || row kokoro FAIL "→ setup/2-setup.sh"

# Giọng tiếng Việt qua edge-tts (cần mạng)
T=.check-tts; rm -rf "$T"; mkdir -p "$T"
echo '[{"id":"vi","text":"Xin chào, đây là giọng đọc thử nghiệm."}]' > "$T/lines.json"
if [ -x "$PY" ] && (cd "$LIB" && "$PY" core/tts/tts_zh.py "$KIT/$T/lines.json" "$KIT/$T/out" --voice vi-VN-HoaiMyNeural) >/dev/null 2>&1 \
   && [ -s "$T/out/vi.wav" ]; then
  row voice-vi OK "nghe thử: $T/out/vi.wav"
else
  row voice-vi FAIL "edge-tts vi-VN lỗi (mạng? package voice?) → vẫn làm phim được nếu tự ghi âm"
fi

g=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
[ -n "$g" ] || g=$(powershell.exe -NoProfile -Command "(Get-CimInstance Win32_VideoController | Select-Object -Expand Name) -join ', '" 2>/dev/null | tr -d '\r')
case "$g" in
  *NVIDIA*|*Radeon*|*"Arc "*) row gpu OK "$g" ;;
  "") row gpu WARN "không dò được GPU → tránh style 3D/shader nặng" ;;
  *) row gpu WARN "$g (GPU tích hợp) → tránh nhóm 3D & Miniature" ;;
esac

# Smoke render: phim 4 giây qua pipeline thật (Chromium headless → frame → ffmpeg → mux). Không tốn quota Claude.
# Thử GPU trước; WebGL lỗi thì thử software (LEMO_ANGLE=swiftshader).
SM="$KIT/smoke/out"; LOG="$KIT/.check-render.log"; rm -rf "$SM"; mkdir -p "$SM"
render() { (cd "$LIB" && env "$@" node core/render/video.mjs "$KIT/smoke" --fps 24 --out "$SM/video.mp4") > "$LOG" 2>&1; }
S=$(date +%s); mode=""
if [ -f "$LIB/node_modules/.lemo-ok" ]; then
  if render LEMO_SMOKE=1; then mode=gpu
  elif S=$(date +%s); render LEMO_ANGLE=swiftshader; then mode=swiftshader; fi
fi
sec=$(( $(date +%s) - S ))
AUD="$KIT/$T/out/vi.wav"
[ -s "$AUD" ] || { AUD="$SM/silence.wav"; ffmpeg -v error -y -f lavfi -i anullsrc=r=48000:cl=stereo -t 4 "$AUD"; }
if [ -n "$mode" ] && (cd "$LIB" && sh core/render/mux.sh "$SM/video.mp4" "$AUD" "$SM/final.mp4" 24 0) >> "$LOG" 2>&1 \
   && [ -s "$SM/final.mp4" ]; then
  est=$(( sec * 45 / 4 / 60 + 1 ))
  if [ "$mode" = gpu ]; then row render OK "GPU, ${sec}s cho 4s phim (~${est} phút render cho phim 45s, chưa tính style nặng). Xem: smoke/out/final.mp4"
  else row render WARN "WebGL GPU lỗi, chạy được bằng software: mọi lệnh render phải có LEMO_ANGLE=swiftshader. ${sec}s cho 4s phim (~${est} phút cho phim 45s). Tránh style 3D"; fi
else
  row render FAIL "render/mux lỗi → xem .check-render.log"
fi

echo
grep -q ' FAIL ' "$OUT" && echo "Còn mục FAIL ở trên. Sửa xong chạy lại: sh setup/3-check.sh" || echo "Sẵn sàng. Gõ: claude  →  /effort high  →  làm phim theo BRIEF.md"
