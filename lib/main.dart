import 'package:flutter/material.dart';
import 'package:map_sample/run_detail_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Map Sample', home: const RunDetailMap());
  }
}
