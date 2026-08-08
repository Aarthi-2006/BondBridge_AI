import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/student_management/student_management_screen.dart';
import '../screens/teacher_management/teacher_management_screen.dart';
import '../screens/parent_management/parent_management_screen.dart';
import '../screens/announcement_management/announcement_management_screen.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Admin User"),
            accountEmail: Text("admin@bondbridge.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Students"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentManagementScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.school),
            title: const Text("Teachers"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TeacherManagementScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text("Parents"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ParentManagementScreen(),
                ),
              );
            },
          ),

         ListTile(
  leading: const Icon(
    Icons.campaign,
  ),
  title: const Text("Announcements"),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnouncementManagementScreen(),
      ),
    );
  },
),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}