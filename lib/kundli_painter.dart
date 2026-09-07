import 'package:flutter/material.dart';

class KundliPainter extends CustomPainter {
  final Map<String, int> chart;
  KundliPainter(this.chart);

  @override
  void paint(Canvas canvas, Size size) {
    var borderPaint = Paint()
      ..color = Colors.deepOrange.shade800
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var linePaint = Paint()
      ..color = Colors.deepOrange.shade600
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var w = size.width;
    var h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
    canvas.drawLine(Offset(0, 0), Offset(w, h), linePaint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), linePaint);

    var path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, linePaint);

    // House Number Coordinates (Fixed 1 to 12)
    Map<int, Offset> houseNumberPositions = {
      1: Offset(w * 0.48, h * 0.28),
      2: Offset(w * 0.23, h * 0.14),
      3: Offset(w * 0.13, h * 0.24),
      4: Offset(w * 0.26, h * 0.48),
      5: Offset(w * 0.13, h * 0.74),
      6: Offset(w * 0.23, h * 0.84),
      7: Offset(w * 0.48, h * 0.68),
      8: Offset(w * 0.73, h * 0.84),
      9: Offset(w * 0.83, h * 0.74),
      10: Offset(w * 0.68, h * 0.48),
      11: Offset(w * 0.83, h * 0.24),
      12: Offset(w * 0.73, h * 0.14),
    };

    for (int i = 1; i <= 12; i++) {
      final numPainter = TextPainter(
        text: TextSpan(
          text: "$i",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(canvas, houseNumberPositions[i]!);
    }

    // Exact Centers of Houses
    Map<int, Offset> planetOffsets = {
      1: Offset(w * 0.36, h * 0.15),
      2: Offset(w * 0.15, h * 0.05),
      3: Offset(w * 0.03, h * 0.35),
      4: Offset(w * 0.15, h * 0.43),
      5: Offset(w * 0.03, h * 0.58),
      6: Offset(w * 0.15, h * 0.90),
      7: Offset(w * 0.36, h * 0.76),
      8: Offset(w * 0.65, h * 0.90),
      9: Offset(w * 0.78, h * 0.58),
      10: Offset(w * 0.65, h * 0.43),
      11: Offset(w * 0.78, h * 0.35),
      12: Offset(w * 0.65, h * 0.05),
    };

    Map<String, String> planetShortNames = {
      "Sun": "Su",
      "Moon": "Mo",
      "Mars": "Ma",
      "Mercury": "Me",
      "Jupiter": "Ju",
      "Venus": "Ve",
      "Saturn": "Sa",
      "Rahu": "Ra",
      "Ketu": "Ke",
    };

    Map<int, List<String>> housePlanets = {};
    chart.forEach((planet, house) {
      String code = planetShortNames[planet] ?? planet.substring(0, 2);
      housePlanets.putIfAbsent(house, () => []).add(code);
    });

    housePlanets.forEach((house, planets) {
      Offset basePos = planetOffsets[house] ?? Offset.zero;

      String displayText;
      if (planets.length > 2) {
        displayText = "${planets.take(2).join(',')}\n${planets.skip(2).join(',')}";
      } else {
        displayText = planets.join(",");
      }

      final planetPainter = TextPainter(
        text: TextSpan(
          text: displayText,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      planetPainter.paint(canvas, basePos);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
