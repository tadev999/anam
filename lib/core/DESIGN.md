# Anam UI/UX Design System & Theme Guidelines

Tài liệu này định nghĩa hệ thống ngôn ngữ thiết kế **Modern Zen & Indochine** cao cấp của ứng dụng Anam. Bất kỳ thành phần giao diện (UI) mới nào được viết ra bắt buộc phải đối chiếu và tuân thủ các thông số kỹ thuật dưới đây để đảm bảo tính nhất quán thị giác.

---

## 1. Triết lý Thiết kế (Design Philosophy)
* **Tranquility (Tĩnh lặng)**: Không gian thoáng đãng, mật độ thông tin vừa phải, tránh gây ngợp cho người dùng.
* **Natural Elements (Yếu tố Tự nhiên)**: Sử dụng các đường cong mềm mại hình đá cuội (Pebble-shaped), hiệu ứng kính mờ sương khói (Frosted Glass) tạo cảm giác như sương mù buổi sáng.
* **Premium Minimalism (Tối giản Cao cấp)**: Sử dụng các viền siêu mỏng, bóng đổ rất nhẹ và tập trung vào các màu nhấn đắt giá (Sage Green, Soft Gold).

---

## 2. Bảng màu chuẩn (Color Tokens)

Mọi Widget chỉ được phép sử dụng các mã màu HEX được quy định dưới đây (tương ứng với cấu trúc định nghĩa màu tại `lib/core/theme.dart`):

| Token Name | HEX Code | Mô tả | Vai trò trong UI |
| :--- | :--- | :--- | :--- |
| **`slateDark`** | `#101418` | Slate sâu lắng | Làm nền chủ đạo của toàn app (Scaffold Background) |
| **`slateMedium`** | `#161B22` | Xám tối vừa | Làm nền các phân vùng trung gian, Bottom bar |
| **`slateLight`** | `#222A36` | Xám tối nhạt | Nền của các thẻ card thường, phần tử phụ |
| **`sageGreen`** | `#8FA89B` | Xanh xô thơm | Màu nhấn chính (Primary), các chỉ báo tích cực |
| **`softGold`** | `#D4AF37` | Vàng gold ấm | Điểm nhấn tinh tế, phần thưởng, streak, chỉ báo Ep |
| **`creamWhite`** | `#F5F5F0` | Trắng kem | Màu chữ chính (Title & Body) - Dịu mắt, không gây lóa |
| **`softGray`** | `#A0AAB5` | Xám sương mù | Màu chữ phụ, chú thích, mô tả nhỏ |
| **`mistRed`** | `#C98B8B` | Đỏ khói tiêu cực | Trạng thái phòng xưng tội, cảnh báo nhẹ |
| **`inkBlue`** | `#6A8CAF` | Xanh mực tối | Trạng thái chế độ tu viện, nhạc thiền |

---

## 3. Kiểu chữ & Typography (Google Fonts)

Bắt buộc sử dụng 2 bộ font chữ dưới đây cho toàn bộ ứng dụng:

* **Font Tiêu đề & Trích dẫn (Lora)**: Dùng cho các tiêu đề lớn mang tính triết lý, châm ngôn thiền định để tạo cảm giác truyền thống, tĩnh tại và nghệ thuật.
  * *Tiêu đề lớn (displayLarge)*: `Lora`, size 32, Bold, letterSpacing `-0.5`
  * *Tiêu đề phụ (displayMedium)*: `Lora`, size 24, SemiBold
* **Font Nội dung & Nhãn nút (Outfit)**: Dùng cho toàn bộ nội dung chính, mô tả chi tiết, nhãn nút bấm để mang lại cảm giác hiện đại, sạch sẽ và cực kỳ dễ đọc.
  * *Nội dung chính (bodyLarge)*: `Outfit`, size 16, height `1.5`, opacity `0.9`
  * *Mô tả nhỏ (bodyMedium)*: `Outfit`, size 14, màu `softGray`, height `1.4`
  * *Nhãn nút (labelLarge)*: `Outfit`, size 14, Bold, letterSpacing `1.0`

---

## 4. Hiệu ứng Kính Mờ (Glassmorphism)

Để thể hiện tinh thần "Thánh đường sương khói", các Container hiển thị nội dung nên áp dụng hiệu ứng kính mờ Frosted Glass:
* **Bộ lọc Blur**: Sử dụng `BackdropFilter` với `ImageFilter.blur(sigmaX: 20, sigmaY: 20)`.
* **Màu nền phủ (Fill color)**: `creamWhite.withOpacity(0.08)` (tối đa `0.12` khi muốn làm nổi bật).
* **Đường viền (Border)**: Viền siêu mỏng `width: 1.0` với màu `creamWhite.withOpacity(0.08)`.
* **Độ bo tròn góc (Radius)**: Tối thiểu là `24.0` (Khuyên dùng `28.0` đến `36.0` để tạo hình dáng bo đá cuội mềm mại).

---

## 5. Quy chuẩn Chuyển động & Micro-Animations

* **Nhấn nút (Pebble Press)**: Các nút bấm hoặc Pebble Cards khi được người dùng tương tác bắt buộc phải có hiệu ứng co giãn nhẹ (`AnimatedScale` hoặc co từ `1.0` xuống `0.95` trong thời gian `150ms`, Curve dạng `Curves.easeOut`) để tạo phản hồi xúc giác mượt mà.
* **Đốt cháy (Dissolve Effect)**: Hiệu ứng đốt giấy xưng tội phải diễn ra chậm rãi trong `2200ms`, chữ mờ dần trong `600ms` và tro tàn bay lên từ toạ độ nhấn ngẫu nhiên, tan biến tự nhiên bằng lực cản không khí giả lập.
