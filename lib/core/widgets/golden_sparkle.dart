import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';

/// GoldenParticles — A custom painter that draws 40 golden particles
/// with slow upward drift, opacity pulsing, and subtle horizontal movement.
class GoldenParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;

  const GoldenParticles({
    super.key,
    this.particleCount = 40,
    this.particleColor = const Color(0xFFFFD700),
  });

  @override
  State<GoldenParticles> createState() => _GoldenParticlesState();
}

class _GoldenParticlesState extends State<GoldenParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => _Particle.random(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            particleColor: widget.particleColor,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double initialX;
  final double initialY;
  final double size;
  final double speedY;
  final double speedX;
  final double opacityMin;
  final double opacityRange;
  final double phase;

  _Particle({
    required this.initialX,
    required this.initialY,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.opacityMin,
    required this.opacityRange,
    required this.phase,
  });

  factory _Particle.random() {
    return _Particle(
      initialX: _Particle._rnd.nextDouble(),
      initialY: _Particle._rnd.nextDouble(),
      size: 1.0 + _Particle._rnd.nextDouble() * 2.0, // 1-3px
      speedY: -0.3 - _Particle._rnd.nextDouble() * 0.7, // -0.3 to -1.0
      speedX: (_Particle._rnd.nextDouble() - 0.5) * 0.4, // -0.2 to 0.2
      opacityMin: 0.10 + _Particle._rnd.nextDouble() * 0.10, // 10-20%
      opacityRange: 0.10 + _Particle._rnd.nextDouble() * 0.10, // 10-20% range
      phase: _Particle._rnd.nextDouble() * 2 * pi,
    );
  }

  static final _rnd = DateTime.now().millisecondsSinceEpoch;
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color particleColor;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Calculate current position with wrap-around
      double y = p.initialY + (p.speedY * progress * 10);
      y = y % 1.0;
      if (y < 0) y += 1.0;

      double x = p.initialX + (p.speedX * progress * 5);
      x = x % 1.0;
      if (x < 0) x += 1.0;

      // Opacity pulse using sine wave
      final opacityPulse = sin(progress * 2 * pi + p.phase);
      final opacity = p.opacityMin + (opacityPulse + 1) * 0.5 * p.opacityRange;

      final paint = Paint()
        ..color = particleColor.withOpacity(opacity.clamp(0.05, 0.30))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
