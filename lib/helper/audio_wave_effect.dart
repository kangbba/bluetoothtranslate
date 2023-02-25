import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioWaveEffect extends StatefulWidget {
  final bool isRecording;

  const AudioWaveEffect({required this.isRecording});

  @override
  _AudioWaveEffectState createState() => _AudioWaveEffectState();
}

class _AudioWaveEffectState extends State<AudioWaveEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleWavePainter(
        isRecording: widget.isRecording,
        animationValue: _animation.value,
        color: Theme.of(context).primaryColor,
      ),
      child: Container(),
    );
  }
}

class CircleWavePainter extends CustomPainter {
  final bool isRecording;
  final double animationValue;
  final Color color;

  CircleWavePainter({
    required this.isRecording,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRecording ? 10 : 0;

    final path = Path();
    for (double i = 0; i < 2 * math.pi; i += 0.2) {
      final x = center.dx + (radius + 20) * math.cos(i + animationValue);
      final y = center.dy + (radius + 20) * math.sin(i + animationValue);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
