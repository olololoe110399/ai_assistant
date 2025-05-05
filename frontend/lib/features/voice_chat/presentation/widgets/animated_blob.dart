import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class AnimatedBlob extends StatefulWidget {
  const AnimatedBlob({this.speed = 1, this.size = 200, super.key})
    : assert(
        speed >= 1 && speed <= 5,
        'Speed factor should be an int between 1 and 5(inclusive)',
      );

  /// min 1, max 5
  final int speed;
  final double size;

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<BlobPoint> _points;

  List<BlobPoint> _createBlobPoints({
    required int numPoints,
    required double centerX,
    required double centerY,
    required double minRadius,
    required double maxRadius,
    required double minDuration,
    required double maxDuration,
  }) {
    final points = <BlobPoint>[];
    final slice = 2 * math.pi / numPoints;
    final startAngle = _random(0, 2 * math.pi);

    for (var i = 0; i < numPoints; i++) {
      final angle = startAngle + i * slice;
      final duration = _random(minDuration, maxDuration);
      final point = BlobPoint(
        centerX: centerX,
        centerY: centerY,
        angle: angle,
        minRadius: minRadius,
        maxRadius: maxRadius,
        phase: _random(0, duration),
        duration: duration,
      );
      points.add(point);
    }
    return points;
  }

  double _random(double min, double max) {
    return min + (max - min) * math.Random().nextDouble();
  }

  double get _size => widget.size;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10 ~/ widget.speed),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.repeat(reverse: true);

    _points = _createBlobPoints(
      numPoints: 7,
      centerX: _size / 2,
      centerY: _size / 2,
      minRadius: _size * 0.4,
      maxRadius: _size * 0.5,
      minDuration: 2,
      maxDuration: 4,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).brightness == Brightness.dark
            ? lightColors
            : dartColors;
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ClipPath(
            clipper: BlobPath(_points, _animation.value),
            child: AnimatedMeshGradient(
              colors: colors,
              options: AnimatedMeshGradientOptions(
                speed: widget.speed * 3,
                amplitude: 25,
              ),
            ),
          );
        },
      ),
    );
  }
}

class BlobPath extends CustomClipper<Path> {
  const BlobPath(this.points, this.animationValue);

  final List<BlobPoint> points;
  final double animationValue;

  @override
  Path getClip(Size size) => _cardinalSpline(points, true, 1, animationValue);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

Path _cardinalSpline(
  List<BlobPoint> data,
  bool closed,
  double tension,
  double t,
) {
  final path = Path();
  if (data.isEmpty) return path..moveTo(0, 0);

  final size = data.length - (closed ? 0 : 1);
  final positions = data.map((p) => p.getPosition(t)).toList();

  path.moveTo(positions[0].dx, positions[0].dy);

  for (var i = 0; i < size; i++) {
    Offset p0;
    Offset p1;
    Offset p2;
    Offset p3;

    if (closed) {
      p0 = positions[(i - 1 + size) % size];
      p1 = positions[i];
      p2 = positions[(i + 1) % size];
      p3 = positions[(i + 2) % size];
    } else {
      p0 = i == 0 ? positions[0] : positions[i - 1];
      p1 = positions[i];
      p2 = positions[i + 1];
      p3 = i == size - 1 ? p2 : positions[i + 2];
    }

    final x1 = p1.dx + ((p2.dx - p0.dx) / 6) * tension;
    final y1 = p1.dy + ((p2.dy - p0.dy) / 6) * tension;
    final x2 = p2.dx - ((p3.dx - p1.dx) / 6) * tension;
    final y2 = p2.dy - ((p3.dy - p1.dy) / 6) * tension;

    path.cubicTo(x1, y1, x2, y2, p2.dx, p2.dy);
  }

  if (closed) path.close();
  return path;
}

class BlobPoint {
  const BlobPoint({
    required this.centerX,
    required this.centerY,
    required this.angle,
    required this.minRadius,
    required this.maxRadius,
    required this.phase,
    required this.duration,
  });
  final double centerX;
  final double centerY;
  final double angle;
  final double minRadius;
  final double maxRadius;
  final double phase;
  final double duration;

  Offset getPosition(double t) {
    // Soften the transition by adjusting the progress calculation
    final progress = (t * duration + phase) % 1;
    // Use a smoother interpolation instead of sharp sine
    final eased =
        0.5 - 0.5 * math.cos(progress * 2 * math.pi); // 0 to 1 and back
    final radius = minRadius + (maxRadius - minRadius) * eased;
    return Offset(
      centerX + math.cos(angle) * radius,
      centerY + math.sin(angle) * radius,
    );
  }
}

const lightColors = [
  Color(0xFF202020),
  Color(0xFF777777),
  Color(0xFF454545),
  Color(0xFFE0E0E0),
];
const dartColors = [
  Color(0xFFF0F0F0),
  Color(0xFFC6C6C6),
  Color(0xFFE2E2E2),
  Color(0xFF060606),
];
