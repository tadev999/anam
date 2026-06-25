# Quy tắc & Phương châm Thiết kế Ứng dụng Anam (Anam App Design Rules & Principles)

Tài liệu này tổng hợp toàn bộ các nguyên tắc thiết kế trải nghiệm người dùng (UX/UI), triết lý tâm lý trị liệu và quy chuẩn kỹ thuật đã thống nhất và triển khai trong ứng dụng **Anam** (Secular Self-Care & Endogenism - Tự chăm sóc bản thân thế tục).

---

## 1. Triết lý & Ngôn ngữ Thế tục (Secular & Endogenism Principles)

*   **Tôn trọng sự tự nhiên, phi tôn giáo (Secularism)**:
    *   Tránh sử dụng các thuật ngữ mang tính giáo điều, tôn giáo hoặc tâm linh huyền bí.
    *   *Quy tắc cụ thể*: Sử dụng từ `"Lắng yên..."` hoặc `"Đang trôi trong khoảng lặng..."` thay cho `"Đang thiền định..."` hay `"Thiền tập"`.
*   **Trị liệu nội sinh không phán xét (Radical Acceptance)**:
    *   Mọi cảm xúc của người dùng, dù là tiêu cực hay tích cực, đều được tôn trọng và đối xử bình đẳng. 
    *   *Ánh xạ thiên nhiên*: Không coi cảm xúc tiêu cực là sự "thất bại". Chúng được chuyển hóa thành các biểu tượng thiên nhiên đẹp đẽ trong Khu Vườn Tâm Trí:
        *   **Burnout** (Kiệt sức) $\rightarrow$ **Volcanic Stone** (Đá núi lửa đỏ mờ trầm tĩnh - `mistRed`).
        *   **Overthinking** (Suy nghĩ nhiều) $\rightarrow$ **Sand Ripple Circle** (Vòng cát xoáy dịu nhẹ - `inkBlue`).
        *   **Lonely** (Cô đơn) / **Empty** (Trống rỗng) $\rightarrow$ **Slate Gray Stone** (Đá cuội xám tĩnh lặng - `softGray`).
        *   **Peaceful** (Bình yên) $\rightarrow$ **Sage Lotus** (Búp sen xanh lục xô thơm - `sageGreen`).
        *   **Grateful** (Biết ơn) $\rightarrow$ **Gold Blossom Petal** (Cánh đào vàng ấm áp - `softGold`).
        *   *Chỉ làm nghi thức sáng* $\rightarrow$ **Neutral Clay Pebble** (Sỏi đất sét vàng nhạt).

---

## 2. Thiết kế Không Áp lực (Guilt-Free & No-Guilt UX)

*   **Loại bỏ áp lực duy trì Streak (Loss Aversion)**:
    *   Trong Chánh niệm Nội sinh, việc đe dọa mất chuỗi ngày check-in sẽ tạo thêm áp lực thành tích (Performance Anxiety).
    *   *Quy tắc cụ thể*: Những ngày người dùng bỏ lỡ không check-in sẽ hiển thị là **nền cát mịn được cào gọn gàng** (Karesansui) trong Khu Vườn Tâm Trí. Không có dấu gạch chéo phê bình, không có khoảng trống cảnh cáo hay thông báo nhắc nhở phiền phức.
*   **Định vị không gian hướng dẫn ôn hòa**:
    *   Khi gieo hạt mầm ngủ ngon, chỉ thông báo cho người dùng biết là hạt mầm đã được gieo thành công. Tuyệt đối không thêm các câu thúc giục mang tính áp đặt như *"Sáng mai hãy bật app lên để thấy hạt mầm nảy nở"*.
*   **Động lực nội tại thông qua Sự kết tụ (Grouping Evolution)**:
    *   Khi tích lũy đủ từ **3 vật phẩm cùng loại** nằm gần nhau trong vườn, đồ họa sẽ tự động kết nối và tiến hóa (ví dụ: Đá cuội xám kết nối thành lối đi sỏi, búp sen xanh nở thành hoa sen, vòng cát xoáy kết nối thành dải sóng). Điều này truyền đi thông điệp: *mỗi trải nghiệm khó khăn khi xâu chuỗi lại đều đóng góp tạo nên con đường phát triển đẹp đẽ của bản thân*.

