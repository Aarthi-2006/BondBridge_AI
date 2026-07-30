import 'package:flutter/material.dart';

import 'add_teacher_screen.dart';
import 'view_teacher_screen.dart';


class TeacherManagementScreen extends StatelessWidget {

  const TeacherManagementScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Teacher Management",
        ),
      ),


      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [


            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.person_add,
                  color: Colors.blue,
                ),

                title: const Text(
                  "Add Teacher",
                ),

                subtitle: const Text(
                  "Create new teacher profile",
                ),


                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const AddTeacherScreen(),

                    ),

                  );

                },

              ),

            ),



            const SizedBox(height: 15),



            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.people,
                  color: Colors.green,
                ),


                title: const Text(
                  "View Teachers",
                ),


                subtitle: const Text(
                  "View and manage teachers",
                ),


                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const ViewTeachersScreen(),

                    ),

                  );


                },


              ),

            ),


          ],

        ),

      ),

    );

  }

}