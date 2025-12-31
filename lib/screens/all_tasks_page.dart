import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../widgets/task_list.dart';
import '../providers/task_provider.dart' show Task; // Explicit import for Task type if needed, though usually exported

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild when data changes
    final taskProvider = context.watch<TaskProvider>();
    final selectedDate = taskProvider.selectedDate;
    
    // Get tasks only for the selected date
    final dailyTasks = selectedDate != null 
        ? taskProvider.getTasksForDate(selectedDate) 
        : <Task>[];

    final dateTitle = selectedDate != null 
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate)
        : 'Tüm Görevler';

    return Scaffold(
      appBar: AppBar(
        title: Text(dateTitle),
      ),
      body: Builder(
        builder: (context) {
          if (dailyTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text(
                    'Bu tarih için görev bulunamadı',
                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
                   ),
                ],
              ),
            );
          }

          // Görevleri tamamlanma durumu ve öncelik sırasına göre sırala
          final sortedTasks = List<Task>.from(dailyTasks);
          
          sortedTasks.sort((a, b) {
            // 1. Tamamlanma durumu (Tamamlanmamışlar önce)
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            
            // 2. Kategori sırası (Provider'dan kategori sırasını almamız gerekebilir, 
            // ama şimdilik oluşturulma sırası veya ID yeterli olabilir, 
            // ya da burada kategoriye göre gruplama yapılmıyor, düz liste isteniyor)
            
            return 0; 
          });

          return ListView.builder(
            itemCount: sortedTasks.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TaskListItem(task: task);
            },
          );
        },
      ),
    );
  }
}
 