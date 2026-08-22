import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/class_permission_service.dart';
import '../services/session.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  // ==========================================
// DROPDOWN VALUES
// ==========================================

String? selectedClass;
String? selectedSection;
String? selectedSubject;
String? filterClass;
String? filterSection;
String? filterSubject;
// ==========================================
// HOMEWORK LIST
// ==========================================

List<dynamic> homeworkList = [];

// ==========================================
// LOADING
// ==========================================

bool isLoading = false;
String currentPage = "Assign Homework";
// ==========================================
// TEXT CONTROLLERS
// ==========================================

final TextEditingController titleController = TextEditingController();
final TextEditingController descriptionController =
    TextEditingController();

final TextEditingController assignedDateController =
    TextEditingController();

final TextEditingController dueDateController =
    TextEditingController();
// ==========================================
// SUBJECTS
// ==========================================

final List<String> subjects = [
  "Tamil",
  "English",
  "Mathematics",
  "Science",
  "Social Science",
  "Biology",
  "Chemistry",
  "Physics",
];
// ==========================================
// SELECTED DATES
// ==========================================

DateTime? assignedDate;
DateTime? dueDate;
// ==========================================
// CLASS & SECTION DATA
// ==========================================

List<String> availableClasses = [];
List<String> availableSections = [];
@override
void initState() {
  super.initState();

  availableClasses = ClassPermissionService.getAvailableClasses();

  if (Session.role?.toLowerCase()
   == "student") {
    currentPage = "View Homework";
  }

  loadHomework();
}
Future<void> selectAssignedDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: assignedDate ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    setState(() {
      assignedDate = picked;
      assignedDateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    });
  }
}
Future<void> selectDueDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: dueDate ?? assignedDate ?? DateTime.now(),
    firstDate: assignedDate ?? DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    setState(() {
      dueDate = picked;
      dueDateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    });
  }
}
bool validateHomeworkForm() {
  if (selectedClass == null || selectedClass!.isEmpty) {
    return false;
  }

  if (selectedSection == null || selectedSection!.isEmpty) {
    return false;
  }

  if (selectedSubject == null || selectedSubject!.isEmpty) {
    return false;
  }

  if (titleController.text.trim().isEmpty) {
    return false;
  }

  if (descriptionController.text.trim().isEmpty) {
    return false;
  }

  if (assignedDate == null) {
    return false;
  }

  if (dueDate == null) {
    return false;
  }

  return true;
}
Future<void> loadHomework() async {
  setState(() {
    isLoading = true;
  });

  try {
    List<dynamic> data = [];

    // ==========================================
    // STUDENT
    // ==========================================

    if (Session.role?.toLowerCase()  == "student") {
      if (Session.studentId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      data = await ApiService.getHomework(
          studentId: Session.studentId,

      );
    }

    // ==========================================
    // TEACHER
    // ==========================================

    else if (Session.role ?.toLowerCase() == "teacher") {
      if (Session.teacherId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      data = await ApiService.getHomework(
        teacherId: Session.teacherId,
        className: filterClass,
        section: filterSection,
        subject: filterSubject,
      );
    }

    setState(() {
      homeworkList = data;
      isLoading = false;
    });

  } catch (e) {

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to load homework: $e"),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework"),
        backgroundColor: Colors.blue,
      ),
     body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Homework Management",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "Assign and manage homework for your classes.",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
const SizedBox(height: 20),

if (Session.role?.toLowerCase()  == "teacher")
  Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentPage = "Assign Homework";
            });
          },
          child: const Text("Assign Homework"),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentPage = "View Homework";
            });
          },
          child: const Text("View Homework"),
        ),
      ),
    ],
  ),

