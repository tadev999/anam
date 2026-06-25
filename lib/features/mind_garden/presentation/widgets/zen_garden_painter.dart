import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../daily_anchor/data/models/anchor_model.dart';

class ZenGardenPainter extends CustomPainter {
  final Map<int, AnchorModel> dayAnchors;
  final int daysInMonth;

  ZenGardenPainter({
    required this.dayAnchors,
    required this.daysInMonth,
  });

  /// Hàm tĩnh để tính toán tọa độ (x, y) đồng đều và organic bằng thuật toán Fibonacci Spiral
  static Offset getDayOffset(int day, int totalDays, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Tối ưu bán kính tối đa của vườn
    final maxRadius = min(size.width, size.height) * 0.42;
    
    if (day == 1) return Offset(centerX, centerY);

    // Thuật toán phân bổ Fibonacci Spiral (Xoắn ốc Fibonacci)
    final d = day - 1;
    final total = totalDays - 1;
    
    final r = maxRadius * sqrt(d) / sqrt(total);
    final theta = d * 2.39996; // Góc vàng (Golden Angle) tính bằng radians

    final x = centerX + r * cos(theta);
    final y = centerY + r * sin(theta);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = min(size.width, size.height) * 0.42;

    // 1. Vẽ gợn sóng cát trắng Zen chủ đạo (Raked Sand Waves)
    final sandPaint = Paint()
      ..color = ZenTheme.creamWhite.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = maxRadius * 0.2; r <= maxRadius * 1.1; r += maxRadius * 0.18) {
      canvas.drawCircle(Offset(centerX, centerY), r, sandPaint);
    }

    // 2. Vẽ các emoji cảm xúc và các ngày trống
    for (int d = 1; d <= daysInMonth; d++) {
      final anchor = dayAnchors[d];
      final pos = getDayOffset(d, daysInMonth, size);

      // Tình huống A: Chưa có nghi lễ hoặc quên check-in (Chỉ vẽ cát cào định vị)
      if (anchor == null || !anchor.morningCompleted) {
        final slotPaint = Paint()
          ..color = ZenTheme.creamWhite.withOpacity(0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(pos, 6, slotPaint);
        _drawDayLabel(canvas, pos, d, false);
      } else if (!anchor.eveningCompleted) {
        // Tình huống B: Chỉ hoàn thành morning check-in (Bình minh 🌅)
        _drawEmoji(canvas, pos, "🌅", 15);
        _drawDayLabel(canvas, pos, d, true);
      } else {
        // Tình huống C: Hoàn thành trọn vẹn cả ngày (Vẽ theo eveningEmotion)
        final emotion = anchor.eveningEmotion;
        String emoji = "";
        switch (emotion) {
          case 'peaceful':
            emoji = "☀️";
            break;
          case 'grateful':
            emoji = "🌸";
            break;
          case 'burnout':
            emoji = "🔥";
            break;
          case 'overthinking':
            emoji = "🌀";
            break;
          case 'lonely':
            emoji = "🌑";
            break;
          case 'empty':
            emoji = "🫧";
            break;
          default:
            emoji = "⚪";
            break;
        }

        _drawEmoji(canvas, pos, emoji, 18);
        _drawDayLabel(canvas, pos, d, true);
      }

      // Vẽ thêm mầm ngủ ngon nếu có
      if (anchor != null && anchor.sleepSeedCollected) {
        _drawEmoji(canvas, Offset(pos.dx - 10, pos.dy + 10), "🌱", 12);
      }
    }
  }

  void _drawEmoji(Canvas canvas, Offset pos, String emoji, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  void _drawDayLabel(Canvas canvas, Offset pos, int day, bool hasData) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$day',
        style: TextStyle(
          color: ZenTheme.creamWhite.withOpacity(hasData ? 0.65 : 0.22),
          fontSize: 10.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Nunito',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(pos.dx + 8, pos.dy - 12));
  }

  @override
  bool shouldRepaint(covariant ZenGardenPainter oldDelegate) {
    return oldDelegate.dayAnchors != dayAnchors || oldDelegate.daysInMonth != daysInMonth;
  }
}
