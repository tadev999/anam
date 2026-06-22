# Anam Soft-Pastel Zen & Playful Mindfulness Design System (Theme 2)

Tài liệu này định nghĩa hệ thống ngôn ngữ thiết kế **Soft-Pastel Zen & Playful Mindfulness** (Giao diện Tĩnh lặng Hiện đại & Tông màu Pastel) của ứng dụng Anam, được lấy cảm hứng trực tiếp từ xu hướng thiết kế giao diện chăm sóc sức khỏe tinh thần hiện đại nhất.

Bất kỳ thành phần giao diện (UI) mới nào được phát triển dưới chủ đề này bắt buộc phải đối chiếu và tuân thủ các thông số kỹ thuật dưới đây.

---

## 1. Triết lý Thiết kế (Design Philosophy)

*   **Playful Serenity (Tĩnh lặng Vui tươi):** Không gian thiền định không nhất thiết phải trầm mặc, cổ kính. Giao diện này mang lại cảm giác nhẹ nhàng, tích cực, khuyến khích sự tương tác thông qua các tông màu pastel dịu dàng và hình họa minh họa mềm mại.
*   **Organic Tactility (Tính Chạm Hữu cơ):** Sử dụng các đường cong đá cuội bo tròn tối đa (`28px` - `36px`), hình khối đám mây và các nút bấm phồng nhẹ tạo cảm giác thân thiện, an toàn như đang chạm vào các vật thể tự nhiên.
*   **Visual Breathing Space (Không gian Thở):** Mật độ thông tin cực thấp, khoảng trắng rộng rãi, các phần tử được phân tách bằng màu nền dịu và bóng đổ siêu mờ sương thay vì dùng các đường kẻ viền sắc cạnh.

---

## 2. Bảng màu Pastel chuẩn (Pastel Color Tokens)

Mọi màn hình hoặc Widget thuộc Theme 2 chỉ được sử dụng các mã màu HEX được quy định dưới đây:

| Token Name | HEX Code | Mô tả | Vai trò trong UI (Flutter Color) |
| :--- | :--- | :--- | :--- |
| **`lavenderDust`** | `#9A7F9D` | Oải hương bụi | Nền chủ đạo cho Splash screen, các phân vùng thiền định sâu |
| **`apricotWarm`** | `#FCA36A` | Mơ chín ấm áp | Màu nhấn chính (Primary), nút bấm hành động quan trọng |
| **`purpleSoft`** | `#9F94F6` | Tím pastel dịu | Nền thẻ Podcast, trạng thái cảm xúc nhẹ nhàng |
| **`blueSky`** | `#4FA1F3` | Xanh da trời | Trạng thái cảm xúc năng lượng, thẻ chủ đề sáng tạo |
| **`creamBase`** | `#FBF9F6` | Trắng kem sữa | Nền Scaffold chính của toàn app (thay thế cho màu trắng tinh) |
| **`inkCharcoal`** | `#1B1C20` | Than đá đậm | Màu chữ tiêu đề chính, đảm bảo tương phản cao |
| **`grayMist`** | `#8E939F` | Xám sương mù | Màu chữ chú thích phụ, các icon không hoạt động |
| **`glassLavender`**| `#E1DDFF` | Kính oải hương | Màu nền kính mờ của Mini-player hoặc Bottom Navigation bar |

---

## 3. Kiểu chữ & Typography (Google Fonts)

Bắt buộc sử dụng bộ font **Outfit** hoặc **Poppins** làm chủ đạo để thể hiện tinh thần hình học hiện đại, sạch sẽ và trẻ trung:

*   **Font Tiêu đề & Cảm xúc (Outfit - Bold/Medium):**
    *   *Tiêu đề chào mừng (displayMedium)*: `Outfit`, size 28, Bold, màu `inkCharcoal`.
    *   *Tiêu đề phụ/Câu hỏi (headlineMedium)*: `Outfit`, size 22, SemiBold, màu `inkCharcoal`.
    *   *Nhãn cảm xúc (labelLarge)*: `Outfit`, size 14, Medium, màu `grayMist`.
