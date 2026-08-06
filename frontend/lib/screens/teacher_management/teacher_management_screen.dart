import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState
    extends State<TeacherManagementScreen> {

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
  final employeeIdController = TextEditingController();
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final joiningController = TextEditingController();

  // ==========================
  // DROPDOWNS
  // ==========================
  String? selectedSubject;
  String? selectedGender;

  // ==========================
  // DATA
  // ==========================
  List teachers = [];
  Map<String, dynamic>? editingTeacher;

  bool isLoading = false;
  bool showPassword = false;

  final List<String> subjects = [
    "Tamil",
    "English",
    "Mathematics",
    "Science",
    "Computer Science",
    "Social Science",
  ];

  final List<String> genders = [
    "Male",
    "Female",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }
    // ==========================
  // LOAD TEACHERS
  // ==========================
  Future<void> loadTeachers() async {
    setState(() {
      isLoading = true;
    });

    final data = await ApiService.getTeachers(
      subject: selectedSubject,
    );

    setState(() {
      teachers = data;
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
    employeeIdController.clear();
    qualificationController.clear();
    experienceController.clear();
    phoneController.clear();
    dobController.clear();
    joiningController.clear();

    selectedSubject = null;
    selectedGender = null;

    editingTeacher = null;
  }

  // ==========================
  // OPEN ADD DIALOG
  // ==========================
  void openAddTeacher() {
    clearForm();
    showTeacherDialog();
  }

  // ==========================
  // OPEN EDIT DIALOG
  // ==========================
  void openEditTeacher(
      Map<String, dynamic> teacher) {

    editingTeacher = teacher;

    fullNameController.text =
        teacher["full_name"];

    emailController.text =
        teacher["email"];

    passwordController.clear();

    employeeIdController.text =
        teacher["employee_id"];

    qualificationController.text =
        teacher["qualification"];

    experienceController.text =
        teacher["experience"].toString();

    phoneController.text =
        teacher["phone_number"];

    selectedSubject =
        teacher["subject"];

    selectedGender =
        teacher["gender"];

    dobController.text =
        teacher["date_of_birth"]
            .toString()
            .split(" ")[0];

    joiningController.text =
        teacher["joining_date"]
            .toString()
            .split(" ")[0];

    showTeacherDialog();
  }
    // ==========================
  // SAVE / UPDATE TEACHER
  // ==========================
  Future<void> saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> result;

    if (editingTeacher == null) {
      result = await ApiService.addTeacher(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        employeeId: employeeIdController.text,
        subject: selectedSubject!,
        qualification: qualificationController.text,
        experience: int.parse(experienceController.text),
        phoneNumber: phoneController.text,
        gender: selectedGender!,
        dateOfBirth: dobController.text,
        joiningDate: joiningController.text,
      );
    } else {
      result = await ApiService.updateTeacher(
        editingTeacher!["teacher_id"],
        {
          "full_name": fullNameController.text,
          "email": emailController.text,
          "employee_id": employeeIdController.text,
          "subject": selectedSubject,
          "qualification": qualificationController.text,
          "experience":
              int.parse(experienceController.text),
          "phone_number": phoneController.text,
          "gender": selectedGender,
          "date_of_birth": dobController.text,
          "joining_date": joiningController.text,
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

    loadTeachers();
  }

  // ==========================
  // DELETE TEACHER
  // ==========================
  Future<void> deleteTeacher(
      int teacherId) async {

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Teacher"),
        content: const Text(
          "Are you sure you want to delete this teacher?",
        ),
        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Delete"),
          ),

        ],
      ),
    );

    if (confirm != true) return;

    final result =
        await ApiService.deleteTeacher(
      teacherId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
      ),
    );

    loadTeachers();
  }
  // ==========================
// ADD / EDIT TEACHER DIALOG
// ==========================
void showTeacherDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          editingTeacher == null
              ? "Add Teacher"
              : "Edit Teacher",
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

                  if (editingTeacher == null)
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

                  if (editingTeacher == null)
                    const SizedBox(height: 12),

                  TextFormField(
                    controller: employeeIdController,
                    decoration: const InputDecoration(
                      labelText: "Employee ID",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: "Subject",
                    ),
                    items: subjects
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: qualificationController,
                    decoration: const InputDecoration(
                      labelText: "Qualification",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Experience (Years)",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),
                                    const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
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
                    controller: joiningController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Joining Date",
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () => pickDate(joiningController),
                    validator: (value) =>
                        value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveTeacher,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              editingTeacher == null
                                  ? "Add Teacher"
                                  : "Update Teacher",
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Management"),
        backgroundColor: Colors.blue,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: openAddTeacher,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          // ==========================
          // SUBJECT FILTER
          // ==========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: "Filter by Subject",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Subjects"),
                      ),
                      ...subjects.map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: loadTeachers,
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                ),

              ],
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  const Icon(
                    Icons.school,
                    size: 40,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Total Teachers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        teachers.length.toString(),
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
                : teachers.isEmpty
                    ? const Center(
                        child: Text(
                          "No Teachers Found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadTeachers,
                        child: ListView.builder(
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {

                            final teacher = teachers[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              elevation: 3,
                              child: ListTile(

                                leading: CircleAvatar(
                                  child: Text(
                                    teacher["full_name"]
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                  ),
                                ),

                                title: Text(
                                  teacher["full_name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "Email : ${teacher["email"]}",
                                    ),

                                    Text(
                                      "Employee ID : ${teacher["employee_id"]}",
                                    ),

                                    Text(
                                      "Subject : ${teacher["subject"]}",
                                    ),

                                    Text(
                                      "Qualification : ${teacher["qualification"]}",
                                    ),

                                    Text(
                                      "Experience : ${teacher["experience"]} Years",
                                    ),

                                    Text(
                                      "Phone : ${teacher["phone_number"]}",
                                    ),

                                    Text(
                                      "Gender : ${teacher["gender"]}",
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
                                        openEditTeacher(
                                          Map<String, dynamic>.from(
                                            teacher,
                                          ),
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteTeacher(
                                          teacher["teacher_id"],
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