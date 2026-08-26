import 'package:flutter/material.dart';

import '../services/session.dart';
import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'marks_screen.dart';
import 'login_screen.dart';
import 'announcement_management/announcement_management_screen.dart';
import 'parent_profile_screen.dart';
import 'ai_reports_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  @override
  Widget build(BuildContext context) {
    final String parentName =
        Session.fullName?.isNotEmpty == true
            ? Session.fullName!
            : "Parent";

    final String parentEmail =
        Session.email?.isNotEmpty == true
            ? Session.email!
            : "";

    return Scaffold(

      // =========================================================
      // PARENT DRAWER
      // =========================================================

      drawer: ParentDrawer(
        parentName: parentName,
        parentEmail: parentEmail,
      ),

      // =========================================================
      // APP BAR
      // =========================================================

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

                  // =================================================
                  // MENU BUTTON
                  // =================================================

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

                  // =================================================
                  // TITLE
                  // =================================================

                  const Expanded(
                    child: Text(
                      "Parent Dashboard",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // =================================================
                  // PARENT PROFILE
                  // =================================================

                  PopupMenuButton<String>(
                    offset: const Offset(0, 45),

                    onSelected: (value) {

                      if (value == "profile") {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const ParentProfileScreen(),
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

                        // PROFILE ICON
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

                        // PARENT NAME
                        Text(
                          parentName,

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

      // =========================================================
      // BODY
      // =========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =====================================================
            // WELCOME TEXT
            // =====================================================

            Text(
              "👋 Welcome, $parentName",

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff1F4FB8),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // DASHBOARD CARDS
            // =====================================================

            GridView.count(
              crossAxisCount: 2,

              crossAxisSpacing: 15,
              mainAxisSpacing: 15,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              children: [

                // =================================================
                // CHILD MARKS
                // =================================================

                DashboardCard(
                  title: "Child Marks",

                  icon: Icons.grading,

                  backgroundColor:
                      const Color(0xfffff1e6),

                  iconBackgroundColor:
                      const Color(0xffffd8b3),

                  iconColor:
                      Colors.orange,

                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                            const MarksScreen(
                          initialPage: "View Marks",
                        ),
                      ),
                    );
                  },
                ),

                // =================================================
                // ATTENDANCE
                // =================================================

                DashboardCard(
                  title: "Attendance",

                  icon: Icons.fact_check,

                  backgroundColor:
                      const Color(0xffEAF3FF),

                  iconBackgroundColor:
                      const Color(0xffCFE4FF),

                  iconColor:
                      const Color(0xff1F4FB8),

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

                // =================================================
                // HOMEWORK
                // =================================================

                DashboardCard(
                  title: "Homework",

                  icon: Icons.menu_book,

                  backgroundColor:
                      const Color(0xffEAF8EF),

                  iconBackgroundColor:
                      const Color(0xffC9F0D6),

                  iconColor:
                      Colors.green,

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

                // =================================================
                // ANNOUNCEMENTS
                // =================================================

                DashboardCard(
                  title: "Announcements",

                  icon: Icons.assignment,

                  backgroundColor:
                      const Color(0xffFDECEC),

                  iconBackgroundColor:
                      const Color(0xffF8CACA),

                  iconColor:
                      Colors.red,

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

                // =================================================
                // AI FIELDS
                // =================================================

                DashboardCard(
                  title: "AI Fields",

                  icon: Icons.auto_awesome,

                  backgroundColor:
                      const Color(0xffF3E8FF),

                  iconBackgroundColor:
                      const Color(0xffDEC7FF),

                  iconColor:
                      Colors.deepPurple,

                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AIReportsScreen(
        mode: AIReportsMode.parent,
      ),
    ),
  );
},
                ),

                // =================================================
                // EMPTY SIXTH CARD
                // =================================================

                const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // LOGOUT FUNCTION
  // =============================================================

  void _logout(BuildContext context) {

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),

      (route) => false,
    );
  }
}


// =================================================================
// PARENT DRAWER
// =================================================================

class ParentDrawer extends StatelessWidget {

  final String parentName;
  final String parentEmail;

  const ParentDrawer({
    super.key,
    required this.parentName,
    required this.parentEmail,
  });

  @override
  Widget build(BuildContext context) {

    return Drawer(
      width: 280,

      child: Column(
        children: [

          // ========================================================
          // PARENT PROFILE HEADER
          // ========================================================

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
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // PROFILE ICON

                CircleAvatar(
                  radius: 32,

                  backgroundColor:
                      Colors.white,

                  child: const Icon(
                    Icons.person,
                    size: 38,
                    color: Color(0xff1F4FB8),
                  ),
                ),

                const SizedBox(height: 12),

                // PARENT NAME

                Text(
                  parentName,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // PARENT EMAIL

                Text(
                  parentEmail,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // PARENT MENU
          // ========================================================

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,

              children: [

                const SizedBox(height: 8),

                // ==================================================
                // CHILD MARKS
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.grading,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Child Marks",

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
                            const MarksScreen(
                          initialPage: "View Marks",
                        ),
                      ),
                    );
                  },
                ),

                // ==================================================
                // ATTENDANCE
                // ==================================================

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

                // ==================================================
                // HOMEWORK
                // ==================================================

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

                // ==================================================
                // ANNOUNCEMENTS
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.announcement,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "Announcements",

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

                // ==================================================
                // AI
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xff444444),
                  ),

                  title: const Text(
                    "AI Fields",

                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  onTap: () {
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AIReportsScreen(
        mode: AIReportsMode.parent,
      ),
    ),
  );
},
                ),
              ],
            ),
          ),

          // ========================================================
          // LOGOUT
          // ========================================================

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
                  builder: (context) =>
                      const LoginScreen(),
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


// =================================================================
// DASHBOARD CARD
// =================================================================

class DashboardCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,

      color: backgroundColor,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  icon,
                  size: 30,
                  color: iconColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}