import 'package:flutter/material.dart';

import '../widgets/dashboard_card.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import 'student_management/student_management_screen.dart';
import '../services/class_permission_service.dart';
import 'marks_screen.dart';
import 'homework_screen.dart';
import 'announcement_management/announcement_management_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String teacherName;
  final String teacherEmail;

  const TeacherDashboard({
    super.key,
    required this.teacherName,
    required this.teacherEmail,
  });

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  Future<void> loadPermissions() async {
    await ClassPermissionService.loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Teacher-specific drawer
      drawer: TeacherDrawer(
        teacherName: widget.teacherName,
        teacherEmail: widget.teacherEmail,
      ),

      // =========================
      // APP BAR
      // =========================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),

        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff1F4FB8),
          elevation: 0,

          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              child: Row(
                children: [
                  // =========================
                  // MENU BUTTON
                  // =========================

                  Builder(
                    builder: (context) => IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),

                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },

                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =========================
                  // TITLE
                  // =========================

                  const Expanded(
                    child: Text(
                      "Teacher Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // =========================
                  // TEACHER PROFILE
                  // =========================

                  PopupMenuButton<String>(
                    offset: const Offset(0, 45),

                   onSelected: (value) {
  if (value == "profile") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TeacherProfileScreen(),
      ),
    );
  }

  if (value == "logout") {
    _logout(context);
  }
},

                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "profile",
                        child: Text("Profile"),
                      ),

                      PopupMenuItem(
                        value: "logout",
                        child: Text("Logout"),
                      ),
                    ],

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,

                          child: const Icon(
                            Icons.person,
                            color: Color(0xff1F4FB8),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          widget.teacherName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),

                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // =========================
      // BODY
      // =========================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================
            // WELCOME TEXT
            // =========================

            Text(
              "👋 Welcome, ${widget.teacherName}",

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff1F4FB8),
              ),
            ),


            const SizedBox(height: 20),

            // =========================
            // DASHBOARD CARDS
            // =========================

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              children: [
                // =========================
                // MY STUDENTS
                // =========================

                DashboardCard(
                  title: "My Students",
                  icon: Icons.groups,

                  backgroundColor: const Color(0xfffff1e6),
                  iconBackgroundColor: const Color(0xffffd8b3),
                  iconColor: Colors.orange,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const StudentManagementScreen(),
                      ),
                    );
                  },
                ),

                // =========================
                // ATTENDANCE
                // =========================

                DashboardCard(
                  title: "Attendance",
                  icon: Icons.fact_check,

                  backgroundColor: const Color(0xffEAF3FF),
                  iconBackgroundColor: const Color(0xffCFE4FF),
                  iconColor: const Color(0xff1F4FB8),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AttendanceScreen(),
                      ),
                    );
                  },
                ),

                // =========================
                // MARKS
                // =========================

                DashboardCard(
                  title: "Marks",
                  icon: Icons.grading,

                  backgroundColor: const Color(0xffEAF8EF),
                  iconBackgroundColor: const Color(0xffC9F0D6),
                  iconColor: Colors.green,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MarksScreen(),
                      ),
                    );
                  },
                ),

                // =========================
                // HOMEWORK
                // =========================

                DashboardCard(
                  title: "Homework",
                  icon: Icons.menu_book,

                  backgroundColor: const Color(0xffFDECEC),
                  iconBackgroundColor: const Color(0xffF8CACA),
                  iconColor: Colors.red,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeworkScreen(),
                      ),
                    );
                  },
                ),

                // =========================
                // ASSIGNMENT
                // =========================

                DashboardCard(
                  title: "Announcements",
                  icon: Icons.assignment,

                  backgroundColor: const Color(0xffFFF8E6),
                  iconBackgroundColor: const Color(0xffFFE7A3),
                  iconColor: Colors.amber,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AnnouncementManagementScreen(),
                      ),
                    );
                  },
                ),

                // =========================
                // AI REPORT
                // =========================

                DashboardCard(
                  title: "AI Report",
                  icon: Icons.auto_awesome,

                  backgroundColor: const Color(0xffF3E8FF),
                  iconBackgroundColor: const Color(0xffDEC7FF),
                  iconColor: Colors.deepPurple,

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "AI Report screen will be connected here.",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // LOGOUT FUNCTION
  // =========================

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),

      (route) => false,
    );
  }
}

// ==========================================================
// TEACHER DRAWER
// ==========================================================

class TeacherDrawer extends StatelessWidget {
  final String teacherName;
  final String teacherEmail;

  const TeacherDrawer({
    super.key,
    required this.teacherName,
    required this.teacherEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,

      child: Column(
        children: [
          // ==================================================
          // TEACHER PROFILE HEADER
          // ==================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.only(
              top: 45,
              left: 20,
              right: 20,
              bottom: 20,
            ),

            color: const Color(0xff5269A3),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Profile Icon
                CircleAvatar(
                  radius: 32,

                  backgroundColor: Colors.white,

                  child: const Icon(
                    Icons.person,
                    size: 38,
                    color: Color(0xff1F4FB8),
                  ),
                ),

                const SizedBox(height: 12),

                // Teacher Name
                Text(
                  teacherName,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // Teacher Email
                Text(
                  teacherEmail,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // TEACHER MENU ITEMS
          // ==================================================

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,

              children: [
                const SizedBox(height: 8),

                // ------------------------------------------------
                // MY STUDENTS
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.groups,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "My Students",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const StudentManagementScreen(),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // ATTENDANCE
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.fact_check,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Attendance",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AttendanceScreen(),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // MARKS
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.grading,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Marks",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MarksScreen(),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // HOMEWORK
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.menu_book,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Homework",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeworkScreen(),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // ANNOUNCEMENT
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.announcement,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Announcemnts",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AnnouncementManagementScreen(),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // AI REPORT
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "AI Report",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "AI Report screen will be connected here.",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ==================================================
          // LOGOUT
          // ==================================================

          const Divider(
            height: 1,
          ),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color(0xff444444),
            ),

            title: const Text(
              "Logout",
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),

                (route) => false,
              );
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}