import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class DynamicBackground extends StatefulWidget {
  final Widget child;

  const DynamicBackground({super.key, required this.child});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = List.generate(40, (index) => _Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    // Automatic time-based logic: 6 AM to 6 PM is Daytime
    final isDaytime = hour >= 6 && hour < 18;

    final bgImage = isDaytime
        ? 'assets/images/day.jpg'
        : 'assets/images/night.jpg';

    return Stack(
      children: [
        // 1. Base Image Layer with scale and rotation
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: 0.02 * math.sin(_controller.value * 2 * math.pi),
                child: Transform.scale(
                  scale: 1.1 + 0.05 * math.cos(_controller.value * 2 * math.pi),
                  child: Image.asset(bgImage, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),

        // 2. Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              color: Colors.black.withValues(alpha: isDaytime ? 0.05 : 0.3),
            ),
          ),
        ),

        // 3. Floating Stars (Night Only)
        if (!isDaytime)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StarPainter(_stars, _controller.value),
                );
              },
            ),
          ),

        // 4. Animated Aura Layers
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Stack(
              children: [
                _buildAura(
                  alignment: Alignment(
                    -0.8 + 0.4 * math.cos(t * 2 * math.pi),
                    -0.7 + 0.3 * math.sin(t * 2 * math.pi),
                  ),
                  color: isDaytime
                      ? const Color(0xFF5E3A1A)
                      : const Color(0xFF1B0B2E),
                  radius: 2.0,
                  opacity: 0.6,
                ),
                _buildAura(
                  alignment: Alignment(
                    0.7 + 0.3 * math.sin(t * 2 * math.pi + 1.0),
                    0.6 + 0.4 * math.cos(t * 3 * math.pi),
                  ),
                  color: isDaytime
                      ? const Color(0xFF4A2C10)
                      : const Color(0xFF0A0214),
                  radius: 2.5,
                  opacity: 0.5,
                ),
                _buildAura(
                  alignment: Alignment(
                    0.5 * math.sin(t * 4 * math.pi),
                    -0.3 * math.cos(t * 2 * math.pi),
                  ),
                  color: isDaytime
                      ? const Color(0xFF7D4627)
                      : const Color(0xFF2D1142),
                  radius: 1.8,
                  opacity: 0.4,
                ),
              ],
            );
          },
        ),

        // 5. Grain Texture
        const Positioned.fill(child: _NoiseOverlay(opacity: 0.04)),

        // 6. Content
        widget.child,
      ],
    );
  }

  Widget _buildAura({
    required Alignment alignment,
    required Color color,
    required double radius,
    required double opacity,
  }) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.8],
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = math.Random().nextDouble() * 2 + 0.5;
  final double phase = math.Random().nextDouble() * 2 * math.pi;
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animationValue;

  _StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var star in stars) {
      final opacity =
          0.2 + 0.6 * math.sin(animationValue * 2 * math.pi + star.phase);
      paint.color = Colors.white.withValues(alpha: opacity.clamp(0, 1));
      final xPos =
          (star.x * size.width +
              10 * math.sin(animationValue * 2 * math.pi + star.phase)) %
          size.width;
      final yPos =
          (star.y * size.height +
              10 * math.cos(animationValue * 2 * math.pi + star.phase)) %
          size.height;
      canvas.drawCircle(Offset(xPos, yPos), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NoiseOverlay extends StatelessWidget {
  final double opacity;
  const _NoiseOverlay({this.opacity = 0.05});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(painter: _NoisePainter()),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);
    for (int i = 0; i < 4000; i++) {
      paint.color = Colors.white.withValues(alpha: random.nextDouble() * 0.3);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
