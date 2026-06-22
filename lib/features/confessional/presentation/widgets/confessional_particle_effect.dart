import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class ConfessionalParticleEffect extends StatefulWidget {
  final bool isBurning;
  final VoidCallback onComplete;
  final Widget child;

  const ConfessionalParticleEffect({
    super.key,
    required this.isBurning,
    required this.onComplete,
    required this.child,
  });

  @override
  State<ConfessionalParticleEffect> createState() => _ConfessionalParticleEffectState();
}

class _ConfessionalParticleEffectState extends State<ConfessionalParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _controller.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.update();
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ConfessionalParticleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBurning && !oldWidget.isBurning) {
      _startBurning();
    }
  }

  void _startBurning() {
    _particles.clear();
    for (int i = 0; i < 120; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble() * 320 + 20,
        y: _random.nextDouble() * 150 + 50,
        vx: (_random.nextDouble() - 0.5) * 1.5,
        vy: -(_random.nextDouble() * 2.0 + 1.0),
        size: _random.nextDouble() * 3.5 + 1.0,
        color: _random.nextDouble() > 0.4
            ? ZenTheme.softGold.withOpacity(_random.nextDouble() * 0.7 + 0.3)
            : ZenTheme.sageGreen.withOpacity(_random.nextDouble() * 0.6 + 0.2),
        life: 1.0,
        decay: 0.008 + _random.nextDouble() * 0.015,
      ));
    }

    setState(() {
      _opacity = 0.0;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: widget.child,
        ),
        if (widget.isBurning)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(_particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double life;
  double decay;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.life,
    required this.decay,
  });

  void update() {
    x += vx;
    y += vy;
    vx += (Random().nextDouble() - 0.5) * 0.05;
    life -= decay;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      if (p.life > 0) {
        paint.color = p.color.withOpacity(p.color.opacity * p.life);
        canvas.drawCircle(
          Offset(p.x, p.y),
          p.size * p.life,
          paint,
        );
        
        if (p.size > 2.5) {
          final glowPaint = Paint()
            ..color = p.color.withOpacity(p.color.opacity * p.life * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          canvas.drawCircle(
            Offset(p.x, p.y),
            p.size * 2 * p.life,
            glowPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
