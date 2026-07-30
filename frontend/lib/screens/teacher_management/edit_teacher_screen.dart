import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditTeacherScreen extends StatefulWidget {

  final Map teacher;

  const EditTeacherScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<EditTeacherScreen> createState() =>
      _EditTeacherScreenState();

}

class _EditTeacherScreenState
    extends State<EditTeacherScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController employeeIdController;
  late TextEditingController qualificationController;
  late TextEditingController experienceController;
  late TextEditingController phoneController;

  String? selectedSubject;
  String? selectedGender;
  DateTime? selectedDateOfBirth;
DateTime? selectedJoiningDate;

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

    fullNameController = TextEditingController(
      text: widget.teacher["full_name"],
    );

    emailController = TextEditingController(
      text: widget.teacher["email"],
    );

    employeeIdController = TextEditingController(
      text: widget.teacher["employee_id"],
    );

    qualificationController = TextEditingController(
      text: widget.teacher["qualification"] ?? "",
    );

    experienceController = TextEditingController(
      text: widget.teacher["experience"].toString(),
    );

    phoneController = TextEditingController(
      text: widget.teacher["phone_number"] ?? "",
    );

    selectedSubject = widget.teacher["subject"];
    selectedGender = widget.teacher["gender"];
    if (widget.teacher["date_of_birth"] != null) {
  selectedDateOfBirth = DateTime.parse(
    widget.teacher["date_of_birth"].toString(),
  );
}

if (widget.teacher["joining_date"] != null) {
  selectedJoiningDate = DateTime.parse(
    widget.teacher["joining_date"].toString(),
  );
}

  }
String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

Future<void> pickDate(bool isDOB) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1950),
    lastDate: DateTime(2030),
  );

  if (picked != null) {
    setState(() {
      if (isDOB) {
        selectedDateOfBirth = picked;
      } else {
        selectedJoiningDate = picked;
      }
    });
  }
}
Future<void> updateTeacher() async {

  if (!_formKey.currentState!.validate()) {
    return;
  }

  final response = await ApiService.updateTeacher(

    widget.teacher["teacher_id"],

    {

      "full_name": fullNameController.text,

      "email": emailController.text,

      "employee_id": employeeIdController.text,

      "subject": selectedSubject,

      "qualification": qualificationController.text,

      "experience": int.parse(experienceController.text),

      "phone_number": phoneController.text,

      "gender": selectedGender,

      "date_of_birth": selectedDateOfBirth == null
          ? null
          : formatDate(selectedDateOfBirth!),

      "joining_date": selectedJoiningDate == null
          ? null
          : formatDate(selectedJoiningDate!),

    },

  );

  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(

      content: Text(
        response["message"],
      ),

    ),

  );

  if (response["message"] == "Teacher updated successfully") {

    Navigator.pop(context);

  }

}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Teacher"),
      ),

      body: Padding(

  padding: const EdgeInsets.all(16),

  child: Form(

    key: _formKey,

    child: SingleChildScrollView(

      child: Column(

        children: [

          const SizedBox(height: 10),

          const Text(

            "Edit Teacher",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 20),

          TextFormField(

            controller: fullNameController,

            decoration: const InputDecoration(

              labelText: "Full Name",

              border: OutlineInputBorder(),

            ),

            validator: (value) {

              if (value == null || value.isEmpty) {

                return "Enter full name";

              }

              return null;

            },

          ),

          const SizedBox(height: 15),

          TextFormField(

            controller: emailController,

            decoration: const InputDecoration(

              labelText: "Email",

              border: OutlineInputBorder(),

            ),

            validator: (value) {

              if (value == null || value.isEmpty) {

                return "Enter email";

              }

              return null;

            },

          ),

          const SizedBox(height: 15),

          TextFormField(

            controller: employeeIdController,

            decoration: const InputDecoration(

              labelText: "Employee ID",

              border: OutlineInputBorder(),

            ),

            validator: (value) {

              if (value == null || value.isEmpty) {

                return "Enter employee ID";

              }

              return null;

            },

          ),
          const SizedBox(height: 15),

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

TextFormField(

  controller: qualificationController,

  decoration: const InputDecoration(

    labelText: "Qualification",

    border: OutlineInputBorder(),

  ),

),

const SizedBox(height: 15),

TextFormField(

  controller: experienceController,

  keyboardType: TextInputType.number,

  decoration: const InputDecoration(

    labelText: "Experience (Years)",

    border: OutlineInputBorder(),

  ),

),

const SizedBox(height: 15),

TextFormField(

  controller: phoneController,

  keyboardType: TextInputType.phone,

  decoration: const InputDecoration(

    labelText: "Phone Number",

    border: OutlineInputBorder(),

  ),

),

const SizedBox(height: 15),

DropdownButtonFormField<String>(

  value: selectedGender,

  decoration: const InputDecoration(

    labelText: "Gender",

    border: OutlineInputBorder(),

  ),

  items: genders.map((gender) {

    return DropdownMenuItem(

      value: gender,

      child: Text(gender),

    );

  }).toList(),

  onChanged: (value) {

    setState(() {

      selectedGender = value;

    });

  },

),
const SizedBox(height: 15),

TextFormField(
  readOnly: true,
  decoration: InputDecoration(
    labelText: "Date of Birth",
    border: const OutlineInputBorder(),
    suffixIcon: const Icon(Icons.calendar_today),
    hintText: selectedDateOfBirth == null
        ? "Select Date"
        : formatDate(selectedDateOfBirth!),
  ),
  onTap: () => pickDate(true),
),

const SizedBox(height: 15),

TextFormField(
  readOnly: true,
  decoration: InputDecoration(
    labelText: "Joining Date",
    border: const OutlineInputBorder(),
    suffixIcon: const Icon(Icons.calendar_today),
    hintText: selectedJoiningDate == null
        ? "Select Date"
        : formatDate(selectedJoiningDate!),
  ),
  onTap: () => pickDate(false),
),
const SizedBox(height: 25),

SizedBox(

  width: double.infinity,

  child: ElevatedButton(

    onPressed: updateTeacher,

    child: const Text(
      "Update Teacher",
    ),

  ),

),

        ],

      ),

    ),

  ),

),

    );

  }

}