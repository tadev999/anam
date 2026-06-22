# Anam Software Architecture & Coding Guidelines

Tài liệu này định nghĩa hệ thống kiến trúc phần mềm, quy chuẩn quản lý trạng thái (State Management) và các nguyên tắc lập trình của ứng dụng Anam. Bất kỳ mã nguồn mới nào liên quan đến logic, dữ liệu hoặc nghiệp vụ bắt buộc phải đối chiếu và tuân thủ các quy định dưới đây.

---

## 1. Cấu trúc thư mục định hướng theo Tính năng (Feature-First Architecture)

Tất cả các chức năng của ứng dụng bắt buộc phải được tổ chức và phân chia rõ ràng theo từng thư mục tính năng riêng biệt nằm trong `lib/features/`. Tránh gom chung tất cả Model hoặc View của mọi tính năng vào một thư mục dùng chung toàn cục.

### Cấu trúc thư mục chuẩn cho mỗi Tính năng (Feature):
Mỗi tính năng trong `lib/features/feature_name/` phải tuân thủ cấu trúc 3 phân lớp sau:

```markdown
lib/features/feature_name/
├── data/                             <-- Tầng Dữ liệu của tính năng
│   ├── models/                       <-- Các thực thể dữ liệu (Model) của tính năng này
│   └── data_sources/repository/       <-- API provider hoặc Repo riêng của tính năng này
├── bloc/                             <-- Tầng Logic nghiệp vụ (BLoC) của tính năng
│   ├── feature_name_bloc.dart        <-- Lớp xử lý chính
│   ├── feature_name_event.dart       <-- Định nghĩa các hành động nhận vào
│   └── feature_name_state.dart       <-- Định nghĩa các trạng thái phát ra
└── presentation/                     <-- Tầng Hiển thị giao diện của tính năng
    ├── screens/                      <-- Các màn hình chính (Views)
    └── widgets/                      <-- Các widget con dùng riêng cho tính năng này
```

### Các thư mục dùng chung toàn cục (Shared / Core):
* **`lib/core/`**: Chứa các cấu hình chung của toàn bộ ứng dụng như: `theme.dart` (Giao diện màu sắc Zen), `constants.dart` (Hằng số), hoặc các dịch vụ dùng chung toàn hệ thống (`FirebaseConfig`, `LocalStorage`).
* **`lib/shared/`**: Chứa các Widget dùng chung cho toàn bộ app (ví dụ: `GlassContainer` dùng chung, `ZenButton` dùng chung).

---

## 2. Quy tắc Thiết kế BLoC (BLoC Design Rules)

### A. Naming Conventions (Quy chuẩn đặt tên)
* **Events**: Phải đặt theo cấu trúc `Thì hiện tại + Động từ + Danh từ`. Ví dụ: `LoadUserProfile`, `SubmitFeedback`, `UpdateSpiritualPoints`. Tất cả các Event phải kế thừa từ một class Event cha (ví dụ: `abstract class UserEvent extends Equatable`).
* **States**: Phải đặt theo cấu trúc trạng thái rõ ràng:
  * `XInitial` (Trạng thái ban đầu)
  * `XLoading` (Đang tải/Xử lý)
  * `XSuccess` (Thành công - chứa dữ liệu trả về)
  * `XFailure` (Thất bại - chứa thông báo lỗi hoặc Error Object)
* **BLoC**: Đặt tên dạng `FeatureNameBloc` kế thừa từ `Bloc<FeatureEvent, FeatureState>`.

### B. Sử dụng Equatable
* Tất cả `Events` và `States` **bắt buộc** phải kế thừa từ `Equatable` để tối ưu hóa hiệu năng, tránh việc Flutter rebuild giao diện không cần thiết khi dữ liệu không thay đổi.
```dart
class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}
```

### C. Phát xạ Trạng thái (State Mutation)
* **Không bao giờ** thay đổi trạng thái trực tiếp.
* Luôn sử dụng phương thức `copyWith` trên State cũ để phát xạ ra một thực thể State mới qua hàm `emit()`.
```dart
emit(state.copyWith(status: UserStatus.success, user: newUser));
```

---

## 3. Quy tắc tích hợp BLoC vào UI (UI Integration Rules)

* **BlocProvider**: Chỉ khởi tạo BLoC ở tầng cao nhất có nhu cầu sử dụng. Luôn đóng (dispose) BLoC khi Widget tương ứng bị huỷ (BlocProvider tự động xử lý việc này).
* **BlocBuilder**: Chỉ sử dụng khi cần vẽ lại giao diện dựa trên State thay đổi. Hãy sử dụng tham số `buildWhen` để lọc các điều kiện rebuild cần thiết nhằm tối ưu hoá hiệu năng.
* **BlocListener**: Chỉ dùng cho các hành động diễn ra một lần (Side Effects) như: Hiển thị Dialog, SnackBar, hoặc Điều hướng trang (Navigation). Sử dụng `listenWhen` để lọc điều kiện lắng nghe.
* **BlocConsumer**: Chỉ dùng khi Widget vừa cần rebuild giao diện, vừa cần thực hiện Side Effect đồng thời từ một trạng thái.

---

## 4. Kiểm thử BLoC (BLoC Unit Testing)
* Bắt buộc sử dụng thư viện `bloc_test` để viết các bài test kiểm tra luồng phát xạ trạng thái:
```dart
blocTest<UserBloc, UserState>(
  'Phát ra [Loading, Success] khi kích hoạt LoadUserProfile thành công',
  build: () => UserBloc(repository: mockRepository),
  act: (bloc) => bloc.add(LoadUserProfile()),
  expect: () => [
    UserLoading(),
    UserSuccess(user: mockUser),
  ],
);
```
