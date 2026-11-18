# Lemo Film Studio — chỉ dẫn cho Claude

Folder này dùng để làm phim ngắn bằng code với plugin **lemo-opuscar** (github.com/lemomo-ai/lemo-opuscar), chạy trên **Windows + Git Bash**.
Trả lời người dùng bằng tiếng Việt có dấu. Ngắn, thẳng.

## Đầu mỗi phiên

1. Đọc `.setup-status` (do `setup/3-check.sh` tạo ra).
   - Nếu không có file, hoặc có dòng `FAIL`: chạy `sh setup/3-check.sh`, rồi xử lý theo bảng.
   - Nếu thiếu phần mềm hệ thống (Node, ffmpeg, Python, Git): **không tự cài**. Bảo người dùng chạy `setup/1-install-windows.ps1` (xem README.md), mở Git Bash mới, rồi chạy lại.
   - Nếu thiếu package hoặc plugin: tự chạy `sh setup/2-setup.sh`.
2. Môi trường OK thì làm phim theo yêu cầu. Không hỏi lại những gì đã chốt bên dưới.

## Đã chốt — không hỏi lại

| Mục | Mặc định |
|---|---|
| Cách làm | Skill `lemo-opuscar` (skill mode). Thư viện ở `~/lemo-opuscar`. Mỗi phim là một folder con `<ten-phim>/` ngay trong folder này (chữ thường, số, gạch nối) |
| Ngôn ngữ phim | Tiếng Việt (giọng đọc + phụ đề), trừ khi brief nói khác |
| Giọng đọc | 1) File trong `assets/` nếu brief chỉ tới. 2) Nếu không: edge-tts qua `core/tts/tts_zh.py --voice vi-VN-HoaiMyNeural` (nữ) hoặc `vi-VN-NamMinhNeural` (nam). Cần mạng. Luôn áp `PHAT-AM.md` vào trường `say` |
| Kiểm tra giọng (ASR) | `asr_check.py --lang vi --model small`. **Không để mặc định `auto`**: nó coi tiếng Việt là `en` và dùng model `base.en`, dòng nào cũng fail. Với `vi`, script so khớp từng từ một, nên lệch dấu hay lệch chính tả cũng fail. Coi mismatch là **cảnh báo**: đọc bản Whisper nghe được; sai nghĩa thật thì sửa `say` và tạo lại **một lần**; vẫn lệch thì ghi vào báo cáo bàn giao, không lặp tiếp |
| Render | Nếu `.setup-status` có dòng `render WARN ... LEMO_ANGLE=swiftshader` → mọi lệnh `still.mjs`/`video.mjs` đều chạy với `LEMO_ANGLE=swiftshader`. Thời gian render ước tính cũng lấy từ dòng đó |
| Nhạc | Tự soạn bằng toolkit của thư viện, trừ khi `assets/` có nhạc và brief chỉ tới |
| Khung hình | 1920×1080, 24 fps (style nào tự đặt fps thì theo style). Brief ghi "dọc" thì làm 1080×1920 |
| Storyboard | Không. Làm thẳng ra phim |
| Độ dài | Theo brief. Brief không ghi thì 45 giây |
| Style ✦ (Manga Panels, Text Flash Cuts, Comic History Cartoon) | Không dùng, trừ khi người dùng nói có công cụ tạo ảnh. Nếu họ chọn style này thì gợi ý 2–3 style thay thế |
| GPU | Xem dòng GPU trong `.setup-status`. Không có GPU rời → tránh nhóm **3D & Miniature** và các style nặng shader, nói rõ lý do khi gợi ý |
| Effort | Nhắc người dùng `/effort high` nếu phiên chưa đặt |

## Brief

- Người dùng có thể điền `BRIEF.md` hoặc gõ một câu.
- Thiếu mục nào thì lấy mặc định ở bảng trên.
- Vòng hỏi duy nhất của thư viện (`AGENTS.md` → Workflow → Brief) chỉ dùng cho những thứ không đoán được: dữ kiện, tên/logo bắt buộc phải có. Đã đủ thì tóm tắt brief trong vài dòng rồi làm luôn.

## Phiên bị ngắt giữa chừng (hết quota, tắt máy)

Đầu phiên, nếu người dùng nói "làm tiếp" hoặc nhắc tới một phim đã có folder:
1. Đọc trong `<ten-phim>/`: `TREATMENT.md`, `build.sh`, `PROGRESS.md`, rồi `ls` các folder output (voice, music, frames, `out/`).
2. Làm tiếp từ bước dở. **Không** viết lại kịch bản, **không** tạo lại giọng, nhạc, frame đã có và đã qua kiểm tra.
3. Nếu thật sự phải làm lại một bước, nói lý do trong một dòng trước khi làm.

Trong lúc làm phim, sau mỗi bước lớn (kịch bản → giọng → nhạc → hình → render → mux), ghi một dòng vào `<ten-phim>/PROGRESS.md`: bước, file đầu ra, OK/lỗi. Phiên sau dựa vào file này.

## Bàn giao — báo cáo bắt buộc cuối mỗi phim

Tự kiểm tra bằng `ffprobe` và output của `mux.sh`, rồi in đúng bảng này:

| Mục | Kết quả |
|---|---|
| File | đường dẫn tuyệt đối tới mp4 cuối |
| Độ dài | x giây (brief yêu cầu y) |
| Khung hình | WxH, fps |
| Loudness | LUFS / true peak (từ `mux.sh`, chuẩn −14 LUFS) |
| Phụ đề | file `.srt`, số dòng, có khớp lời đọc không |
| ASR | số dòng lệch (và đó là dòng nào) |
| Phát âm cần nghe lại | các từ không có trong `PHAT-AM.md` |
| Lệch so với brief | những gì khác brief và lý do |

Sau bảng là một dòng: người dùng cần xem gì, ví dụ "xem 0:12–0:18, chỗ tên sản phẩm". Không tóm tắt quá trình làm.

## Lưu ý

- **Phim thương mại + giọng edge-tts**: Microsoft không rõ ràng về quyền dùng thương mại (docstring của `tts_zh.py` cũng ghi vậy). Nếu brief nói phim để bán, chạy quảng cáo, hoặc làm cho khách hàng → nhắc một lần: nên dùng giọng tự ghi âm hoặc TTS có license.
- **License thư viện**: code MIT. Docs/STYLE.md là CC BY-NC, nhưng được phép dùng để làm phim, kể cả phim thương mại và phim cho khách. Không được bán lại style hoặc nhúng vào sản phẩm/dịch vụ thương mại. Phim làm ra thuộc về người dùng.
- **Quota (Claude Max)**: mỗi phim tốn khoảng 30–60 phút agent và khá nhiều token. Không tự mở rộng phạm vi (ví dụ thêm vòng sửa không ai yêu cầu).
- **Đường dẫn**: Kokoro/espeak cần đường dẫn thư viện dưới 160 byte. Nếu `.setup-status` báo path dài, đặt `LEMO_OPUSCAR_HOME=C:/lemo/lib`.
- **Git**: không commit/push trừ khi được yêu cầu. Folder phim đã bị `.gitignore` loại ra (file render rất nặng).
