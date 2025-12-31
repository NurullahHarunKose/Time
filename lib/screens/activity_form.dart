import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'package:uuid/uuid.dart';

class ActivityForm extends StatefulWidget {
  final Activity? activity;
  final DateTime selectedDate;
  final Function(Activity) onSave;

  const ActivityForm({
    super.key,
    this.activity,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descriptionController = TextEditingController(text: widget.activity?.description ?? '');
    _startTime = widget.activity?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.activity?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _selectedColor = widget.activity?.color ?? Activity.predefinedColors[0];
    _isAllDay = widget.activity?.isAllDay ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Zamanı dakikaya çevir (24 saat formatında)
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Zaman seçimi kontrolü
  bool _isValidTimeRange() {
    if (_isAllDay) return true;
    
    final startMinutes = _timeToMinutes(_startTime);
    final endMinutes = _timeToMinutes(_endTime);
    
    // Eğer bitiş zamanı başlangıç zamanından önceyse (gece yarısı geçişi olabilir)
    if (endMinutes < startMinutes) {
      return false;
    }
    
    return true;
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Eğer bitiş zamanı başlangıç zamanından önceyse, bitiş zamanını güncelle
          if (!_isValidTimeRange()) {
            _endTime = TimeOfDay(
              hour: (picked.hour + 1) % 24,
              minute: picked.minute,
            );
          }
        } else {
          _endTime = picked;
          // Eğer bitiş zamanı başlangıç zamanından önceyse, kullanıcıyı uyar
          if (!_isValidTimeRange()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitiş zamanı başlangıç zamanından önce olamaz!'),
                duration: Duration(seconds: 2),
              ),
            );
            // Bitiş zamanını başlangıç zamanından 1 saat sonraya ayarla
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        }
      });
    }
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate() && _isValidTimeRange()) {
      final activity = Activity(
        id: widget.activity?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        startTime: _isAllDay ? const TimeOfDay(hour: 0, minute: 0) : _startTime,
        endTime: _isAllDay ? const TimeOfDay(hour: 23, minute: 59) : _endTime,
        color: _selectedColor,
        date: widget.selectedDate,
        isAllDay: _isAllDay,
      );
      
      widget.onSave(activity);
      Navigator.of(context).pop();
    } else if (!_isValidTimeRange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir zaman aralığı seçin!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Yeni Aktivite' : 'Aktivite Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveActivity,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Aktivite Adı',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir aktivite adı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                border: OutlineInputBorder(),
                hintText: 'Aktivite için açıklama ekleyebilirsiniz',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tüm Gün'),
              value: _isAllDay,
              onChanged: (bool value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
            if (!_isAllDay) ...[
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Başlangıç'),
                trailing: Text(_startTime.format(context)),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Bitiş'),
                trailing: Text(_endTime.format(context)),
                onTap: () => _selectTime(context, false),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Renk Seçin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Activity.predefinedColors.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 