const SizedBox(height: 20),
if (currentPage == "Assign Homework" &&
    Session.role?.toLowerCase()  == "teacher") ...[
DropdownButtonFormField<String>(
  initialValue: selectedClass,
  decoration: const InputDecoration(
    labelText: "Class",
    border: OutlineInputBorder(),
  ),
  items: availableClasses.map((className) {
    return DropdownMenuItem<String>(
      value: className,
      child: Text(className),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedClass = value;
      selectedSection = null;

      availableSections =
          ClassPermissionService.getAvailableSections(value!);
    });
  },
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  initialValue: selectedSection,
  decoration: const InputDecoration(
    labelText: "Section",
    border: OutlineInputBorder(),
  ),
  items: availableSections.map((section) {
    return DropdownMenuItem<String>(
      value: section,
      child: Text(section),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedSection = value;
    });
  },
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  initialValue: selectedSubject,
  decoration: const InputDecoration(
    labelText: "Subject",
    border: OutlineInputBorder(),
  ),
  items: subjects.map((subject) {
    return DropdownMenuItem<String>(
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
const SizedBox(height: 16),

TextFormField(
  controller: titleController,
  decoration: const InputDecoration(
    labelText: "Homework Title",
    hintText: "Enter homework title",
    border: OutlineInputBorder(),
  ),
),
const SizedBox(height: 16),

TextFormField(
  controller: descriptionController,
  maxLines: 4,
  decoration: const InputDecoration(
    labelText: "Homework Description",
    hintText: "Enter homework description",
    border: OutlineInputBorder(),
    alignLabelWithHint: true,
  ),
),
const SizedBox(height: 16),

TextFormField(
  controller: assignedDateController,
  readOnly: true,
  onTap: selectAssignedDate,
  decoration: const InputDecoration(
    labelText: "Assigned Date",
    hintText: "Select assigned date",
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
  ),
),
const SizedBox(height: 16),

TextFormField(
  controller: dueDateController,
  readOnly: true,
  onTap: selectDueDate,
  decoration: const InputDecoration(
    labelText: "Due Date",
    hintText: "Select due date",
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
  ),
),
const SizedBox(height: 16),


SizedBox(
  width: double.infinity,
  child: ElevatedButton(
   onPressed: () async {
  if (!validateHomeworkForm()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all homework details"),
      ),
    );
    return;
  }

  try {
    final data = {
      "teacher_id": Session.teacherId,
      "class": selectedClass,
      "section": selectedSection,
      "subject": selectedSubject,
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "assigned_date": assignedDate!.toIso8601String().split('T')[0],
      "due_date": dueDate!.toIso8601String().split('T')[0],
    
    };

    final response = await ApiService.addHomework(data);
    if (!context.mounted) return;
    if (response["success"])
     {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Homework assigned successfully"),
    ),
  );
  titleController.clear();
descriptionController.clear();
assignedDateController.clear();
dueDateController.clear();
assignedDate = null;
dueDate = null;
setState(() {
  selectedClass = null;
selectedSection = null;
availableSections = [];
    selectedSubject = null;

});
  await loadHomework();
}
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"] ?? "Failed to assign homework",
          ),
        ),
      );
    }
  } catch (e) {
    if(!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
},
    child: const Text("Assign Homework"),
  ),
),
const SizedBox(height: 30),
],
if (currentPage == "View Homework") ...[

  if (Session.role?.toLowerCase()  == "teacher") ...[
DropdownButtonFormField<String>(
  initialValue: filterClass,
  decoration: const InputDecoration(
    labelText: "Filter by Class",
    border: OutlineInputBorder(),
  ),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text("All Classes"),
    ),
    ...availableClasses.map(
      (className) => DropdownMenuItem<String>(
        value: className.toString(),
        child: Text(className.toString()),
      ),
    ),
  ],
  onChanged: (value) async {
    setState(() {
      filterClass = value;
          filterSection = null;

    });

    await loadHomework();
  },
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  initialValue: filterSection,
  decoration: const InputDecoration(
    labelText: "Filter by Section",
    border: OutlineInputBorder(),
  ),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text("All Sections"),
    ),
    if (filterClass != null)
      ...ClassPermissionService
          .getAvailableSections(filterClass!)
          .toSet()
          .map(
            (section) => DropdownMenuItem<String>(
              value: section.toString(),
              child: Text(section.toString()),
            ),
          ),
  ],
  onChanged: (value) async {
    setState(() {
      filterSection = value;
    });

    await loadHomework();
  },
),

const SizedBox(height: 16),
DropdownButtonFormField<String>(
  initialValue: filterSubject,
  decoration: const InputDecoration(
    labelText: "Filter by Subject",
    border: OutlineInputBorder(),
  ),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text("All Subjects"),
    ),
    ...subjects.map(
      (subject) => DropdownMenuItem<String>(
        value: subject.toString(),
        child: Text(subject.toString()),
      ),
    ),
  ],
  onChanged: (value) async {
    setState(() {
      filterSubject = value;
    });

    await loadHomework();
  },
),



const SizedBox(height: 16),

// 👇 PUT CLEAR FILTERS HERE

Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () async {
      setState(() {
        filterClass = null;
        filterSection = null;
        filterSubject = null;
      });

      await loadHomework();
    },
    icon: const Icon(Icons.clear),
    label: const Text("Clear Filters"),
  ),
),

  ],
// 👇 ASSIGNED HOMEWORK COMES AFTER CLEAR FILTERS


const SizedBox(height: 8),
const Text(
  "Assigned Homework",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (isLoading)
  const Center(
    child: CircularProgressIndicator(),
  )
else if (homeworkList.isEmpty)
const Center(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.assignment_outlined,
          size: 70,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          "No homework assigned yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Assign homework to see it here.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
)
else
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: homeworkList.length,
    itemBuilder: (context, index) {
      final homework = homeworkList[index];

      return Card(
  elevation: 3,
  margin: const EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 6,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: ListTile(
  contentPadding: const EdgeInsets.all(16),

  title: Text(
    homework["title"]?.toString() ?? "",
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  subtitle: Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subject: ${homework["subject"] ?? ""}",
        ),

        const SizedBox(height: 4),

        Text(
          "Class: ${homework["class"] ?? ""} - "
          "${homework["section"] ?? ""}",
        ),

        const SizedBox(height: 4),

        Row(
  children: [
    const Icon(
      Icons.calendar_today,
      size: 18,
    ),
    const SizedBox(width: 8),
    Text(
      "Assigned: ${homework["assigned_date"] ?? ""}",
    ),
  ],
),

const SizedBox(height: 6),

Row(
  children: [
    const Icon(
      Icons.event,
      size: 18,
    ),
    const SizedBox(width: 8),
    Text(
      "Due: ${homework["due_date"] ?? ""}",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),

        const SizedBox(height: 8),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    homework["description"]?.toString() ?? "",
    style: const TextStyle(
      fontSize: 15,
      height: 1.4,
    ),
  ),
),
      ],
    ),
  ),
),
      );
    },
  ),
    ],
    ],
  ),
),
    );
  }
}