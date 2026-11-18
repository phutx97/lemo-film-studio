# Từ điển phát âm

Claude dùng file này cho **mọi phim**: phụ đề giữ nguyên chữ viết, còn giọng đọc dùng cách đọc ở cột phải
(trường `say` của `core/tts/tts_zh.py`). Thêm dòng mỗi khi nghe TTS đọc sai.

| Viết | Đọc |
|---|---|
| AI | ây ai |
| MRR | em a a |
| 2,5 tỷ | hai tỷ rưỡi |
| 45% | bốn mươi lăm phần trăm |
| 2026 | hai nghìn không trăm hai mươi sáu |
| TP.HCM | thành phố Hồ Chí Minh |
| Shopify | sóp-pi-phai |

Quy tắc chung, không cần liệt kê từng trường hợp:
- Số và ngày tháng đọc thành chữ, kiểu miền Bắc ("nghìn", không phải "ngàn"), trừ khi brief nói khác.
- Từ viết tắt tiếng Anh đọc theo từng chữ cái kiểu Việt, trừ khi có trong bảng.
- Tên thương hiệu tiếng Anh: nếu chưa có trong bảng thì để nguyên, ghi vào báo cáo bàn giao để người dùng nghe lại.
