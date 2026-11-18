# Lemo Film Studio

Kit làm phim ngắn bằng code với [lemo-opuscar](https://github.com/lemomo-ai/lemo-opuscar) trên Windows.
Cài một lần. Sau đó chỉ cần mở Claude và đưa brief.

## Cài đặt (một lần, khoảng 30 phút)

1. **Cài Git** (để clone kit này). Mở PowerShell:
   ```powershell
   winget install --id Git.Git -e
   ```
2. **Clone kit vào đường dẫn ngắn.** Mở Git Bash mới:
   ```sh
   mkdir -p /c/lemo && cd /c/lemo
   git clone <URL repo kit này> studio
   cd studio
   ```
3. **Cài phần mềm hệ thống** (Node, Python, uv, ffmpeg 7, Claude Code). Mở PowerShell tại `C:\lemo\studio`:
   ```powershell
   powershell -ExecutionPolicy Bypass -File setup\1-install-windows.ps1
   ```
4. **Cài plugin + thư viện + package, rồi kiểm tra.** Mở Git Bash **mới**:
   ```sh
   cd /c/lemo/studio
   claude          # đăng nhập tài khoản Max một lần, rồi /exit
   sh setup/2-setup.sh
   ```
   Cuối lệnh sẽ in bảng kiểm tra, có cả render thử một phim 4 giây (`smoke/out/final.mp4`, không tốn quota). Tất cả `OK` là xong. Dòng `WARN` ở GPU/render vẫn làm phim được, chỉ chậm hơn và nên tránh style 3D. Claude tự đọc kết quả này.

## Làm phim

```sh
cd /c/lemo/studio
claude
```
- Gõ `/effort high`.
- Điền `BRIEF.md` rồi nói: **"làm phim theo BRIEF.md"**. Hoặc gõ một câu, ví dụ: *"Làm phim 45 giây style Watercolor về trang trại cà phê nhà tôi, giọng nữ."*
- Phim nằm trong `C:\lemo\studio\<ten-phim>\`.
- Ảnh, logo, nhạc, giọng ghi âm của bạn bỏ vào `assets/`.

Claude đọc `CLAUDE.md` để biết các mặc định đã chốt, nên không hỏi lại từ đầu.

- **Xong phim**: Claude in bảng bàn giao (độ dài, khung hình, loudness, phụ đề, các từ cần nghe lại). Bạn chỉ cần xem video và những chỗ được chỉ ra.
- **Bị ngắt giữa chừng** (hết quota, tắt máy): mở `claude` rồi nói **"làm tiếp phim <ten-phim>"**. Claude đọc `PROGRESS.md` trong folder phim và làm tiếp, không làm lại từ đầu.
- **TTS đọc sai**: thêm dòng vào `PHAT-AM.md`. Áp dụng cho mọi phim sau.

## File trong kit

| File | Dùng để |
|---|---|
| `CLAUDE.md` | Claude đọc mỗi phiên: mặc định đã chốt, quy tắc |
| `BRIEF.md` | Mẫu brief cho từng phim |
| `PHAT-AM.md` | Từ điển phát âm cho giọng đọc tiếng Việt |
| `setup/1-install-windows.ps1` | Cài Git, Node, Python, uv, ffmpeg, Claude Code. Tắt sleep khi cắm điện. Tùy chọn loại folder khỏi Defender (cần admin) |
| `setup/2-setup.sh` | Cài plugin, tải thư viện style, cài package |
| `setup/3-check.sh` | Kiểm tra môi trường + render thử, ghi `.setup-status` |
| `smoke/index.html` | Phim test 4 giây cho bước kiểm tra |
| `.claude/settings.json` | **Chưa tạo**: bạn quyết định có cấp sẵn quyền lệnh hay không (xem Ghi chú) |

## Ghi chú

- **Quota Max $100**: mỗi phim tốn khoảng 30–60 phút agent. Phim đầu tiên nên làm 45 giây, xong xem `/usage` để biết một phim tốn bao nhiêu phần trăm quota.
- **Giọng tiếng Việt edge-tts**: cần mạng. Quyền dùng thương mại chưa rõ, nên phim cho khách thì dùng giọng tự ghi âm.
- **Style ✦** (Manga Panels, Text Flash Cuts, Comic History) cần công cụ tạo ảnh bên ngoài.
- **Quyền lệnh**: khi bị hỏi quyền, chọn "Yes, don't ask again" cho `node`, `ffmpeg`, `python`, `sh`. Sau vài lần sẽ hết hỏi. Hoặc bật auto mode (Shift+Tab).
- **Cập nhật thư viện**: `claude plugin marketplace update lemolab && claude plugin update lemo-opuscar@lemolab`.
