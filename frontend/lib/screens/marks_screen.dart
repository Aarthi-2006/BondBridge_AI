import 'package:flutter/material.dart';

class MarksScreen extends StatelessWidget {
  const MarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marks"),
      ),
      body: const Center(
        child: Text(
          "Marks Screen",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}