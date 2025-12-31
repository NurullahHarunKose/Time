import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_list.dart';

class TaskMatrix extends StatelessWidget {
  const TaskMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Artık sadece seçili günün kategorileri geliyor (getter güncellendi)
        final categories = taskProvider.categories;

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Bu güne ait kategori bulunamadı',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '"+" butonuna basarak yeni kategori ekleyebilirsiniz',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          buildDefaultDragHandles: false, // Custom handle kullanacağız
          itemCount: categories.length,
          onReorder: (oldIndex, newIndex) {
            taskProvider.reorderCategories(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final category = categories[index];
            final Color baseColor = category.color;

            // Arka plan rengini çok açık yap
            final Color backgroundColor = baseColor.withOpacity(0.05);
            // Başlık arka planını biraz daha koyu yap
            final Color headerColor = baseColor.withOpacity(0.1);
            // Kenarlık rengi
            final Color borderColor = baseColor.withOpacity(0.3);

            return DragTarget<Task>(
              key: ValueKey(category.id), // Reorderable list için unique key şart
              onWillAccept: (task) => task != null && task.categoryId != category.id,
              onAccept: (task) {
                taskProvider.updateTaskCategory(task.id, category.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Görev "${category.name}" kategorisine taşındı'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 200, 
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty ? baseColor.withOpacity(0.2) : backgroundColor,
                    border: Border.all(
                      color: candidateData.isNotEmpty ? baseColor : borderColor, 
                      width: candidateData.isNotEmpty ? 2.5 : 1.5
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Kategori Başlığı Handle ve Silme Butonu
                      ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: headerColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Drag Handle Icon
                              Icon(Icons.drag_indicator, size: 20, color: baseColor.withOpacity(0.5)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: baseColor.withOpacity(1.0), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Silme Butonu
                              GestureDetector(
                                onTap: () {
                                  final taskCount = taskProvider.getTasksByCategory(category.id).length;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Kategoriyi Sil'),
                                      content: Text(
                                        '${category.name} kategorisini silmek istiyor musunuz?\n\n'
                                        'Bu işlem içerisindeki $taskCount görevi de kalıcı olarak silecektir.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('İptal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            taskProvider.removeCategory(category.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: baseColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Görev Listesi
                      Expanded(
                        child: TaskList(
                          tasks: taskProvider.getTasksByCategory(category.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
 