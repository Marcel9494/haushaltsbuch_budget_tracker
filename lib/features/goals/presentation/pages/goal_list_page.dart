import 'package:flutter/material.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({super.key});

  @override
  State<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('Goal List Page'),
    );
  }
}
