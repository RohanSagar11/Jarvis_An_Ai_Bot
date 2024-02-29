import 'package:flutter/material.dart';
import 'package:jarvis/home_page.dart';
import 'package:jarvis/pallete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light(
          useMaterial3: true,
        ).copyWith(
            scaffoldBackgroundColor: Pallete.whiteColor,
            appBarTheme: AppBarTheme(color: Pallete.whiteColor)),
        debugShowCheckedModeBanner: false,
        title: 'Jarvis',
        home: HomePage());
  }
}
