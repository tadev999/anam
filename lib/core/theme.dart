import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenTheme {
  // Bảng màu Wabi-Sabi tối ấm áp (Warm Charcoal & Clay)
  static const Color slateDark = Color(0xff151312); // Nền tối nâu đất sét ấm áp
  static const Color slateMedium = Color(0xff1d1918); // Nền phụ tối ấm
  static const Color slateLight = Color(0xff272321); // Màu của card/container tối
  
  static const Color sageGreen = Color(0xff8fa89b); // Xanh xô thơm tĩnh lặng
  static const Color sageLight = Color(0xffb5c7be); // Xanh nhạt
  
  static const Color softGold = Color(0xffd4af37); // Vàng hổ phách ấm áp
  static const Color creamWhite = Color(0xfff4f1eb); // Trắng kem giấy dó mềm mại
  static const Color softGray = Color(0xffa39b95); // Xám xơ linen sáng hơn để tăng tương phản, hỗ trợ đọc dễ dàng

  // Bảng màu Wabi-Sabi sáng tinh tế (Linen & Sand)
  static const Color sandLight = Color(0xfffaf8f5); // Nền card sáng mịn màng
  static const Color sandMedium = Color(0xfff4efea); // Nền sáng giấy dó thô
  static const Color sandDark = Color(0xffebe6df); // Màu phụ sáng đất cát
  
  static const Color charcoalBrown = Color(0xff2c2825); // Chữ chính sáng (không dùng đen tuyền)
  static const Color clayGray = Color(0xff7d756e); // Chữ phụ sáng mộc mạc

  // Bảng màu phụ cho trạng thái cảm xúc
  static const Color mistRed = Color(0xffc98b8b); // Đỏ đất nung nhẹ
  static const Color inkBlue = Color(0xff6a8caf); // Xanh mực thâm trầm

  // Cấu hình Dark Theme (Tối ấm áp Wabi-Sabi)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: sageGreen,
      scaffoldBackgroundColor: slateDark,
      dividerColor: creamWhite.withOpacity(0.08),
      cardColor: slateLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: creamWhite, size: 20),
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.dark(
        primary: sageGreen,
        secondary: softGold,
        surface: slateMedium,
        error: mistRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(
          fontSize: 34, // Tăng từ 32 lên 34
          fontWeight: FontWeight.bold,
          color: creamWhite,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 26, // Tăng từ 24 lên 26
          fontWeight: FontWeight.w600,
          color: creamWhite,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22, // Tăng từ 20 lên 22
          fontWeight: FontWeight.w600,
          color: creamWhite,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 17, // Tăng từ 16 lên 17
          fontWeight: FontWeight.normal,
          color: creamWhite.withOpacity(0.9),
          height: 1.6, // Tăng từ 1.5 để văn bản tiếng Việt dễ đọc, thoáng đạt hơn
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15, // Tăng từ 14 lên 15
          color: softGray,
          height: 1.5, // Tăng từ 1.4 để các dòng chữ không chồng lấn dấu thanh
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 15, // Tăng từ 14 lên 15
          fontWeight: FontWeight.bold,
          color: creamWhite,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: slateLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 0,
      ),
    );
  }

  // Cấu hình Light Theme (Sáng Linen & Sand Wabi-Sabi)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: sageGreen,
      scaffoldBackgroundColor: sandMedium,
      dividerColor: charcoalBrown.withOpacity(0.08),
      cardColor: sandLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: charcoalBrown, size: 20),
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.light(
        primary: sageGreen,
        secondary: softGold,
        surface: sandLight,
        error: mistRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(
          fontSize: 34, // Tăng từ 32 lên 34
          fontWeight: FontWeight.bold,
          color: charcoalBrown,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 26, // Tăng từ 24 lên 26
          fontWeight: FontWeight.w600,
          color: charcoalBrown,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22, // Tăng từ 20 lên 22
          fontWeight: FontWeight.w600,
          color: charcoalBrown,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 17, // Tăng từ 16 lên 17
          fontWeight: FontWeight.normal,
          color: charcoalBrown.withOpacity(0.9),
          height: 1.6, // Tăng từ 1.5 để văn bản tiếng Việt dễ đọc, thoáng đạt hơn
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15, // Tăng từ 14 lên 15
          color: clayGray,
          height: 1.5, // Tăng từ 1.4 để các dòng chữ không chồng lấn dấu thanh
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 15, // Tăng từ 14 lên 15
          fontWeight: FontWeight.bold,
          color: charcoalBrown,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: sandLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 0,
      ),
    );
  }

  // Tiện ích lấy Background Gradient thích ứng động
  static LinearGradient getBackgroundGradient(BuildContext context, {bool isConfessional = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      if (isConfessional) {
        return const LinearGradient(
          colors: [slateDark, Color(0xff1d1212)], // Dark Earthy Clay + Warm Terracotta Mud
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }
      return const LinearGradient(
        colors: [slateDark, Color(0xff0d0c0c)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      if (isConfessional) {
        return const LinearGradient(
          colors: [sandMedium, Color(0xffeddcd3)], // Linen + Soft Clay Terracotta Glow
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }
      return const LinearGradient(
        colors: [sandMedium, sandDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Tiện ích tạo hiệu ứng Frosted Glass (Kính mờ) thích ứng với chế độ sáng tối
  static BoxDecoration glassDecoration({
    Color? color,
    double opacity = 0.08,
    double radius = 24.0,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: (color ?? creamWhite).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: creamWhite.withOpacity(0.06),
              width: 1.0,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
