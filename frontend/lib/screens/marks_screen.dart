import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/class_permission_service.dart';
import '../services/session.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {

  //=====================================================
  // DROPDOWN VALUES
  //=====================================================

  String? selectedClass;
  String? selectedSection;
  String? selectedStudentId;
  String? selectedSubject;
  String? selectedAssessmentType;
  String? selectedAcademicYear;

  DateTime? selectedAssessmentDate;

  //=====================================================
  // CONTROLLERS
  //=====================================================

  final TextEditingController assessmentNameController =
      TextEditingController();

  final TextEditingController totalMarksController =
      TextEditingController();

  final TextEditingController obtainedMarksController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  //=====================================================
  // DATA
  //=====================================================

  List students = [];

  bool isLoading = false;
  List viewMarks = [];
  String selectedPage = "Add Marks";

  //=====================================================
  // CLASSES
  //=====================================================

  final List<String> allClasses = [

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

  //=====================================================
  // SECTIONS
  //=====================================================

  final List<String> allSections = [

    "A",
    "B",
    "C",
    "D",

  ];

  //=====================================================
  // ASSESSMENT TYPES
  //=====================================================

  final List<String> assessmentTypes = [

    "Daily Test",
    "Weekly Test",
    "Assignment",
    "Monthly Test",
    "Quarterly Exam",
    "Half-Yearly Exam",
    "Annual Exam",

  ];

  //=====================================================
  // ACADEMIC YEARS
  //=====================================================

  final List<String> academicYears = [

    "2025-2026",
    "2026-2027",
    "2027-2028",

  ];

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  //=====================================================
  // LOAD PERMISSIONS
  //=====================================================

  Future<void> loadPermissions() async {

    if (Session.role == "teacher") {

      await ClassPermissionService.loadPermissions();

      if (mounted) {
        setState(() {});
      }
    }
  }

  //=====================================================
  // AVAILABLE CLASSES
  //=====================================================

  List<String> getAvailableClasses() {

    if (Session.role == "admin") {
      return allClasses;
    }

    return ClassPermissionService.getClasses()
        .map((item) => item["class"].toString())
        .toSet()
        .toList();
  }

  //=====================================================
  // AVAILABLE SECTIONS
  //=====================================================

  List<String> getAvailableSections() {

    if (Session.role == "admin") {
      return allSections;
    }

    if (selectedClass == null) {
      return [];
    }

    return ClassPermissionService.getClasses()
        .where(
          (item) =>
              item["class"].toString() ==
              selectedClass,
        )
        .map(
          (item) =>
              item["section"].toString(),
        )
        .toSet()
        .toList();
  }

  //=====================================================
  // SUBJECTS
  //=====================================================

  List<String> getAvailableSubjects() {

    if (selectedClass == null) {
      return [];
    }

    final classNumber =
        int.tryParse(selectedClass!);

    if (classNumber == null) {
      return [];
    }

    // Classes 1-10

    if (classNumber >= 1 &&
        classNumber <= 10) {

      return [

        "Tamil",
        "English",
        "Mathematics",
        "Science",
        "Social Science",

      ];
    }

    // Classes 11-12

    return [

      "Tamil",
      "English",
      "Mathematics",
      "Physics",
      "Chemistry",
      "Biology",

    ];
  }

  //=====================================================
  // AUTO MAXIMUM MARKS
  //=====================================================

  void setDefaultMaximumMarks(
      String assessmentType) {

    switch (assessmentType) {

      case "Daily Test":
        totalMarksController.text = "10";
        break;

      case "Weekly Test":
        totalMarksController.text = "25";
        break;

      case "Assignment":
        totalMarksController.text = "20";
        break;

      case "Monthly Test":
        totalMarksController.text = "50";
        break;

      case "Quarterly Exam":
        totalMarksController.text = "100";
        break;

      case "Half-Yearly Exam":
        totalMarksController.text = "100";
        break;

      case "Annual Exam":
        totalMarksController.text = "100";
        break;

      default:
        totalMarksController.clear();
    }
  }
    //=====================================================
  // LOAD STUDENTS
  //=====================================================

  Future<void> loadStudents() async {

    if (selectedClass == null ||
        selectedSection == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select Class and Section.",
          ),
        ),
      );

      return;
    }

    // Teacher Permission Check

    if (Session.role == "teacher") {

      final allowed =
          ClassPermissionService.isAssigned(
        selectedClass!,
        selectedSection!,
      );

      if (!allowed) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You are not assigned to this class.",
            ),
          ),
        );

        return;
      }
    }

    setState(() {

      isLoading = true;
      students = [];
      selectedStudentId = null;

    });

    try {

      final result =
          await ApiService.getStudents(

        studentClass: selectedClass,
        section: selectedSection,

      );

      if (!mounted) return;

      setState(() {

        students = result;
        isLoading = false;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        isLoading = false;

      });

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            "Failed to load students\n$e",
          ),
        ),

      );
    }
  }


