import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';

class ZenTheme {
  // Bảng màu chuẩn từ an_match (Dark luxury, Calm & Warm Amber Accents)
  static const Color slateDark = AppColors.background; // 0xFF0F141C
  static const Color slateMedium = AppColors.surface; // 0xFF181F2C
  static const Color slateLight = AppColors.surfaceLight; // 0xFF222B3D
  
  static const Color sageGreen = AppColors.primary; // 0xFF2A9D8F (Mindful Sage Green)
  static const Color sageLight = AppColors.primaryLight; // 0xFF48B6A7
  
  static const Color softGold = AppColors.secondary; // 0xFFF4A261 (Warm Peach Gold)
  static const Color creamWhite = AppColors.textPrimary; // 0xFFF8FAFC
  static const Color softGray = AppColors.textSecondary; // 0xFF94A3B8

  // Bảng màu sáng tương thích (Linen & Sand)
  static const Color sandLight = Color(0xfff8fafc);
  static const Color sandMedium = Color(0xfff1f5f9);
  static const Color sandDark = Color(0xffe2e8f0);
  
  static const Color charcoalBrown = Color(0xff0f172a);
  static const Color clayGray = Color(0xff64748b);

  // Bảng màu trạng thái & Mạch Nội Sinh
  static const Color mistRed = AppColors.accentRose; // 0xFFE76F51
  static const Color inkBlue = AppColors.radarActive; // 0xFF2A9D8F

  // 🗺️ Màu định danh cho 5 Mạch Nội Sinh (Đồng bộ sắc thái an_match)
  static Color getCircuitColor(int circuitId) {
    switch (circuitId) {
      case 1:
        return AppColors.radarActive; // Mạch 1: Gọi Tên — Xanh tĩnh lặng (0xFF2A9D8F)
      case 2:
        return AppColors.warmAmber; // Mạch 2: Xây Nền Tảng — Cam đất hổ phách (0xFFE58062)
      case 3:
        return AppColors.gold; // Mạch 3: Hành Động Nhỏ — Vàng ấm (0xFFFFD166)
      case 4:
        return AppColors.accentRose; // Mạch 4: Nhận Ra Giá Trị — Hồng đất ấm (0xFFE76F51)
      case 5:
        return AppColors.primaryLight; // Mạch 5: Buông Bỏ — Xanh ngọc thanh thoát (0xFF48B6A7)
      default:
        return sageGreen;
    }
  }

  // 🌅 Gradient nhịp sinh học theo thời gian thực (Đồng điệu tông tối siêu dịu an_match)
  static LinearGradient getCircadianGradient({DateTime? time}) {
    final now = time ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      // 🌅 Sáng bình minh dịu êm
      return const LinearGradient(
        colors: [Color(0xFF0F141C), Color(0xFF161F2C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 11 && hour < 16) {
      // ☀️ Giữa ngày thanh thản
      return const LinearGradient(
        colors: [Color(0xFF0D1219), Color(0xFF141D2B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 16 && hour < 19) {
      // 🌆 Hoàng hôn ấm áp hổ phách
      return const LinearGradient(
        colors: [Color(0xFF12141C), Color(0xFF1F1D2B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // 🌙 Đêm tĩnh mịch sâu lắng
      return const LinearGradient(
        colors: [AppColors.background, Color(0xFF0A0E14)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Tiện ích lấy ThemeMode tự động (Ưu tiên Dark Theme chuẩn an_match)
  static ThemeMode getCircadianThemeMode({DateTime? time}) {
    return ThemeMode.dark;
  }

  // Cấu hình Dark Theme (Đồng nhất 100% với an_match AppTheme)
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      cardColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.glassBorder, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  // Cấu hình Light Theme
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: sandMedium,
      dividerColor: charcoalBrown.withValues(alpha: 0.08),
      cardColor: sandLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: charcoalBrown, size: 20),
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: charcoalBrown,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: sandLight,
        error: AppColors.error,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: charcoalBrown,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: charcoalBrown,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: charcoalBrown,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: charcoalBrown,
          fontSize: 16,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: clayGray,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: sandLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: charcoalBrown.withValues(alpha: 0.08)),
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
          colors: [AppColors.background, Color(0xFF1B1218)],
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

  // Tiện ích tạo hiệu ứng Frosted Glass (Kính mờ) chuẩn an_match
  static BoxDecoration glassDecoration({
    Color? color,
    double opacity = 0.85,
    double radius = 20.0,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
