import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import 'activity_form.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../widgets/schedule_action_buttons.dart';

class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;

  const DailySchedulePage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailySchedulePage> createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showHeader = true;
  bool _showButtons = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Aktivite ekledikten sonra sayfayı yenile
  void _refreshPage() {
    setState(() {
      // Durum değişkenleri güncellenir
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ScheduleProvider>().getActivitiesForDate(widget.selectedDate);
    activities.sort((a, b) => a.startTime.hour * 60 + a.startTime.minute 
                          - (b.startTime.hour * 60 + b.startTime.minute));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Program'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTimelineList(),
          ),
        ],
      ),
      floatingActionButton: ScheduleActionButtons(
        selectedDate: widget.selectedDate,
        onRefresh: () => setState(() {}),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Günlük Program sayfası seçili
        onTap: (index) {
          switch (index) {
            case 0: // Günlük sayfası
              Navigator.pushReplacementNamed(context, '/left');
              break;
            case 1: // Matris sayfası
              Navigator.pushReplacementNamed(context, '/matrix');
              break;
            case 2: // Plan sayfası
              Navigator.pushReplacementNamed(context, '/right');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Günlük',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_4x4),
            label: 'Matris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${DateFormat('d', 'tr_TR').format(widget.selectedDate)}",
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'tr_TR').format(widget.selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  DateFormat('EEEE', 'tr_TR').format(widget.selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Takvim seçme dialogu
  Future<void> _showCalendarDialog() async {
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

    if (selectedDate != null) {
      // Eğer tarih seçildiyse ve şimdiki tarihten farklıysa, yeni tarihli sayfaya git
      if (!isSameDay(selectedDate, widget.selectedDate)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DailySchedulePage(
              selectedDate: selectedDate,
            ),
          ),
        );
      }
    }
  }

  Widget _buildTimelineList() {
    final activities = context.watch<ScheduleProvider>().getActivitiesForDate(widget.selectedDate);
    const double hourHeight = 80.0; // Her saat dilimi için yükseklik
    // 00:00 ile 24:00 arası toplam yükseklik
    const double totalHeight = 24 * hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            height: totalHeight,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Stack(
              children: [
                // 1. Izgara ve Saat Etiketleri
                ...List.generate(24, (index) {
                  return Positioned(
                    top: index * hourHeight,
                    left: 0,
                    right: 0,
                    height: hourHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                '${index.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          // Dikey ayırıcı çizgi
                          Container(
                            width: 1,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                
                // 2. Aktiviteler
                ...activities.map((activity) {
                  // Başlangıç ve bitiş dakikalarını hesapla
                  final startMinutes = activity.startTime.hour * 60 + activity.startTime.minute;
                  final endMinutes = activity.endTime.hour * 60 + activity.endTime.minute;
                  
                  // Gece yarısını geçen aktiviteler için bitiş süresi düzeltmesi (örn. 23:00 - 01:00)
                  // Bu basit versiyonda sadece aynı gün içindekileri gösteriyoruz veya 24:00'e kadar kesiyoruz.
                  final effectiveEndMinutes = endMinutes < startMinutes ? 24 * 60 : endMinutes;
                  
                  final durationMinutes = effectiveEndMinutes - startMinutes;
                  
                  // Konum hesaplama (1 saat = hourHeight px, 1 dk = hourHeight/60 px)
                  final topPosition = (startMinutes / 60) * hourHeight;
                  final height = (durationMinutes / 60) * hourHeight;
                  
                  return Positioned(
                    top: topPosition,
                    left: 65, // Saat etiketinden sonra
                    right: 10,
                    height: height > 0 ? height : hourHeight, // Min yükseklik koruması
                    child: GestureDetector(
                      onTap: () => _showActivityDetails(activity),
                      onLongPress: () => _showActivityOptions(activity),
                      child: Container(
                        margin: const EdgeInsets.all(2), // Kartlar arası hafif boşluk
                        decoration: BoxDecoration(
                          color: activity.color.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            // Yükseklik küçükse padding'i azalt
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.0, 
                              vertical: height > 40 ? 8.0 : 2.0
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activity.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    // Yükseklik çok azsa tek satır yap
                                    maxLines: height > 60 ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Sadece yeterli alan varsa saati göster (Eşik değeri artırıldı)
                                  if (height > 50) ...[ 
                                    const SizedBox(height: 4),
                                    Text(
                                      '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(Activity activity, double height) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      height: height,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: activity.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showActivityDetails(activity),
          onLongPress: () => _showActivityOptions(activity),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  activity.color.withOpacity(0.9),
                  activity.color.withOpacity(0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zamanlar ve Tüm Gün etiketi
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (activity.isAllDay)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tüm Gün',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 6),
                // Başlık
                Expanded(
                  child: Text(
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: activity.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (activity.description != null) ...[
                const Text(
                  'Açıklama',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.description!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    onPressed: () {
                      Navigator.pop(context);
                      _editActivity(activity);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteActivity(activity);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivityOptions(Activity activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                  _editActivity(activity);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Sil', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteActivity(activity);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editActivity(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityForm(
          activity: activity,
          selectedDate: widget.selectedDate,
          onSave: (updatedActivity) {
            context.read<ScheduleProvider>().updateActivity(updatedActivity);
            _refreshPage(); // Sayfayı yenile
          },
        ),
      ),
    ).then((_) => _refreshPage()); // Dönüşte de sayfa yenileme
  }

  void _deleteActivity(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktiviteyi Sil'),
        content: const Text('Bu aktiviteyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ScheduleProvider>().deleteActivity(activity.id);
              _refreshPage(); // Sayfayı yenile
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 