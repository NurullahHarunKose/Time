import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<Activity> _activities = [
    Activity(
      id: '1',
      title: 'Ahmet\'in doğum günü. Arayıp kutlamayı unutma!',
      description: 'Doğum günü kutlaması',
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 0, minute: 30),
      color: Activity.predefinedColors[2], // Mavi
      date: DateTime.now(),
      isAllDay: false,
    ),
    Activity(
      id: '2',
      title: 'Uyarı',
      description: 'Günün başlangıcı',
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 8, minute: 30),
      color: Activity.predefinedColors[0], // Kırmızı
      date: DateTime.now(),
      isAllDay: false,
    ),
    Activity(
      id: '3',
      title: 'İş',
      description: 'Mehmet\'i ara, telefon bekleniyor',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 0),
      color: Activity.predefinedColors[1], // Yeşil
      date: DateTime.now(),
      isAllDay: false,
    ),
    Activity(
      id: '4',
      title: 'Öğle yemeği, Hüveyla kafeye gide',
      description: 'Öğle yemeği molası',
      startTime: const TimeOfDay(hour: 12, minute: 0),
      endTime: const TimeOfDay(hour: 13, minute: 0),
      color: Activity.predefinedColors[2], // Mavi
      date: DateTime.now(),
      isAllDay: false,
    ),
    Activity(
      id: '5',
      title: 'Postalar',
      description: 'Posta işlemleri',
      startTime: const TimeOfDay(hour: 15, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      color: Activity.predefinedColors[0], // Kırmızı
      date: DateTime.now(),
      isAllDay: false,
    ),
    Activity(
      id: '6',
      title: 'Öğluma yüzme havuzu',
      description: 'Yüzme dersi',
      startTime: const TimeOfDay(hour: 19, minute: 0),
      endTime: const TimeOfDay(hour: 20, minute: 30),
      color: Activity.predefinedColors[0], // Kırmızı
      date: DateTime.now(),
      isAllDay: false,
    ),
  ];

  List<Activity> get activities => List.unmodifiable(_activities);

  List<Activity> getActivitiesForDate(DateTime date) {
    return _activities.where((activity) =>
      activity.date.year == date.year &&
      activity.date.month == date.month &&
      activity.date.day == date.day
    ).toList();
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void updateActivity(Activity activity) {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      notifyListeners();
    }
  }

  void deleteActivity(String id) {
    _activities.removeWhere((activity) => activity.id == id);
    notifyListeners();
  }
} 