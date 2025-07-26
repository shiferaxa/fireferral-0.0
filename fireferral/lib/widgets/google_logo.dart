import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;
  
  const GoogleLogo({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Google "G" shape
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    
    // Blue section (top-right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Green section (bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,     // 0 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Yellow section (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.57,  // 90 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Red section (top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,  // 180 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, paint);
    
    // "G" cutout
    paint.color = const Color(0xFF4285F4);
    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 0.2);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.2);
    path.lineTo(center.dx + radius * 0.3, center.dy);
    path.lineTo(center.dx + radius * 0.1, center.dy);
    path.lineTo(center.dx + radius * 0.1, center.dy + radius * 0.2);
    path.lineTo(center.dx, center.dy + radius * 0.2);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}