//=====================================================
// LOAD VIEW MARKS
//=====================================================

Future<void> loadViewMarks() async {

  if (selectedClass == null || selectedSection == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select Class and Section."),
      ),
    );

    return;
  }

  setState(() {
    isLoading = true;
    viewMarks = [];
  });

  try {

    final result = await ApiService.getMarks(
  studentClass: selectedClass!,
  section: selectedSection!,
);

if (!mounted) return;

setState(() {
  viewMarks = result;
});
  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to load marks\n$e"),
      ),
    );

  } finally {

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

  }

}
  //=====================================================
  // VALIDATION
  //=====================================================

  bool validateMarks() {

    if (selectedStudentId == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a student.",
          ),
        ),
      );

      return false;
    }

    if (selectedSubject == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a subject.",
          ),
        ),
      );

      return false;
    }

    if (selectedAssessmentType == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select assessment type.",
          ),
        ),
      );

      return false;
    }

    if (assessmentNameController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter assessment name.",
          ),
        ),
      );

      return false;
    }

    if (selectedAssessmentDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select assessment date.",
          ),
        ),
      );

      return false;
    }

    if (selectedAcademicYear == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select academic year.",
          ),
        ),
      );

      return false;
    }

    final totalMarks =
        double.tryParse(
      totalMarksController.text.trim(),
    );

    final obtainedMarks =
        double.tryParse(
      obtainedMarksController.text.trim(),
    );

    if (totalMarks == null ||
        totalMarks <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid maximum marks.",
          ),
        ),
      );

      return false;
    }

    if (obtainedMarks == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid obtained marks.",
          ),
        ),
      );

      return false;
    }

    if (obtainedMarks > totalMarks) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Marks cannot exceed $totalMarks",
          ),
        ),
      );

      return false;
    }

    return true;
  }

  //=====================================================
  // SAVE MARKS
  //=====================================================

  Future<void> saveMarks() async {

    if (!validateMarks()) {
      return;
    }

    if (Session.teacherId == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Teacher not found. Login again.",
          ),
        ),
      );

      return;
    }

    setState(() {

      isLoading = true;

    });

    try {

      await ApiService.addMarks(

        studentId:
            int.parse(selectedStudentId!),

        teacherId:
            Session.teacherId!,

        subject:
            selectedSubject!,

        assessmentType:
            selectedAssessmentType!,

        assessmentCategory:
            selectedAssessmentType!,

        assessmentName:
            assessmentNameController.text.trim(),

        assessmentDate:
            "${selectedAssessmentDate!.year}-"
            "${selectedAssessmentDate!.month.toString().padLeft(2, '0')}-"
            "${selectedAssessmentDate!.day.toString().padLeft(2, '0')}",

        academicYear:
            selectedAcademicYear!,

        marksObtained:
            double.parse(
          obtainedMarksController.text,
        ),

        totalMarks:
            double.parse(
          totalMarksController.text,
        ),

        teacherRemarks:
            remarksController.text.trim(),

      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Marks saved successfully.",
          ),
        ),
      );

      clearForm();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            "Failed to save marks\n$e",
          ),
        ),

      );

    }

    if (mounted) {

      setState(() {

        isLoading = false;

      });

    }
  }

  //=====================================================
  // CLEAR FORM
  //=====================================================

  void clearForm() {

    assessmentNameController.clear();

    totalMarksController.clear();

    obtainedMarksController.clear();

    remarksController.clear();

    setState(() {

      selectedStudentId = null;
      selectedSubject = null;
      selectedAssessmentType = null;
      selectedAcademicYear = null;
      selectedAssessmentDate = null;

    });
  }


  Widget _markRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}
