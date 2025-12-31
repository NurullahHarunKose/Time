import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String? description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  final DateTime date;
  final bool isAllDay;

  Activity({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.date,
    this.isAllDay = false,
  });

  // Önceden tanımlanmış aktivite renkleri
  static const List<Color> predefinedColors = [
    Color(0xFFFF5252), // Kırmızı
    Color(0xFF4CAF50), // Yeşil
    Color(0xFF2196F3), // Mavi
    Color(0xFFFFC107), // Sarı
    Color(0xFF9C27B0), // Mor
    Color(0xFF795548), // Kahverengi
    Color(0xFF607D8B), // Gri-Mavi
    Color(0xFFE91E63), // Pembe
    Color(0xFF00BCD4), // Turkuaz
    Color(0xFFFF9800), // Turuncu
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'color': color.value,
      'date': date.toIso8601String(),
      'isAllDay': isAllDay,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: TimeOfDay(
        hour: json['startTimeHour'],
        minute: json['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'],
        minute: json['endTimeMinute'],
      ),
      color: Color(json['color']),
      date: DateTime.parse(json['date']),
      isAllDay: json['isAllDay'] ?? false,
    );
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    DateTime? date,
    bool? isAllDay,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      date: date ?? this.date,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
} 