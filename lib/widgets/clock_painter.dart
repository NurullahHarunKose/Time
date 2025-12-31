import 'package:flutter/material.dart';
import 'dart:math';
import '../models/activity.dart';

class ClockPainter extends CustomPainter {
  final List<Activity> activities;
  final DateTime currentTime;
  final bool isNightTime;

  ClockPainter({
    required this.activities,
    required this.currentTime,
    required this.isNightTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width * 0.45 : size.height * 0.45;
    
    // Saat arkaplanı
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dış çember
    final outerCirclePaint = Paint()
      ..color = isNightTime ? Colors.indigo.shade100 : Colors.blue.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // İç çember
    final innerCirclePaint = Paint()
      ..color = isNightTime ? Colors.indigo.shade50 : Colors.blue.shade50
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.85, innerCirclePaint);

    // Aktiviteleri çiz
    for (final activity in activities) {
      final startAngle = _timeToAngle(activity.startTime);
      final endAngle = _timeToAngle(activity.endTime);
      final sweepAngle = _normalizeAngle(endAngle - startAngle);
      
      final activityPaint = Paint()
        ..color = activity.color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.15;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.925),
        startAngle,
        sweepAngle,
        false,
        activityPaint,
      );
    }

    // Küçük çizgileri çiz
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * pi / 180;
      final isHour = i % 5 == 0;
      final outerRadius = radius;
      final innerRadius = radius * (isHour ? 0.85 : 0.9);
      
      final markerPaint = Paint()
        ..color = isHour 
            ? (isNightTime ? Colors.indigo.shade300 : Colors.blue.shade300)
            : (isNightTime ? Colors.indigo.shade100 : Colors.blue.shade100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHour ? 2 : 1;
      
      final innerX = center.dx + innerRadius * cos(angle);
      final innerY = center.dy + innerRadius * sin(angle);
      final outerX = center.dx + outerRadius * cos(angle);
      final outerY = center.dy + outerRadius * sin(angle);

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        markerPaint,
      );
    }

    // Saat numaralarını çiz
    for (int i = 1; i <= 12; i++) {
      final hour = isNightTime ? i + 12 : i;
      final angle = (i * 30 - 90) * pi / 180;
      final textRadius = radius * 0.75;
      final x = center.dx + textRadius * cos(angle);
      final y = center.dy + textRadius * sin(angle);

      final textSpan = TextSpan(
        text: hour.toString(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isNightTime ? Colors.indigo.shade700 : Colors.blue.shade700,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Saat ve dakika kollarını çiz
    final currentHour = isNightTime 
        ? currentTime.hour - 12 
        : (currentTime.hour >= 12 ? currentTime.hour - 12 : currentTime.hour);
    final hourAngle = (currentHour + currentTime.minute / 60.0) * 30 * pi / 180 - pi / 2;
    final minuteAngle = currentTime.minute * 6 * pi / 180 - pi / 2;

    // Saat kolu
    final hourHandPaint = Paint()
      ..color = isNightTime ? Colors.indigo : Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandLength = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(hourAngle) * hourHandLength,
        center.dy + sin(hourAngle) * hourHandLength,
      ),
      hourHandPaint,
    );

    // Dakika kolu
    final minuteHandPaint = Paint()
      ..color = isNightTime ? Colors.indigo : Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final minuteHandLength = radius * 0.7;
    final dashLength = 6.0;
    final gapLength = 3.0;
    var distance = 0.0;
    final dx = cos(minuteAngle);
    final dy = sin(minuteAngle);

    while (distance < minuteHandLength) {
      final startDistance = distance;
      distance += dashLength;
      if (distance > minuteHandLength) {
        distance = minuteHandLength;
      }

      canvas.drawLine(
        Offset(
          center.dx + dx * startDistance,
          center.dy + dy * startDistance,
        ),
        Offset(
          center.dx + dx * distance,
          center.dy + dy * distance,
        ),
        minuteHandPaint,
      );

      distance += gapLength;
    }

    // Merkez noktası
    final centerDotPaint = Paint()
      ..color = isNightTime ? Colors.indigo : Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double _timeToAngle(TimeOfDay time) {
    final minutes = time.hour * 60 + time.minute;
    final totalMinutes = 720; // 12 saat = 720 dakika
    return (minutes / totalMinutes) * 2 * pi - pi / 2;
  }

  double _normalizeAngle(double angle) {
    if (angle < 0) {
      angle += 2 * pi;
    }
    return angle;
  }
} 