List<Map<String, dynamic>> _groupMarksByStudent() {

  final Map<String, Map<String, dynamic>> grouped = {};

  for (final mark in viewMarks) {

    final String studentId =
        mark["student_id"].toString();

    if (!grouped.containsKey(studentId)) {

      grouped[studentId] = {
        "student_id": studentId,
        "student_name":
            mark["student_name"]?.toString() ??
                "Unknown Student",
        "roll_no":
            mark["roll_no"]?.toString() ?? "-",
        "marks": [],
      };
    }

    if (mark["mark_id"] != null) {

      grouped[studentId]!["marks"].add(mark);
    }
  }

  return grouped.values.toList();
}
    @override
  Widget build(BuildContext context) {

    final availableClasses = getAvailableClasses();
    final availableSections = getAvailableSections();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Marks Entry"),
        centerTitle: true,
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
             if (selectedPage == "Add Marks")...[
             
              const Text(

                "Enter Student Marks",

                style: TextStyle(

                  fontSize: 24,
                  fontWeight: FontWeight.bold,

                ),
              ),

              const SizedBox(height: 20),

              //====================================
              // CLASS
              //====================================

        

Row(
  children: [

    Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedPage = "Add Marks";
          });
        },
        child: const Text("Add Marks"),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedPage = "View Marks";
          });
        },
        child: const Text("View Marks"),
      ),
    ),

  ],
),

