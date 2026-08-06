import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState
    extends State<StudentManagementScreen> {

  // ==========================
  // FORM KEY
  // ==========================
  final _formKey = GlobalKey<FormState>();

  // ==========================
  // CONTROLLERS
  // ==========================
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rollNoController = TextEditingController();
  final dobController = TextEditingController();
  final admissionController = TextEditingController();

  // ==========================
  // DROPDOWN VALUES
  // ==========================
  String? selectedClass;
  String? selectedSection;
  String? selectedGender;

  // ==========================
  // STUDENT DATA
  // ==========================
  List students = [];
  Map<String, dynamic>? editingStudent;

  bool isLoading = false;
  bool showPassword = false;

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
    "12"
  ];

  final List<String> sections = [
    "A",
    "B",
    "C",
    "D",
  ];

  final List<String> genders = [
    "Male",
    "Female",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }
  // ==========================
// LOAD STUDENTS
// ==========================
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
    isLoading = false;
  });
}

// ==========================
// DATE PICKER
// ==========================
Future<void> pickDate(
  TextEditingController controller,
) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1990),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
  }
}

// ==========================
// CLEAR FORM
// ==========================
void clearForm() {
  fullNameController.clear();
  emailController.clear();
  passwordController.clear();
  rollNoController.clear();
  dobController.clear();
  admissionController.clear();

  selectedClass = null;
  selectedSection = null;
  selectedGender = null;

  editingStudent = null;
}

// ==========================
// OPEN ADD DIALOG
// ==========================
void openAddStudent() {
  clearForm();
  showStudentDialog();
}

// ==========================
// OPEN EDIT DIALOG
// ==========================
void openEditStudent(Map<String, dynamic> student) {  editingStudent = student;

  fullNameController.text = student["full_name"]?.toString () ??"";
  emailController.text = student["email"]?.toString()??"";
  passwordController.clear();
  rollNoController.text = student["roll_no"]?.toString()??"";

  selectedClass = student["class"].toString();
  selectedSection = student["section"].toString();
  selectedGender = student["gender"].toString();

  dobController.text =
      student["date_of_birth"].toString().split(" ")[0];

  admissionController.text =
      student["admission_date"].toString().split(" ")[0];

  showStudentDialog();
}
// ==========================
// ADD / UPDATE STUDENT
// ==========================
Future<void> saveStudent() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
  });

  Map<String, dynamic> result;

  if (editingStudent == null) {
    result = await ApiService.addStudent(
      fullName: fullNameController.text,
      email: emailController.text,
      password: passwordController.text,
      rollNo: rollNoController.text,
      studentClass: selectedClass!,
      section: selectedSection!,
      dateOfBirth: dobController.text,
      gender: selectedGender!,
      admissionDate: admissionController.text,
    );
  } else {
    result = await ApiService.updateStudent(
      editingStudent!["student_id"],
      {
        "full_name": fullNameController.text,
        "email": emailController.text,
        "roll_no": rollNoController.text,
        "class": selectedClass,
        "section": selectedSection,
        "gender": selectedGender,
        "date_of_birth": dobController.text,
        "admission_date": admissionController.text,
      },
    );
  }

  setState(() {
    isLoading = false;
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result["message"]),
    ),
  );

  Navigator.pop(context);

  loadStudents();
}

// ==========================
// DELETE STUDENT
// ==========================
Future<void> deleteStudent(int studentId) async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Student"),
      content: const Text(
        "Are you sure you want to delete this student?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final result = await ApiService.deleteStudent(studentId);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result["message"]),
    ),
  );

  loadStudents();
}
// ==========================
// ADD / EDIT DIALOG
// ==========================
void showStudentDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          editingStudent == null
              ? "Add Student"
              : "Edit Student",
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  if (editingStudent == null)
                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Required" : null,
                    ),

                  if (editingStudent == null)
                    const SizedBox(height: 12),

                  TextFormField(
                    controller: rollNoController,
                    decoration: const InputDecoration(
                      labelText: "Roll Number",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: "Class",
                    ),
                    items: classes
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedSection,
                    decoration: const InputDecoration(
                      labelText: "Section",
                    ),
                    items: sections
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: "Gender",
                    ),
                    items: genders
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Required" : null,
                  ),
                                    const SizedBox(height: 12),

                  TextFormField(
                    controller: dobController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () => pickDate(dobController),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: admissionController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Admission Date",
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () => pickDate(admissionController),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveStudent,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              editingStudent == null
                                  ? "Add Student"
                                  : "Update Student",
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
@override
void dispose() {

  fullNameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  rollNoController.dispose();
  dobController.dispose();
  admissionController.dispose();

  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Management"),
        backgroundColor: Colors.blue,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: openAddStudent,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          // ==========================
          // CLASS & SECTION FILTER
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

          const SizedBox(height: 10),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  const Icon(
                    Icons.groups,
                    size: 40,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Total Students",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        students.length.toString(),
                        style: const TextStyle(
                          fontSize: 28,
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
                                    student["full_name"] != null &&
                                       student["full name"].toString().isNotEmpty
                                    ?student["full name"]
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase()
                                        :"?",
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

                                    Text(
                                      "Email : ${student["email"]}",
                                    ),

                                    Text(
                                      "Roll No : ${student["roll_no"]}",
                                    ),

                                    Text(
                                      "Class : ${student["class"]} - ${student["section"]}",
                                    ),

                                    Text(
                                      "Gender : ${student["gender"]}",
                                    ),

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
                                      onPressed: () {
                                        openEditStudent(student);
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteStudent(
                                          student["student_id"],
                                        );
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