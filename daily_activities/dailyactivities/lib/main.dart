import 'package:flutter/material.dart';
import 'models/activity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ActivityAdapter());

  await Hive.openBox<Activity>('activities');
  // await Hive.box<Activity>('activities').clear();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 88, 34, 224),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          labelSmall: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StudyPage(),
    );
  }
}

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

  // Затем новые выше старых
  return b.createdAt?.compareTo(a.createdAt!) ?? 0;
});
    return activityList;
  }
    

  final activityController = TextEditingController();
  final List<String> priorities = ['High', 'Medium', 'Low'];
  String selectedPriority = 'High';

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
            // trailing: Icon(Icons.arrow_forward_ios),
            // onTap: () {
            //   // Handle tap event
            // },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 88, 34, 224),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add New Activity'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: activityController,
                      decoration: InputDecoration(labelText: 'Activity Title'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['High', 'Medium', 'Low'].map((priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedPriority = value!;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // activities.insert(
                        //   0,
                        //   Activity(
                        //     title: activityController.text,
                        //     priority: selectedPriority,
                        //   ),
                        // );
                        activityBox.add(
                          Activity(
                            title: activityController.text,
                            priority: selectedPriority,
                            createdAt: DateTime.now(),
                          ),
                        );
                      
                      });

                      // activityBox.values.toList().sort((a, b) => b.createdAt?.compareTo(a.createdAt!) ?? 0);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
