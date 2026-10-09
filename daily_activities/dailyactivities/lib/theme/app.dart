import 'package:flutter/material.dart';
import 'package:dailyactivities/features/study_page/view/view.dart';
import 'package:dailyactivities/theme/theme.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: const StudyPage(),
    );
  }
}