*   **Font Nội dung & Danh sách nhạc (Outfit - Regular/SemiBold):**
    *   *Tên bài hát đang phát (titleMedium)*: `Outfit`, size 16, SemiBold, màu `inkCharcoal`.
    *   *Tên nghệ sĩ (bodyMedium)*: `Outfit`, size 14, Regular, màu `grayMist`.
    *   *Thời gian lượng (bodySmall)*: `Outfit`, size 12, Regular, màu `grayMist`.
*   **Chỉ số đặc biệt (Header Spacer):**
    *   Các từ khóa trạng thái lớn (ví dụ: `R E L A X`) viết hoa toàn bộ, font `Outfit` (Bold), kích thước 24px, `letterSpacing: 0.25em` để tạo độ thoáng đãng tối đa.

---

## 4. Bố cục & Thành phần Giao diện Đặc trưng

### 4.1. Khung Minh họa Đám mây (Illustration Cloud Frame)
*   Các hình minh họa vector (như nhân vật ngồi thiền) phải được đặt trong một khung hình đám mây mềm mại có viền kép mờ nhạt.
*   Nền khung hình đám mây sử dụng dải màu gradient chuyển tiếp nhẹ nhàng từ màu đào ấm sang oải hương (`apricotWarm.withOpacity(0.2)` sang `lavenderDust.withOpacity(0.2)`).

### 4.2. Danh sách cảm xúc dạng cuộn ngang (Mood Selector Grid)
*   Gồm các vòng tròn màu xám nhạt (`#F2F3F5`) chứa icon vector tối giản.
*   Trạng thái được chọn (Active) sẽ có viền dày hoặc chuyển sang màu nhấn ấm áp, kèm nhãn chữ đậm màu `inkCharcoal`.

### 4.3. Thanh phát nhạc nổi Kính mờ (Floating Mini-Player)
*   Thanh điều khiển nhạc nổi ở cạnh dưới màn hình được bo cong cực đại (`borderRadius: BorderRadius.circular(32)`).
*   Sử dụng hiệu ứng kính mờ (Glassmorphism) với nền `glassLavender.withOpacity(0.8)` kết hợp `BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15))`.
*   Tích hợp thanh tiến trình (Seek bar) dạng sợi chỉ mảnh màu xanh dương nhạt với một chấm tròn điều khiển tối giản.

### 4.4. Thẻ ảnh bọc nghệ thuật (Art-masked Header Cards)
*   Màn hình chi tiết phát nhạc thiền sử dụng một thẻ ảnh bo tròn (`borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36))`) chứa hình ảnh thiên nhiên chuyển động chậm (sóng biển, mây bay).
*   Chữ tiêu đề chủ đề (ví dụ: `RELAX`) được đè trực tiếp lên tâm ảnh với màu chữ trắng kem ngà tương phản.

---

## 5. Quy chuẩn Chuyển động (Micro-Animations)

*   **Hiệu ứng Vòng tròn Thở (Breathing Interlocking Rings):** Ở góc trên màn hình Home, tích hợp hai vòng tròn giao nhau màu oải hương và màu cam đào chuyển động xoay chậm rãi (`duration: 8000ms`, `curve: Curves.easeInOut`) co giãn nhẹ từ `1.0` sang `1.08` theo nhịp thở để hướng dẫn người dùng điều hòa nhịp tim.
*   **Hiệu ứng Pebble Bounce (Nút nhấn Đá cuội):** Mọi nút bấm (như nút "Get Started" màu mơ chín) khi nhấn vào phải co giãn mềm mại (`transform: Matrix4.identity()..scale(0.96)`, thời gian `180ms`, `curve: Curves.easeOutBack`) để tạo cảm giác đàn hồi chân thực.
