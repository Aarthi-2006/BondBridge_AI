import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_student_screen.dart';
import 'delete_student_screen.dart';

class ViewStudentsScreen extends StatefulWidget {
  const ViewStudentsScreen({super.key});

  @override
  State<ViewStudentsScreen> createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  List students = [];

  bool isLoading = true;

  int totalStudents = 0;

  String? selectedClass;
  String? selectedSection;

  final List<String> classes = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
  ];

  final List<String> sections = [
    "A",
    "B",
    "C",
    "D",
  ];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
    });

    final data = await ApiService.getStudents(
      studentClass: selectedClass,
      section: selectedSection,
    );

    setState(() {
      students = data;
      totalStudents = data.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Students"),
        backgroundColor: Colors.blue,
      ),
            body: Column(
        children: [

          // ==========================
          // CLASS & SECTION
          // ==========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: "Class",
                      border: OutlineInputBorder(),
                    ),
                    items: classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSection,
                    decoration: const InputDecoration(
                      labelText: "Section",
                      border: OutlineInputBorder(),
                    ),
                    items: sections
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value;
                      });
                    },
                  ),
                ),

              ],
            ),
          ),

          // ==========================
          // SEARCH & SHOW ALL
          // ==========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loadStudents,
                    icon: const Icon(Icons.search),
                    label: const Text("Search"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedClass = null;
                        selectedSection = null;
                      });
                      loadStudents();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Show All"),
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 15),

          // ==========================
          // TOTAL STUDENTS
          // ==========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              color: Colors.blue.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [

                    const Icon(
                      Icons.groups,
                      color: Colors.blue,
                      size: 40,
                    ),

                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Total Students",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "$totalStudents",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : students.isEmpty
                    ? const Center(
                        child: Text(
                          "No Students Found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadStudents,
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    student["full_name"]
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  student["full_name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text("Email : ${student["email"]}"),
                                    Text("Roll No : ${student["roll_no"]}"),
                                    Text(
                                      "Class : ${student["class"]} - ${student["section"]}",
                                    ),
                                    Text("Gender : ${student["gender"]}"),
                                  ],
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
                                            builder: (_) => EditScreen(
                                              student: student,
                                            ),
                                          ),
                                        );
                                        loadStudents();
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DeleteScreen(
                                              student: student,
                                            ),
                                          ),
                                        );
                                        loadStudents();
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
    );
  }
}