import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/clock_painter.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/activity.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'daily_schedule_page.dart';
import 'package:uuid/uuid.dart';
import 'activity_form.dart';

class RightPage extends StatefulWidget {
  const RightPage({super.key});

  @override
  State<RightPage> createState() => _RightPageState();
}

class _RightPageState extends State<RightPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _showButtons = true;
  bool _isNightTime = false;
  bool _showNightClock = false;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  final PageController _pageController = PageController();
  bool _showCalendar = true;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _showNightClock = _isNightTime;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _updateCurrentTime() {
    if (!mounted) return;
    setState(() {
      _currentTime = DateTime.now();
      _isNightTime = _currentTime.hour >= 18 || _currentTime.hour < 6;
    });
    _timer = Timer(const Duration(minutes: 1), _updateCurrentTime);
  }

  Future<void> _showCalendarDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tarih Seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  Navigator.pop(context);
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                locale: 'tr_TR',
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Ay',
                  CalendarFormat.twoWeeks: '2 Hafta',
                  CalendarFormat.week: 'Hafta',
                },
                calendarStyle: CalendarStyle(
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                        _focusedDay = DateTime.now();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Bugün'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ScheduleProvider>().getActivitiesForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Günlük Plan'),
        // centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showNightClock = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_showNightClock ? Colors.lightBlue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: !_showNightClock ? null : Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sunny, color: !_showNightClock ? Colors.orange : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          '00:00-12:00',
                          style: TextStyle(
                            color: !_showNightClock ? Colors.black87 : Colors.grey,
                            fontWeight: !_showNightClock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showNightClock = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _showNightClock ? Colors.indigo[100] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: _showNightClock ? null : Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.nightlight_round, color: _showNightClock ? Colors.indigo : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          '12:00-24:00',
                          style: TextStyle(
                            color: _showNightClock ? Colors.black87 : Colors.grey,
                            fontWeight: _showNightClock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: ClockPainter(
                  activities: activities.where((activity) {
                    final hour = activity.startTime.hour;
                    return _showNightClock 
                        ? (hour >= 12 && hour < 24)
                        : (hour >= 0 && hour < 12);
                  }).toList(),
                  currentTime: _currentTime,
                  isNightTime: _showNightClock,
                ),
              ),
            ),
            if (activities.isNotEmpty) _buildActivityList(activities),
            const SizedBox(height: 80), // Alt kısımda boşluk bırak
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              FloatingActionButton(
                heroTag: 'toggleButtons',
                onPressed: () {
                  setState(() {
                    _showButtons = !_showButtons;
                  });
                },
                backgroundColor: Colors.purple,
                child: Icon(_showButtons ? Icons.visibility_off : Icons.visibility),
              ),
              const SizedBox(height: 4),
              const Text('Menü', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          if (_showButtons) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'toggleCalendar',
                  onPressed: () {
                    _showCalendarDialog();
                  },
                  tooltip: 'Takvimi Göster',
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.calendar_month),
                ),
                const SizedBox(height: 4),
                const Text('Takvim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'dailySchedule',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailySchedulePage(
                          selectedDate: _selectedDate,
                        ),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  tooltip: 'Günlük Program',
                  backgroundColor: Colors.cyan,
                  child: const Icon(Icons.view_timeline),
                ),
                const SizedBox(height: 4),
                const Text('Günlük Program', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'addActivity',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityForm(
                          selectedDate: _selectedDate,
                          onSave: (activity) {
                            context.read<ScheduleProvider>().addActivity(activity);
                            setState(() {});
                          },
                        ),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  tooltip: 'Yeni Aktivite Ekle',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 4),
                const Text('Ekle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildActivityList(List<Activity> activities) {
    final filteredActivities = activities.where((activity) {
      final hour = activity.startTime.hour;
      return _showNightClock 
          ? (hour >= 12 && hour < 24)
          : (hour >= 0 && hour < 12);
    }).toList();

    if (filteredActivities.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _showNightClock ? "12:00-24:00 Aktiviteleri" : "00:00-12:00 Aktiviteleri",
                style: TextStyle(
                fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filteredActivities.length,
            itemBuilder: (context, index) {
              final activity = filteredActivities[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 12,
                        decoration: BoxDecoration(
                      color: activity.color,
                          borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      Text(
                        '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                              style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
              Text(
                        activity.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                  fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<ScheduleProvider>().deleteActivity(activity.id);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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

      // Aktivite için özel şekil çiz
      final activityPath = Path();
      final startPoint = Offset(
        center.dx + cos(startAngle) * radius,
        center.dy + sin(startAngle) * radius
      );
      final endPoint = Offset(
        center.dx + cos(endAngle) * radius,
        center.dy + sin(endAngle) * radius
      );
      
      // Merkez noktadan başla
      activityPath.moveTo(center.dx, center.dy);
      
      // Yay çiz (saat yüzeyine temas eden kısım)
      activityPath.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false
      );
      
      // Merkeze geri dön
      activityPath.lineTo(center.dx, center.dy);
      activityPath.close();

      // Dilim çizimi
      final trianglePaint = Paint()
        ..color = activity.color.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(activityPath, trianglePaint);

      // İnce kenar çizgisi
      final borderPaint = Paint()
        ..color = activity.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawPath(activityPath, borderPaint);

      // Dış yay çizgisi (daha belirgin)
      final arcPaint = Paint()
        ..color = activity.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );

      // Merkez çizgileri (daha ince)
      final centerLinePaint = Paint()
        ..color = activity.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      // Yazı çizimi için hazırlık
      final midAngle = startAngle + sweepAngle / 2;

      // Açıyı 0-2pi aralığına normalize et
      double normalizedAngle = midAngle;
      while (normalizedAngle < 0) normalizedAngle += 2 * pi;
      while (normalizedAngle >= 2 * pi) normalizedAngle -= 2 * pi;

      // Saatin sol yarısı mı? (Saat 6 ile 12 arası)
      // pi/2 (90 derece) ile 3pi/2 (270 derece) arası sol taraftır
      bool isLeftSide = normalizedAngle > pi/2 && normalizedAngle < 3*pi/2;
      double textAngle = isLeftSide ? midAngle + pi : midAngle;
      
      // Metin kutusunun genişliği: İç çember (0.35r) ile dış çember (0.85r) arası - margin ile
      final availableWidth = radius * 0.45;
      String displayText = activity.title;
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      // Yazıyı çiz
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.left, // Soldan başlayarak (yönlendirmeye göre dıştan içe veya içten dışa)
        fontSize: 10,
        height: 1.1,
        maxLines: 2,
        ellipsis: '...',
      ))
        ..pushStyle(ui.TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ))
        ..addText(displayText);

      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: availableWidth));
      
      Offset textOffset;
      if (isLeftSide) {
        // Sol taraf: Koordinat sistemi 180 derece dönük.
        // X ekseni negatif yönde (sola doğru) artar.
        // Metin kutusunu -0.82r (dış çemberin hemen içi) noktasından başlatıyoruz.
        // TextAlign.left ile dıştan içe doğru yazılır.
        textOffset = Offset(-radius * 0.82, -paragraph.height / 2);
      } else {
        // Sağ taraf: Koordinat sistemi düz.
        // Metin kutusunu 0.35r (iç kenar) noktasından başlatıyoruz.
        textOffset = Offset(radius * 0.35, -paragraph.height / 2);
      }

      canvas.drawParagraph(paragraph, textOffset);
      canvas.restore();

      // Saat ve dakika kolları
      final currentHour = isNightTime 
          ? currentTime.hour - 12 
          : (currentTime.hour >= 12 ? currentTime.hour - 12 : currentTime.hour);
      final hourAngle = (currentHour + currentTime.minute / 60.0) * 30 * pi / 180 - pi / 2;
      final minuteAngle = currentTime.minute * 6 * pi / 180 - pi / 2;

      // Saat kolu gölgesi
      final hourShadowPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      final hourHandLength = radius * 0.5;
      canvas.drawLine(
        center + const Offset(2, 2),
        Offset(
          center.dx + cos(hourAngle) * hourHandLength + 2,
          center.dy + sin(hourAngle) * hourHandLength + 2,
        ),
        hourShadowPaint,
      );

      // Saat kolu
      final hourHandPaint = Paint()
        ..color = isNightTime ? Colors.indigo.shade600 : Colors.blue.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(hourAngle) * hourHandLength,
          center.dy + sin(hourAngle) * hourHandLength,
        ),
        hourHandPaint,
      );

      // Dakika kolu gölgesi
      final minuteShadowPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      final minuteHandLength = radius * 0.7;
      canvas.drawLine(
        center + const Offset(2, 2),
        Offset(
          center.dx + cos(minuteAngle) * minuteHandLength + 2,
          center.dy + sin(minuteAngle) * minuteHandLength + 2,
        ),
        minuteShadowPaint,
      );

      // Dakika kolu
      final minuteHandPaint = Paint()
        ..color = isNightTime ? Colors.indigo.shade400 : Colors.blue.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(minuteAngle) * minuteHandLength,
          center.dy + sin(minuteAngle) * minuteHandLength,
        ),
        minuteHandPaint,
      );

      // Merkez noktası gölgesi
      final centerShadowPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + const Offset(1, 1), 6, centerShadowPaint);

      // Merkez noktası
      final centerDotPaint = Paint()
        ..color = isNightTime ? Colors.indigo.shade700 : Colors.blue.shade700
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 5, centerDotPaint);
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
        textDirection: ui.TextDirection.ltr,
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
    final angle = (minutes / totalMinutes) * 2 * pi - pi / 2;
    
    // Gece saatleri için açıyı ayarla
    if (isNightTime && time.hour < 12) {
      return angle + pi;
    }
    return angle;
  }

  double _normalizeAngle(double angle) {
    if (angle < 0) {
      angle += 2 * pi;
    }
    return angle;
  }
} 