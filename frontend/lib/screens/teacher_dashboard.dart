import 'package:flutter/material.dart';

import 'attendance_screen.dart';
import 'marks_screen.dart';
import 'homework_screen.dart';
import 'announcements_screen.dart';
import 'ai_reports_screen.dart';
import 'profile_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            _buildCard(
              context,
              Icons.fact_check,
              "Attendance",
              Colors.blue,
              const AttendanceScreen(),
            ),

            _buildCard(
              context,
              Icons.assignment,
              "Marks",
              Colors.orange,
              const MarksScreen(),
            ),

            _buildCard(
              context,
              Icons.menu_book,
              "Homework",
              Colors.purple,
              const HomeworkScreen(),
            ),

            _buildCard(
              context,
              Icons.campaign,
              "Announcements",
              Colors.red,
              const AnnouncementsScreen(),
            ),

            _buildCard(
              context,
              Icons.analytics,
              "AI Reports",
              Colors.teal,
              const AIReportsScreen(),
            ),

            _buildCard(
              context,
              Icons.person,
              "Profile",
              Colors.green,
              const ProfileScreen(),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget screen,
  ) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 50,
              color: color,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}