import 'package:flutter/material.dart';
import 'package:os_project_unii/presentation/scheduler_screen/os_scheduler.dart';
import 'package:os_project_unii/presentation/process_generator_screen/process_generator_screen.dart';
import 'package:os_project_unii/presentation/splash_screen/splash_screen.dart';
import 'package:os_project_unii/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Process Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: ProcessGeneratorScreen(),
      routes: {OsScheduler.routeName: (_) => OsScheduler(),
        ProcessGeneratorScreen.routeName: (_) => ProcessGeneratorScreen(),
        SplashScreen.routeName: (_) => SplashScreen(),
        MyDropdownWidget.routeName: (_) => MyDropdownWidget(),
      },
      initialRoute: SplashScreen.routeName,
    );
  }
}