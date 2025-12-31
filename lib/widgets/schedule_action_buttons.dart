import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/activity_form.dart';
import '../screens/daily_schedule_page.dart';
import '../screens/right_page.dart';
import '../providers/schedule_provider.dart';

class ScheduleActionButtons extends StatefulWidget {
  final DateTime selectedDate;
  final Function onRefresh;

  const ScheduleActionButtons({
    super.key,
    required this.selectedDate,
    required this.onRefresh,
  });

  @override
  State<ScheduleActionButtons> createState() => _ScheduleActionButtonsState();
}

class _ScheduleActionButtonsState extends State<ScheduleActionButtons> {
  bool _showButtons = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
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
        if (_showButtons) ...[
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'toggleCalendar',
            onPressed: () {
              _showCalendarDialog(context);
            },
            tooltip: 'Takvimi Göster',
            backgroundColor: Colors.blue,
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'dailySchedule',
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Saat Görünümü',
            backgroundColor: Colors.cyan,
            child: const Icon(Icons.watch_later),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'addActivity',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityForm(
                    selectedDate: widget.selectedDate,
                    onSave: (activity) {
                      context.read<ScheduleProvider>().addActivity(activity);
                      widget.onRefresh();
                    },
                  ),
                ),
              );
            },
            tooltip: 'Yeni Aktivite Ekle',
            backgroundColor: Colors.red,
            child: const Icon(Icons.add),
          ),
        ],
      ],
    );
  }

  Future<void> _showCalendarDialog(BuildContext context) async {
    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tarih Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: widget.selectedDate,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => 
                  isSameDay(day, widget.selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.pop(context, selectedDay);
                },
                calendarStyle: CalendarStyle(
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('İptal'),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedDate != null && !isSameDay(selectedDate, widget.selectedDate)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.runtimeType == DailySchedulePage
              ? DailySchedulePage(selectedDate: selectedDate)
              : RightPage(),
        ),
      );
    }
  }
} 