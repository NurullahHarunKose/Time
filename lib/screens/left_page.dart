import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'all_notes_page.dart';
import 'package:intl/intl.dart';

class LeftPage extends StatefulWidget {
  const LeftPage({super.key});

  @override
  State<LeftPage> createState() => _LeftPageState();
}

class _LeftPageState extends State<LeftPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = true;
  bool _showButtons = true;
  bool _isEditing = false;
  String? _editingNoteId;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _selectedDay != null
        ? context.watch<NoteProvider>().getNotesForDate(_selectedDay!)
        : [];

    return Scaffold(
      appBar: !_isEditing ? AppBar(
        // title: const Text('Günlük & Notlar'), 
        // centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ) : null,
      body: Column(
        children: [
          if (_showCalendar)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _isEditing = false;
                  _noteController.clear();
                });
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
          Expanded(
            child: _isEditing
                ? Scaffold(
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _editingNoteId = null;
                                    _noteController.clear();
                                    _showCalendar = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              hintText: 'Notunuzu buraya yazın...',
                              contentPadding: EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottomNavigationBar: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _editingNoteId = null;
                                  _noteController.clear();
                                  _showCalendar = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'İptal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_noteController.text.isNotEmpty) {
                                  if (_editingNoteId != null) {
                                    context.read<NoteProvider>().updateNote(
                                      _editingNoteId!,
                                      _noteController.text,
                                    );
                                  } else {
                                    context.read<NoteProvider>().addNote(
                                      _selectedDay!,
                                      _noteController.text,
                                    );
                                  }
                                  setState(() {
                                    _isEditing = false;
                                    _editingNoteId = null;
                                    _noteController.clear();
                                    _showCalendar = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_editingNoteId != null ? 'Not güncellendi' : 'Not kaydedildi'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Kaydet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _selectedDay == null
                    ? const Center(
                        child: Text('Lütfen bir tarih seçin'),
                      )
                    : notes.isEmpty
                        ? Center(
                            child: Text(
                              '${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDay!)}\n\nHenüz not eklenmemiş',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notes.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      setState(() {
                                        _isEditing = true;
                                        _editingNoteId = note.id;
                                        _noteController.text = note.content;
                                        _showCalendar = false;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.access_time, size: 14, color: Theme.of(context).primaryColor),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      DateFormat('HH:mm', 'tr_TR').format(note.createdAt),
                                                      style: TextStyle(
                                                        color: Theme.of(context).primaryColor,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined),
                                                    color: Colors.blue,
                                                    constraints: const BoxConstraints(),
                                                    padding: const EdgeInsets.all(8),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isEditing = true;
                                                        _editingNoteId = note.id;
                                                        _noteController.text = note.content;
                                                        _showCalendar = false;
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline),
                                                    color: Colors.red,
                                                    constraints: const BoxConstraints(),
                                                    padding: const EdgeInsets.all(8),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Notu Sil'),
                                                          content: const Text('Bu notu silmek istediğinizden emin misiniz?'),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: const Text('İptal'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                context.read<NoteProvider>().deleteNote(note.id);
                                                                Navigator.pop(context);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text('Not silindi'),
                                                                    behavior: SnackBarBehavior.floating,
                                                                  ),
                                                                );
                                                              },
                                                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                              child: const Text('Sil'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            note.content,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              height: 1.5,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: !_isEditing ? Column(
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
                    setState(() {
                      _showCalendar = !_showCalendar;
                    });
                  },
                  tooltip: 'Takvimi Gizle/Göster',
                  backgroundColor: Colors.blue,
                  child: Icon(_showCalendar ? Icons.calendar_today : Icons.calendar_month),
                ),
                const SizedBox(height: 4),
                const Text('Takvim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'viewAllNotes',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllNotesPage(),
                      ),
                    );
                  },
                  tooltip: 'Tüm Notları Göster',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.list),
                ),
                const SizedBox(height: 4),
                const Text('Tüm Notlar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'addNote',
                  onPressed: () {
                    if (_selectedDay != null) {
                      setState(() {
                        _isEditing = true;
                        _noteController.clear();
                        _showCalendar = false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen önce bir tarih seçin'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  tooltip: 'Yeni Not Ekle',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 4),
                const Text('Not Ekle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
} 