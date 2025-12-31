import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final DateTime date;
  final int orderIndex; // Sıralama için eklendi

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.date,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'date': date.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}
