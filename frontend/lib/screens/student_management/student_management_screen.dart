import 'package:flutter/material.dart';
import 'view_students_screen.dart';
import 'add_student_screen.dart';
import '../../services/api_service.dart';

class StudentManagementScreen extends StatefulWidget {

  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState
    extends State<StudentManagementScreen> {

  int totalStudents = 0;

  @override
  void initState() {
    super.initState();
    loadStudentCount();
  }

  Future<void> loadStudentCount() async {

    final count = await ApiService.getStudentCount();

    setState(() {
      totalStudents = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Student Management",
        ),

        backgroundColor: Colors.blue,

      ),



      body: Padding(


        padding:
            const EdgeInsets.all(20),



        child: Column(


          children: [


            Container(
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 20),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.blue.shade200,
    ),
  ),
  child: Column(
    children: [

      const Icon(
        Icons.school,
        size: 40,
        color: Colors.blue,
      ),

      const SizedBox(height: 10),

      const Text(
        "Total Students",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

      Text(
        totalStudents.toString(),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    ],
  ),
),

            // ADD STUDENT

            Card(

              child: ListTile(


                leading: const Icon(

                  Icons.person_add,

                  color: Colors.green,

                ),


                title: const Text(
                  "Add Student",
                ),


                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context)=>

                      const AddStudentScreen(),

                    ),

                  );


                },


              ),

            ),





            // VIEW STUDENT


            Card(

              child: ListTile(


                leading: const Icon(

                  Icons.people,

                  color: Colors.blue,

                ),



                title: const Text(

                  "View Students",

                ),



                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context)=>

                      const ViewStudentsScreen(),

                    ),

                  );


                },


              ),

            ),





            // EDIT STUDENT


            Card(

              child: ListTile(


                leading: const Icon(

                  Icons.edit,

                  color: Colors.orange,

                ),



                title: const Text(

                  "Edit Student",

                ),



                subtitle: const Text(

                  "Update student details",

                ),



                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context)=>

                      const ViewStudentsScreen(),

                    ),

                  );


                },


              ),

            ),






            // DELETE STUDENT


            Card(

              child: ListTile(


                leading: const Icon(

                  Icons.delete,

                  color: Colors.red,

                ),



                title: const Text(

                  "Delete Student",

                ),



                subtitle:

                const Text(

                  "Remove student record",

                ),



                onTap: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context)=>

                      const ViewStudentsScreen(),

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