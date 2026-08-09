import 'package:flutter/material.dart';

import '../widgets/dashboard_card.dart';
import '../widgets/app_drawer.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import 'student_management/student_management_screen.dart';
import '../services/class_permission_service.dart';
import 'marks_screen.dart';
import 'homework_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String teacherName;

  const TeacherDashboard({
    super.key,
    required this.teacherName,
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

      drawer: const AppDrawer(),


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


                  // Menu Button

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



                  // Admin Dashboard Title

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



                  // Admin Profile Dropdown

                 PopupMenuButton<String>(

  offset: const Offset(0, 45),

  onSelected: (value) {

    if (value == "logout") {

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );

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


                          child: Icon(

                            Icons.person,

                            color: Color(0xff1F4FB8),

                            size: 22,

                          ),

                        ),



                        SizedBox(width: 5),



                        Text(
widget.teacherName,  style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
  ),
),



                        Icon(

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





      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        "👋 Welcome, ${widget.teacherName}",
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xff1F4FB8),
        ),
      ),

      const SizedBox(height: 6),

      const Text(
        "Have a great day! Here's your teaching overview.",
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 20),
      const Text(
  "Today's Summary",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xff1F4FB8),
  ),
),

const SizedBox(height: 15),

Row(
  children: [

    Expanded(
      child: _summaryCard(
        title: "Classes",
        value: "4",
        icon: Icons.class_,
        color: Colors.blue,
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _summaryCard(
        title: "Attendance",
        value: "2",
        icon: Icons.fact_check,
        color: Colors.green,
      ),
    ),
  ],
),

const SizedBox(height: 12),

Row(
  children: [

    Expanded(
      child: _summaryCard(
        title: "Homework",
        value: "1",
        icon: Icons.menu_book,
        color: Colors.orange,
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _summaryCard(
        title: "Marks",
        value: "3",
        icon: Icons.grading,
        color: Colors.red,
      ),
    ),
  ],
),

const SizedBox(height: 20),

      GridView.count(

          crossAxisCount: 2,


          crossAxisSpacing: 15,


          mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),



          children: [


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
      builder: (context) => const StudentManagementScreen(),
    ),
  );
},
),


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
      builder: (context) => const AttendanceScreen(),
    ),
  );

},
),




          DashboardCard(
  title: "Marks",
  icon: Icons.grading,
  backgroundColor: const Color(0xffEAF8EF),
  iconBackgroundColor: const Color(0xffC9F0D6),
  iconColor: Colors.green,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>const MarksScreen(),
      ),
    );
  },
),




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
    builder: (_) =>const HomeworkScreen(),
  ),
);
  },
),
  
          DashboardCard(
  title: "Announcements",
  icon: Icons.campaign,
  backgroundColor: const Color(0xffFFF8E6),
  iconBackgroundColor: const Color(0xffFFE7A3),
  iconColor: Colors.amber,
  onTap: () {
    // We will connect this later
  },
),

      DashboardCard(
  title: "AI Reports",
  icon: Icons.auto_awesome,
  backgroundColor: const Color(0xffF3E8FF),
  iconBackgroundColor: const Color(0xffDEC7FF),
  iconColor: Colors.deepPurple,
  onTap: () {
    // We will connect this later
  },
),


              ],
        ),
      
    ],
  ),
),
    );
}
}
Widget _summaryCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha:0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha:0.15),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
