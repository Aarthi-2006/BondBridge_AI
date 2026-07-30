import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'edit_teacher_screen.dart';
import 'delete_teacher_screen.dart';

class ViewTeachersScreen extends StatefulWidget {
  const ViewTeachersScreen({super.key});

  @override
  State<ViewTeachersScreen> createState() =>
      _ViewTeachersScreenState();
}

class _ViewTeachersScreenState
    extends State<ViewTeachersScreen> {

  List teachers = [];

  bool isLoading = true;
  int totalTeachers = 0;
  String? selectedSubject;

final List<String> subjects = [

  "Tamil",
  "English",
  "Mathematics",
  "Science",
  "Computer Science",
  "Social Science",

];

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers({String? subject}) async {

  setState(() {
    isLoading = true;
  });

  final data = await ApiService.getTeachers(
    subject: subject,
  );

  setState(() {

    teachers = data;

    totalTeachers = data.length;

    isLoading = false;

  });

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("View Teachers"),
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

              : Padding(

    padding: const EdgeInsets.all(16),

    child: Column(

      children: [

        DropdownButtonFormField<String>(

          value: selectedSubject,

          decoration: const InputDecoration(

            labelText: "Subject",

            border: OutlineInputBorder(),

          ),

          items: subjects.map((subject) {

            return DropdownMenuItem(

              value: subject,

              child: Text(subject),

            );

          }).toList(),

          onChanged: (value) {

            setState(() {

              selectedSubject = value;

            });

          },

        ),

        const SizedBox(height: 15),

Row(

  children: [

    Expanded(

      child: ElevatedButton(

        onPressed: () {

  if (selectedSubject != null) {

    loadTeachers(
      subject: selectedSubject,
    );

  }

},
        child: const Text(
          "Search",
        ),

      ),

    ),

    const SizedBox(width: 10),

    Expanded(

      child: ElevatedButton(

       onPressed: () {

  setState(() {

    selectedSubject = null;

  });

  loadTeachers();

},

        child: const Text(
          "Show All",
        ),

      ),

    ),

  ],

),

const SizedBox(height: 15),


        Card(

  elevation: 3,

  child: Padding(

    padding: const EdgeInsets.all(16),

    child: Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        const Text(

          "Total Teachers",

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.bold,

          ),

        ),

        Text(

          totalTeachers.toString(),

          style: const TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Colors.blue,

          ),

        ),

      ],

    ),

  ),

),

const SizedBox(height: 15),

Expanded(

  child: RefreshIndicator(

    onRefresh: () async {

      await loadTeachers(
        subject: selectedSubject,
      );

    },

    child: ListView.builder(

      itemCount: teachers.length,

      itemBuilder: (context, index) {

        final teacher = teachers[index];

        return Card(

          margin: const EdgeInsets.only(bottom: 10),

          child: ListTile(

            leading: const CircleAvatar(

              child: Icon(Icons.person),

            ),

            title: Text(
              teacher["full_name"],
            ),

            subtitle: Text(
              "${teacher["employee_id"]} • ${teacher["subject"]}",
            ),

            trailing: Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                IconButton(

                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),

                  onPressed: () async {

                    await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => EditTeacherScreen(
                          teacher: teacher,
                        ),

                      ),

                    );

                    loadTeachers(
                      subject: selectedSubject,
                    );

                  },

                ),

                IconButton(

                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),

                  onPressed: () async {

                    final result = await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => DeleteTeacherScreen(
                          teacherId: teacher["teacher_id"],
                        ),

                      ),

                    );

                    if (result == true) {

                      loadTeachers(
                        subject: selectedSubject,
                      );

                    }

                  },

                ),

              ],

            ),

          ),

        );

      },

    ),

  ),

),
      ],

    ),

  ),
    );

  }

}