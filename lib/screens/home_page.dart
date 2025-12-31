import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_matrix.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/task_list.dart';
import 'all_tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = true;
  bool _showButtons = true;

  @override
  void initState() {
    super.initState();
    // Başlangıçta bugünün tarihini seç
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().setSelectedDate(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Görev Yöneticisi'), // Title removed as requested
        // centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // Hide app bar completely if title is gone, or keep it minimal
      ),
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
                });
                context.read<TaskProvider>().setSelectedDate(selectedDay);
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
          const Expanded(
            child: TaskMatrix(),
          ),
        ],
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
                  heroTag: 'addCategory',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddCategoryDialog(),
                    );
                  },
                  tooltip: 'Yeni Kategori Ekle',
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.grid_view),
                ),
                const SizedBox(height: 4),
                const Text('Kategori', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'viewAllTasks',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllTasksPage(),
                      ),
                    );
                  },
                  tooltip: 'Tüm Görevleri Göster',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.list),
                ),
                const SizedBox(height: 4),
                const Text('Tüm Görevler', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                FloatingActionButton(
                  heroTag: 'addTask',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddTaskDialog(initialDate: _focusedDay),
                    );
                  },
                  tooltip: 'Yeni Görev Ekle',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 4),
                const Text('Görev', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
 