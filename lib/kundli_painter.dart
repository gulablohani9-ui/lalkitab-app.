import 'package:flutter/material.dart';

class KundliPainter extends CustomPainter {
  final Map<String, int> chart;
  KundliPainter(this.chart);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var w = size.width;
    var h = size.height;

    // Outer Rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // Diagonals
    canvas.drawLine(Offset(0, 0), Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);

    // Inner Diamond
    var path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, paint);

    // Draw Planet Text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    Map<int, Offset> houseOffsets = {
      1: Offset(w * 0.45, h * 0.20),
      2: Offset(w * 0.22, h * 0.10),
      3: Offset(w * 0.10, h * 0.22),
      4: Offset(w * 0.25, h * 0.45),
      5: Offset(w * 0.10, h * 0.70),
      6: Offset(w * 0.22, h * 0.85),
      7: Offset(w * 0.45, h * 0.75),
      8: Offset(w * 0.70, h * 0.85),
      9: Offset(w * 0.85, h * 0.70),
      10: Offset(w * 0.70, h * 0.45),
      11: Offset(w * 0.85, h * 0.22),
      12: Offset(w * 0.70, h * 0.10),
    };

    Map<int, List<String>> housePlanets = {};
    chart.forEach((planet, house) {
      housePlanets.putIfAbsent(house, () => []).add(planet.substring(0, 2));
    });

    housePlanets.forEach((house, planets) {
      Offset pos = houseOffsets[house] ?? Offset.zero;
      textPainter.text = TextSpan(
        text: planets.join(","),
        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
