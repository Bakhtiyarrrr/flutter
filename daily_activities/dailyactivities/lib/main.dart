import 'package:flutter/material.dart';
import 'models/activity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:dailyactivities/theme/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ActivityAdapter());

  await Hive.openBox<Activity>('activities');
  // await Hive.box<Activity>('activities').clear();

  runApp(const MyApp());
}
