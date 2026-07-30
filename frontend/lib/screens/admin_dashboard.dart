
import 'package:flutter/material.dart';

import '../widgets/dashboard_card.dart';
import '../widgets/app_drawer.dart';

import 'student_management/student_management_screen.dart';
import 'teacher_management/teacher_management_screen.dart';
import 'parent_dashboard.dart';
import 'ai_reports_screen.dart';


class AdminDashboard extends StatelessWidget {

  const AdminDashboard({super.key});


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

                      "Admin Dashboard",


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



                    child: const Row(

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

                          "Admin",

                          style: TextStyle(

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





      body: Padding(

        padding: const EdgeInsets.all(16),


        child: GridView.count(


          crossAxisCount: 2,


          crossAxisSpacing: 15,


          mainAxisSpacing: 15,



          children: [



            DashboardCard(
  title: "Students",
  icon: Icons.school,
  backgroundColor: const Color(0xffEAF3FF),
  iconBackgroundColor: const Color(0xffCFE4FF),
  iconColor: const Color(0xff1F4FB8),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentManagementScreen(),
      ),
    );
  },
),



            DashboardCard(
  title: "Teachers",
  icon: Icons.person,
  backgroundColor: const Color(0xffEAF8EF),
  iconBackgroundColor: const Color(0xffC9F0D6),
  iconColor: Colors.green,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherManagementScreen(),
      ),
    );
  },
),




           DashboardCard(
  title: "Parents",
  icon: Icons.family_restroom,
  backgroundColor: const Color(0xfffff1e6),
  iconBackgroundColor: const Color(0xffffd8b3),
  iconColor: Colors.orange,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentDashboard(),
      ),
    );
  },
),




           DashboardCard(
  title: "AI Reports",
  icon: Icons.analytics,
  backgroundColor: const Color(0xffF3ECFF),
  iconBackgroundColor: const Color(0xffDDC8FF),
  iconColor: Colors.purple,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AIReportsScreen(),
      ),
    );
  },
),



          ],

        ),

      ),

    );

  }

}