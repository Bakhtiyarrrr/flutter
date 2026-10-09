import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../models/activity.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  late Box<Activity> activityBox;
  // List<Activity> activities = [
  //   Activity(title: 'Read Chapter 1', priority: 'High'),
  //   Activity(title: 'Complete Assignment', priority: 'Medium'),
  //   Activity(title: 'Review Notes', priority: 'Low'),
  // ];

  List<Activity> get activities {
    final List<Activity> activityList = activityBox.values.toList();
    activityList.sort((a, b) {
      // Сначала невыполненные
      if (a.iscompleted != b.iscompleted) {
        return a.iscompleted ? 1 : -1;
      }

      // Затем новые выше старых — безопасно обрабатываем null
      final aCreated = a.createdAt;
      final bCreated = b.createdAt;
      if (aCreated == null && bCreated == null) return 0;
      if (aCreated == null) return 1; // отсутствие даты считается старым
      if (bCreated == null) return -1;
      return bCreated.compareTo(aCreated);
    });
    return activityList;
  }

  final activityController = TextEditingController();
  final List<String> priorities = ['High', 'Medium', 'Low'];
  String selectedPriority = 'High';
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    activityBox = Hive.box<Activity>('activities');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks for Study'), centerTitle: true),
      body: ListView.separated(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              activities[index].title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: activities[index].iscompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              activities[index].priority,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            leading: Checkbox(
              value: activities[index].iscompleted,
              onChanged: (value) {
                setState(() {
                  activities[index].iscompleted = value!;
                  activities[index].save(); // Save the updated activity to Hive
                });
              },
            ),
            onTap: () {
              final bytes = activities[index].imageBytes;
              if (bytes != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImagePage(imageBytes: bytes),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No image attached for this task')),
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 88, 34, 224),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> pickImage() async {
                    try {
                      final ImagePicker picker = ImagePicker();
                      final XFile? file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (!context.mounted) return; // guard BuildContext after async

                      if (file == null) {
                        // user cancelled or no file selected
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No image selected')),
                          );
                        }
                        return;
                      }

                      final bytes = await file.readAsBytes();

                      if (!context.mounted) return; // guard again after another await

                      setModalState(() {
                        _pickedImageBytes = bytes;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image selected')),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to pick image: $e')),
                      );
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Add New Activity",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: activityController,
                          decoration: const InputDecoration(
                            labelText: "Activity Title",
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Image picker button and preview
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () async {
                                await pickImage();
                              },
                              icon: const Icon(Icons.photo),
                              label: const Text('Add Image'),
                            ),
                            const SizedBox(width: 12),
                            if (_pickedImageBytes != null)
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: Image.memory(
                                  _pickedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),

                        DropdownButtonFormField<String>(
                          initialValue: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: "Priority",
                          ),
                          items: priorities.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) selectedPriority = value;
                          },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                activityBox.add(
                                  Activity(
                                    title: activityController.text,
                                    priority: selectedPriority,
                                    createdAt: DateTime.now(),
                                    imageBytes: _pickedImageBytes,
                                  ),
                                );
                              });

                              // clear picked image after adding
                              _pickedImageBytes = null;
                              Navigator.pop(context);
                              activityController.clear();
                            },
                            child: const Text("Add Task"),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final Uint8List imageBytes;

  const FullImagePage({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(imageBytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
