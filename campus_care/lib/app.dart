import 'package:flutter/material.dart';

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCare',
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('CampusCare — structure ready')),
      ),
    );
  }
}
