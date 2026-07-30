import 'package:flutter/material.dart';

class AIReportsScreen extends StatelessWidget {
  const AIReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Reports"),
      ),
      body: const Center(
        child: Text(
          "AI Reports Screen",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}