---

## 3. Giao diện Nhịp sinh học & Tối giản Zen (Circadian & Minimalist UI)

*   **Lời chào động theo thời gian thực (Circadian Greeting)**:
    *   Tiêu đề trang chủ tự động điều chỉnh lời chào dựa vào nhịp sinh học tự nhiên để kết nối ấm áp với người dùng:
        *   *Sáng (5h - 12h)*: `"Chào ngày mới nhẹ nhõm, [Tên]"`
        *   *Chiều (12h - 17h)*: `"Bình yên giữa ngày, [Tên]"`
        *   *Tối (17h - 5h)*: `"Khép lại ngày, thả lỏng... [Tên]"`
*   **Giảm tải gánh nặng nhận thức (Low Visual Weight)**:
    *   Sử dụng nền tối thâm trầm (`slateDark` và `#0d1115`) giúp giảm thiểu kích thích thụ thể ánh sáng ở võng mạc, từ đó kích hoạt chế độ thư giãn của dây thần kinh phế vị.
    *   Các thẻ chính (Main Anchor Cards) sử dụng kích thước và padding nhỏ gọn để tối ưu hóa không gian trống (whitespaces):
        *   Bán kính bo góc thẻ: `radius: 24`.
        *   Đệm lề trong thẻ: `padding: 20`.
        *   Mô tả ngắn gọn, nhẹ nhàng (1-2 dòng) thay vì các đoạn văn dài dòng.
        *   Nút bấm hành động nhỏ gọn, chữ thanh mảnh.
    *   Dùng hiệu ứng kính mờ (`GlassContainer`) với độ mờ nền thấp (`0.05` - `0.18`) kèm viền mỏng mờ sương sang trọng.

---

## 4. Quy chuẩn Trải nghiệm tương tác (Interaction & Gestures)

*   **Chạm giữ để kích hoạt (Hold-to-Activate)**:
    *   Đối với các hành động mang tính lắng dịu và cam kết (như gieo hạt mầm), yêu cầu chạm giữ trong **3 giây**.
    *   Đi kèm với phản hồi xúc giác nhẹ nhàng (`HapticFeedback.lightImpact`) khi bắt đầu chạm giữ và khi hoàn thành để tăng cảm giác sờ chạm vật lý chân thật.
*   **Mở rộng vùng chạm (Generous Hit Targets)**:
    *   Trong các trạng thái tĩnh tâm (người dùng có thể nhắm mắt), vùng tương tác phải cực kỳ rộng rãi.
    *   *Quy tắc cụ thể*: Cho phép chạm vào **bất kỳ điểm nào trên vòng tròn tiến trình đếm ngược** của màn hình Khoảng Lặng để Bắt đầu/Tạm dừng, thay vì bắt buộc phải bấm trúng nút Play/Pause nhỏ ở tâm.
*   **Đồng bộ tương tác và gợi ý tư thế**:
    *   Khi chưa bắt đầu đếm ngược, hiển thị dòng gợi ý tư thế mờ nhẹ dưới tiêu đề: *"Hãy ngồi thoải mái, thả lỏng vai và khép hờ mắt..."*. Dòng này tự động ẩn đi bằng hiệu ứng `AnimatedOpacity` khi bắt đầu để người dùng tập trung.

---

## 5. Thiết kế Layout thích ứng & Chống tràn (Responsive & Keyboard-Safe Layout)

