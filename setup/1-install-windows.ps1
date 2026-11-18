# Bước 1 — cài phần mềm hệ thống trên Windows 10/11 (PowerShell).
# Chạy:  powershell -ExecutionPolicy Bypass -File setup\1-install-windows.ps1
# Chạy lại nhiều lần không sao: gói nào đã có thì winget bỏ qua.

$ErrorActionPreference = 'Continue'
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host 'X Khong tim thay winget. Cai "App Installer" tu Microsoft Store roi chay lai.' -ForegroundColor Red
  exit 1
}

$pkgs = @(
  @{ id = 'Git.Git';            why = 'Git + Git Bash (Claude Code va cac script sh can no)' },
  @{ id = 'OpenJS.NodeJS.LTS';  why = 'Node 20+' },
  @{ id = 'Python.Python.3.12'; why = 'Python 3.11+ (kokoro can < 3.14)' },
  @{ id = 'astral-sh.uv';       why = 'uv: cai package Python nhanh hon' },
  @{ id = 'Gyan.FFmpeg';        why = 'ffmpeg 7+' }
)
foreach ($p in $pkgs) {
  Write-Host "-> $($p.id)  ($($p.why))"
  winget install --id $p.id -e --silent --accept-source-agreements --accept-package-agreements
}

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host '-> Claude Code'
  irm https://claude.ai/install.ps1 | iex
}

# Toi uu cho render (tuy chon)
# 1) Khong sleep khi cam dien: render 30-60 phut khong bi dung giua chung. Pin van sleep binh thuong.
Write-Host '-> Tat sleep khi cam dien'
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# 2) Loai folder lam phim khoi Windows Defender: render ghi hang nghin frame, Defender quet tung file -> cham 2-3 lan.
#    Doi lai: Defender khong quet cac folder nay nua. Chi lam neu ban tin code trong do. Can quyen Administrator.
$kit = (Resolve-Path "$PSScriptRoot\..").Path
$lib = if ($env:LEMO_OPUSCAR_HOME) { $env:LEMO_OPUSCAR_HOME } else { "$env:USERPROFILE\lemo-opuscar" }
$pw  = "$env:LOCALAPPDATA\ms-playwright"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
  $ans = Read-Host "Loai $kit, $lib, $pw khoi Defender? (y/N)"
  if ($ans -eq 'y') { Add-MpPreference -ExclusionPath $kit, $lib, $pw; Write-Host '   Da loai.' }
} else {
  Write-Host '-> Bo qua Defender (khong phai Administrator). Muon lam: mo PowerShell "Run as administrator" va chay:' -ForegroundColor Yellow
  Write-Host "   Add-MpPreference -ExclusionPath '$kit','$lib','$pw'"
}

Write-Host ''
Write-Host 'Xong buoc 1. DONG cua so nay, mo Git Bash MOI (de PATH nhan ban moi), roi chay:' -ForegroundColor Green
Write-Host '   sh setup/2-setup.sh'
