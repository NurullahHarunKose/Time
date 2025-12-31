import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String content;
  final DateTime date;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.content,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NoteProvider with ChangeNotifier {
  Map<DateTime, List<Note>> _notes = {};
  final _prefs = SharedPreferences.getInstance();

  NoteProvider() {
    _loadNotes();
  }

  Map<DateTime, List<Note>> get notes => _notes;

  List<Note> getNotesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _notes[key] ?? [];
  }

  void addNote(DateTime date, String content) {
    final key = DateTime(date.year, date.month, date.day);
    final note = Note(
      id: const Uuid().v4(),
      content: content,
      date: key,
      createdAt: DateTime.now(),
    );

    if (_notes.containsKey(key)) {
      _notes[key]!.add(note);
    } else {
      _notes[key] = [note];
    }

    _saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String content) {
    for (var entry in _notes.entries) {
      final noteIndex = entry.value.indexWhere((note) => note.id == id);
      if (noteIndex != -1) {
        final oldNote = entry.value[noteIndex];
        entry.value[noteIndex] = Note(
          id: oldNote.id,
          content: content,
          date: oldNote.date,
          createdAt: oldNote.createdAt,
        );
        _saveNotes();
        notifyListeners();
        break;
      }
    }
  }

  void deleteNote(String id) {
    for (var entry in _notes.entries) {
      final noteList = entry.value;
      final initialLength = noteList.length;
      noteList.removeWhere((note) => note.id == id);
      if (noteList.length < initialLength) {
        if (noteList.isEmpty) {
          _notes.remove(entry.key);
        }
        _saveNotes();
        notifyListeners();
        break;
      }
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await _prefs;
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final notesMap = jsonDecode(notesJson) as Map<String, dynamic>;
      _notes = notesMap.map((key, value) {
        final date = DateTime.parse(key);
        final notesList = (value as List)
            .map((noteJson) => Note.fromJson(noteJson))
            .toList();
        return MapEntry(date, notesList);
      });
      notifyListeners();
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await _prefs;
    final notesJson = jsonEncode(_notes.map((key, value) {
      return MapEntry(
        key.toIso8601String(),
        value.map((note) => note.toJson()).toList(),
      );
    }));
    await prefs.setString('notes', notesJson);
  }
} 