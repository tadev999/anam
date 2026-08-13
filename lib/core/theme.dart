import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenTheme {
  // Bảng màu Wabi-Sabi tối ấm áp (Warm Charcoal & Clay)
  static const Color slateDark = Color(0xff151312); // Nền tối nâu đất sét ấm áp
  static const Color slateMedium = Color(0xff1d1918); // Nền phụ tối ấm
  static const Color slateLight = Color(0xff272321); // Màu của card/container tối
  
  static const Color sageGreen = Color(0xff9cbbaa); // Xanh xô thơm ánh ngọc mượt mà (Sage Pearl)
  static const Color sageLight = Color(0xffb5c7be); // Xanh nhạt
  
  static const Color softGold = Color(0xffe5bf45); // Vàng hổ phách mật ong (Amber Honey Glow)
  static const Color creamWhite = Color(0xfff4f1eb); // Trắng kem giấy dó mềm mại
  static const Color softGray = Color(0xffa39b95); // Xám xơ linen nâng tương phản

  // Bảng màu Wabi-Sabi sáng tinh tế (Linen & Sand)
  static const Color sandLight = Color(0xfffaf8f5); // Nền card sáng mịn màng
  static const Color sandMedium = Color(0xfff4efea); // Nền sáng giấy dó thô
  static const Color sandDark = Color(0xffebe6df); // Màu phụ sáng đất cát
  
  static const Color charcoalBrown = Color(0xff2c2825); // Chữ chính sáng (không dùng đen tuyền)
  static const Color clayGray = Color(0xff7d756e); // Chữ phụ sáng mộc mạc

  // Bảng màu phụ cho trạng thái cảm xúc & Mạch Nội Sinh
  static const Color mistRed = Color(0xffd99b9b); // Đỏ đất nung ấm (Terracotta Rose)
  static const Color inkBlue = Color(0xff789ec6); // Xanh chàm tĩnh lặng (Serene Indigo)

  // 🗺️ Màu định danh cho 5 Mạch Nội Sinh
  static Color getCircuitColor(int circuitId) {
    switch (circuitId) {
      case 1:
        return const Color(0xff789ec6); // Mạch 1: Gọi Tên — Xanh chàm
      case 2:
        return const Color(0xff9cbbaa); // Mạch 2: Xây Nền Tảng — Xanh xô thơm
      case 3:
        return const Color(0xffe5bf45); // Mạch 3: Hành Động Nhỏ — Vàng hổ phách
      case 4:
        return const Color(0xffd99b9b); // Mạch 4: Nhận Ra Giá Trị — Đỏ đất nung
      case 5:
        return const Color(0xffb8c4bc); // Mạch 5: Buông Bỏ — Xám khói linen
      default:
        return sageGreen;
    }
  }

  // 🌅 Gradient nhịp sinh học theo thời gian thực (Circadian Ambient Gradient)
  static LinearGradient getCircadianGradient({DateTime? time}) {
    final now = time ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      // 🌅 Sáng hừng đông (Warm Clay Sunrise)
      return const LinearGradient(
        colors: [Color(0xff171412), Color(0xff1e1916)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 11 && hour < 16) {
      // ☀️ Giữa ngày thanh mát (Sage Dew)
      return const LinearGradient(
        colors: [Color(0xff131715), Color(0xff161f1b)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 16 && hour < 19) {
      // 🌆 Hoàng hôn ấm áp (Amber Twilight)
      return const LinearGradient(
        colors: [Color(0xff181411), Color(0xff211a14)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // 🌙 Đêm trầm tĩnh (Ink Midnight)
      return const LinearGradient(
        colors: [Color(0xff121417), Color(0xff0d1014)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Tiện ích lấy ThemeMode tự động theo nhịp sinh học ban ngày / đêm (Warm Dark First + Circadian Adaptive)
  static ThemeMode getCircadianThemeMode({DateTime? time}) {
    final hour = (time ?? DateTime.now()).hour;
    // Ban ngày (5h sáng - 17h chiều): Dùng Light Mode Giấy Dó (Linen Sand Wabi-Sabi)
    // Ban đêm (17h chiều - 5h sáng): Dùng Warm Dark Mode Đất Sét (Warm Charcoal)
    if (hour >= 5 && hour < 17) {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
  }

  // Cấu hình Dark Theme (Tối ấm áp Wabi-Sabi)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: sageGreen,
      scaffoldBackgroundColor: slateDark,
      dividerColor: creamWhite.withValues(alpha: 0.08),
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
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: creamWhite,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: creamWhite,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: creamWhite,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          color: creamWhite.withValues(alpha: 0.9),
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15,
          color: softGray,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 15,
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
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: sageGreen,
      scaffoldBackgroundColor: sandMedium,
      dividerColor: charcoalBrown.withValues(alpha: 0.08),
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
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: charcoalBrown,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: charcoalBrown,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: charcoalBrown,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          color: charcoalBrown.withValues(alpha: 0.9),
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15,
          color: clayGray,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 15,
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

  // Tiện ích lấy Background Gradient thích ứng động theo nhịp sinh học
  static LinearGradient getBackgroundGradient(BuildContext context, {bool isConfessional = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      if (isConfessional) {
        return const LinearGradient(
          colors: [slateDark, Color(0xff1d1212)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }
      return getCircadianGradient();
    } else {
      if (isConfessional) {
        return const LinearGradient(
          colors: [sandMedium, Color(0xffeddcd3)],
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
      color: (color ?? creamWhite).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: creamWhite.withValues(alpha: 0.06),
              width: 1.0,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