const SizedBox(height: 20),
Text(
  "Current Page: $selectedPage",
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),
              const SizedBox(height: 16),

              //====================================
              // SECTION
              //====================================

              DropdownButtonFormField<String>(

                initialValue: selectedSection,

                decoration: const InputDecoration(

                  labelText: "Section",

                  border: OutlineInputBorder(),

                ),

                items: availableSections.map((item) {

                  return DropdownMenuItem(

                    value: item,

                    child: Text(item),

                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedSection = value;

                    selectedStudentId = null;

                    students = [];

                  });

                },

              ),

              const SizedBox(height: 20),

              //====================================
              // LOAD STUDENTS
              //====================================

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  icon: const Icon(Icons.people),

                  label: Text(

                    isLoading
                        ? "Loading..."
                        : "Load Students",

                  ),

                  onPressed:
                      isLoading
                          ? null
                          : loadStudents,

                ),

              ),

              const SizedBox(height: 20),

              //====================================
              // STUDENT
              //====================================

              DropdownButtonFormField<String>(

                initialValue: selectedStudentId,

                decoration: const InputDecoration(

                  labelText: "Student",

                  border: OutlineInputBorder(),

                ),

                items: students.map<DropdownMenuItem<String>>((student) {

                  return DropdownMenuItem<String>(

                    value: student["student_id"].toString(),

                    child: Text(
                      student["full_name"].toString(),
                    ),

                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedStudentId = value;

                  });

                },

              ),

              const SizedBox(height: 20),
                            //====================================
              // SUBJECT
              //====================================

              DropdownButtonFormField<String>(

                initialValue: selectedSubject,

                decoration: const InputDecoration(

                  labelText: "Subject",

                  border: OutlineInputBorder(),

                ),

                items: getAvailableSubjects().map((subject) {

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

              //====================================
              // ASSESSMENT TYPE
              //====================================

              DropdownButtonFormField<String>(

                initialValue: selectedAssessmentType,

                decoration: const InputDecoration(

                  labelText: "Assessment Type",

                  border: OutlineInputBorder(),

                ),

                items: assessmentTypes.map((type) {

                  return DropdownMenuItem<String>(

                    value: type,

                    child: Text(type),

                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedAssessmentType = value;

                    if (value != null) {
                      setDefaultMaximumMarks(value);
                    }

                  });

                },

              ),

              const SizedBox(height: 16),

              //====================================
              // ASSESSMENT NAME
              //====================================

              TextField(

                controller: assessmentNameController,

                decoration: const InputDecoration(

                  labelText: "Assessment Name",

                  hintText: "Example: Monthly Test - July",

                  border: OutlineInputBorder(),

                ),

              ),

              const SizedBox(height: 16),

              //====================================
              // ASSESSMENT DATE
              //====================================

              InkWell(

                onTap: () async {

                  final pickedDate =
                      await showDatePicker(

                    context: context,

                    initialDate: DateTime.now(),

                    firstDate: DateTime(2024),

                    lastDate: DateTime(2100),

                  );

                  if (pickedDate != null) {

                    setState(() {

                      selectedAssessmentDate =
                          pickedDate;

                    });

                  }

                },

                child: InputDecorator(

                  decoration: const InputDecoration(

                    labelText: "Assessment Date",

                    border: OutlineInputBorder(),

                    suffixIcon:
                        Icon(Icons.calendar_today),

                  ),

                  child: Text(

                    selectedAssessmentDate == null

                        ? "Select Date"

                        : "${selectedAssessmentDate!.day.toString().padLeft(2, '0')}-"
                          "${selectedAssessmentDate!.month.toString().padLeft(2, '0')}-"
                          "${selectedAssessmentDate!.year}",

                  ),

                ),

              ),

              const SizedBox(height: 16),

              //====================================
              // ACADEMIC YEAR
              //====================================

              DropdownButtonFormField<String>(

                initialValue: selectedAcademicYear,

                decoration: const InputDecoration(

                  labelText: "Academic Year",

                  border: OutlineInputBorder(),

                ),

                items: academicYears.map((year) {

                  return DropdownMenuItem<String>(

                    value: year,

                    child: Text(year),

                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedAcademicYear = value;

                  });

                },

              ),

              const SizedBox(height: 20),
                            //====================================
              // MAXIMUM MARKS
              //====================================

              TextField(
                controller: totalMarksController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Maximum Marks",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              //====================================
              // OBTAINED MARKS
              //====================================

              TextField(
                controller: obtainedMarksController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Obtained Marks",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              //====================================
              // TEACHER REMARKS
              //====================================

              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Teacher Remarks",
                  hintText: "Optional",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              //====================================
              // SAVE BUTTON
              //====================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveMarks,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isLoading ? "Saving..." : "Save Marks",
                  ),
                ),
              ),

              const SizedBox(height: 20),
          
             ],
             if (selectedPage == "View Marks") ...[
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "View Student Marks",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      // ==========================================
      // CLASS
      // ==========================================

      DropdownButtonFormField<String>(
        initialValue: selectedClass,
        decoration: const InputDecoration(
          labelText: "Class",
          border: OutlineInputBorder(),
        ),
        items: availableClasses.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text("Class $item"),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedClass = value;
            selectedSection = null;
            viewMarks = [];
          });
        },
      ),

      const SizedBox(height: 16),

      // ==========================================
      // SECTION
      // ==========================================

      DropdownButtonFormField<String>(
        initialValue: selectedSection,
        decoration: const InputDecoration(
          labelText: "Section",
          border: OutlineInputBorder(),
        ),
        items: availableSections.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSection = value;
            viewMarks = [];
          });
        },
      ),

      const SizedBox(height: 20),

      // ==========================================
      // LOAD MARKS BUTTON
      // ==========================================

      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : loadViewMarks,
          icon: const Icon(Icons.visibility),
          label: Text(
            isLoading ? "Loading..." : "View Marks",
          ),
        ),
      ),

      const SizedBox(height: 25),

      // ==========================================
      // NO MARKS
      // ==========================================

      if (!isLoading && viewMarks.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "No marks found for the selected class and section.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

      // ==========================================
      // MARKS LIST
      // ==========================================

      if (viewMarks.isNotEmpty)
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _groupMarksByStudent().length,
    itemBuilder: (context, index) {
      final student = _groupMarksByStudent()[index];

      final String studentName =
          student["student_name"] ?? "Unknown Student";

      final String rollNo =
          student["roll_no"] ?? "-";

      final List marks =
          student["marks"] ?? [];

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ======================================
              // STUDENT HEADER
              // ======================================

              Row(
                children: [

                  const Icon(
                    Icons.person,
                    size: 30,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    "Roll No: $rollNo",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(height: 25),

              // ======================================
              // NO MARKS
              // ======================================

              if (marks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [

                      Icon(
                        Icons.pending_actions,
                        color: Colors.orange,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Marks Not Entered",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // ======================================
              // MARKS
              // ======================================

              if (marks.isNotEmpty)
                ...marks.map<Widget>((mark) {

                  final subject =
                      mark["subject"]?.toString() ?? "-";

                  final assessmentName =
                      mark["assessment_name"]?.toString() ?? "-";

                  final assessmentType =
                      mark["assessment_type"]?.toString() ?? "-";

                  final marksObtained =
                      mark["marks_obtained"]?.toString() ?? "0";

                  final totalMarks =
                      mark["total_marks"]?.toString() ?? "0";

                  final assessmentDate =
                      mark["assessment_date"]?.toString() ?? "-";

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _markRow(
                          "Assessment",
                          assessmentName,
                        ),

                        _markRow(
                          "Type",
                          assessmentType,
                        ),

                        _markRow(
                          "Date",
                          assessmentDate,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            const Text(
                              "Marks",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              "$marksObtained / $totalMarks",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      );
    },
  ),
    ],
  ),
],
             
              ]
  
          ),
        ),
      ),
    );
  }
}