*   **Chống tràn màn hình khi hiển thị bàn phím (RenderFlex Overflow Prevention)**:
    *   Mọi màn hình nhập liệu (như *Gương tự vấn*, *Khoảng buông*) phải tự động co giãn khi bàn phím đẩy lên.
    *   Sử dụng bộ khung: `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox` + `IntrinsicHeight` để nội dung cuộn mượt mà.
    *   **Focus Mode**: Đăng ký trạng thái focus node của TextField. Khi bàn phím hiện lên (`_focusNode.hasFocus`):
        *   Tự động ẩn bớt các tiêu đề phụ, nhãn hướng dẫn phía trên để đẩy khung nhập liệu lên sát mép trên.
        *   Sử dụng `AnimatedSwitcher` kết hợp `SizeTransition` và `FadeTransition` để thu hẹp chiều cao và ẩn hoàn toàn các nút hành động ở đáy về `SizedBox.shrink()`. Điều này giải phóng tối đa không gian cho TextField nhập liệu.
*   **Khoảng cách an toàn ở đáy (Safe Bottom Spacing)**:
    *   Đảm bảo các nút bấm ở cuối trang luôn có một khoảng đệm an toàn tối thiểu (ví dụ: `SizedBox(height: 24)`) phía trước để khi màn hình co lại hết cỡ, nút bấm không bao giờ bị dính sát vào nội dung phía trên.
*   **Nhấp ra ngoài để ẩn bàn phím**:
    *   Bao bọc màn hình nhập liệu bằng `GestureDetector` gọi `unfocus()` để người dùng có thể đóng bàn phím dễ dàng bằng cách chạm vào khoảng trống nền.

---

## 6. Quy chuẩn về Âm thanh (Audio Lifecycle & Fading)

*   **Giảm âm lượng tuyến tính (Volume Fade-Out)**:
    *   Khi nhạc ngủ ngon gần hết (10 giây cuối cùng), âm lượng phải giảm dần tuyến tính từ mức hiện tại về 0 trong vòng 10 giây trước khi dừng hẳn. Điều này ngăn chặn kích thích đột ngột (Startle Effect) gây adrenaline spike làm người dùng giật mình tỉnh giấc.
*   **Quản lý vòng đời âm thanh nghiêm ngặt**:
    *   Khi người dùng back/pop hoặc thoát khỏi màn hình phát nhạc, âm thanh phải dừng ngay lập tức.
    *   **Ngăn ngừa lỗi Defunct BuildContext**: Trong hàm `dispose()` của màn hình, không được gọi `context.read<Bloc>()` (vì context lúc này đã bị huỷ). Phải lưu tham chiếu của Bloc vào biến cục bộ trong `didChangeDependencies()` và sử dụng biến này để gửi sự kiện reset âm thanh trong `dispose()`.
    *   **Race Condition**: Trong BLoC âm thanh, trước khi gọi `play()`, luôn kiểm tra xem người dùng có yêu cầu dừng nhạc (`state.isPlayingSound == false`) trong lúc bài hát đang tải hay không. Nếu có, lập tức hủy tiến trình phát.

---

## 7. Đồng bộ Typography & Phong cách Mỹ thuật

*   **Font mặc định (Sans-serif)**:
    *   Sử dụng font **`Nunito`** làm phông chữ mặc định của hệ thống theme (thiết lập `fontFamily` mặc định trong `ThemeData`). Phông chữ này giúp đọc các nội dung hướng dẫn, nhãn nút, thông báo một cách rõ ràng và hiện đại.
*   **Font chiêm nghiệm (Serif)**:
    *   Sử dụng font **`Lora`** cho các tiêu đề chính, các câu hỏi tự vấn hoặc trích dẫn suy ngẫm để mang lại cảm giác chiều sâu, cổ điển và tri thức.

---

## 8. Bảo mật & Offline-First (Data Privacy)

*   **Tính riêng tư tuyệt đối cho thế giới nội tâm**:
    *   Dữ liệu chi tiết về cảm xúc, nguyện ước sáng và nhật ký tối được lưu trữ hoàn toàn ở bộ nhớ thiết bị cá nhân (local state/SharedPreferences).
    *   Không đồng bộ hóa dữ liệu chi tiết này lên cloud để bảo vệ tính riêng tư tuyệt đối của lữ khách.
