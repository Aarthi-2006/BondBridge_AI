import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
class MarksScreen extends StatefulWidget {
  const MarksScreen({
    super.key,
    this.initialPage = "Management",
  });

  final String initialPage;

  static const Color primaryBlue = Color(0xff1F4FB8);

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  // ===========================================================
  // CLASS / SECTION / STUDENT DATA
  // ===========================================================

  String? selectedClass;
  String? selectedSection;
  int? selectedStudentId;

  List<dynamic> students = [];

  bool isLoadingStudents = false;
  int? actualStudentId;
  // ===========================================================
// TEACHER ASSIGNED CLASSES
// ===========================================================

List<Map<String, String>> assignedClasses = [];
bool isLoadingAssignedClasses = false;
  // ===========================================================
// VIEW MARKS DATA
// ===========================================================

List<dynamic> viewMarks = [];

bool isLoadingMarks = false;
bool marksLoaded = false;

  // ===========================================================
  // ASSESSMENT
  // ===========================================================

  String selectedAssessment = "Monthly Test";
  String? selectedMonth;
  String selectedCategory = "Academic";
  String selectedViewCategory = "Academic";

final List<String> assessmentCategories = [
  "Academic",
  "Extracurricular",
];

final List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];
String? selectedActivityCategory;
String? selectedActivity;
String? selectedAchievement;
String? selectedLevel;

final List<String> activityCategories = [
  "Sports",
  "Dance",
  "Singing",
  "Drawing",
  "Speech Competition",
];

final List<String> sportsActivities = [
  "Volleyball",
  "Football",
  "Running Race",
];

final List<String> achievements = [
  "Participated",
  "First Prize",
  "Second Prize",
  "Third Prize",
  "Selected for Next Level",
];

final List<String> levels = [
  "Class",
  "School",
  "District",
  "State",
  "National",
];
  // ===========================================================
  // SUBJECTS
  // ===========================================================

  List<String> get subjects {
  final classNumber = int.tryParse(selectedClass ?? "");

  if (classNumber != null && classNumber >= 11) {
    return [
      "Tamil",
      "English",
      "Mathematics",
      "Biology",
      "Chemistry",
      "Physics",
    ];
  }

  return [
    "Tamil",
    "English",
    "Mathematics",
    "Science",
    "Social Science",
  ];
}

  // ===========================================================
  // MARK CONTROLLERS
  // ===========================================================

  final Map<String, TextEditingController> markControllers = {};

  @override
void initState() {
  super.initState();

  _loadAssignedClasses();
  _loadActualStudentId();
}
void _initializeMarkControllers() {
  for (final subject in subjects) {
    if (!markControllers.containsKey(subject)) {
      markControllers[subject] = TextEditingController();
    }
  }
}

Future<void> _loadActualStudentId() async {
  try {
    final result = await ApiService.getStudents();

    if (result.isEmpty || Session.userId == null) {
      return;
    }

    final student = result.firstWhere(
      (item) => item["user_id"].toString() == Session.userId.toString(),
      orElse: () => null,
    );

    if (student != null) {
      setState(() {
        actualStudentId =
            int.tryParse(student["student_id"].toString());
      });
      debugPrint("Actual Student ID: $actualStudentId");
    }
  } catch (e) {
    debugPrint("Error loading student ID: $e");
  }
}
  @override
  void dispose() {
    for (final controller in markControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // ENTER MARKS
    // =========================================================

    if (widget.initialPage == "Enter Marks") {
      return _buildEnterMarksPage(context);
    }

    // =========================================================
    // VIEW MARKS
    // =========================================================

    if (widget.initialPage == "View Marks") {
  if (Session.role?.toLowerCase() == "student") {
    return _buildStudentViewMarksPage(context);
  }

  return _buildViewMarksPage(context);
}

    // =========================================================
    // MANAGEMENT
    // =========================================================

    return _buildManagementPage(context);
  }

  // ===========================================================
  // MANAGEMENT PAGE
  // ===========================================================

  Widget _buildManagementPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: MarksScreen.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Marks Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Manage Student Marks",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter new marks or view previously entered marks.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // ENTER MARKS
              // =================================================

              _buildManagementCard(
                context: context,
                icon: Icons.edit_note,
                title: "Enter Marks",
                subtitle: "Enter and manage student marks",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarksScreen(
                        initialPage: "Enter Marks",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // =================================================
              // VIEW MARKS
              // =================================================

              _buildManagementCard(
                context: context,
                icon: Icons.visibility_outlined,
                title: "View Marks",
                subtitle: "View student marks and performance",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarksScreen(
                        initialPage: "View Marks",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // ENTER MARKS PAGE
  // ===========================================================

  Widget _buildEnterMarksPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: MarksScreen.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Enter Marks",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // TITLE
              // =================================================

              const Text(
                "Enter Student Marks",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Select class and section, then load the students.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // CLASS + SECTION
              // =================================================

             Column(
  children: [
    _buildDropdownField(
      label: "Class",
      hint: "Select Class",
      value: selectedClass,
      items: assignedClasses
          .map((item) => item["class"]!)
          .toSet()
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedClass = value;
          selectedSection = null;
          selectedStudentId = null;
          students = [];

          _initializeMarkControllers();
        });
      },
    ),

    const SizedBox(height: 15),

    _buildDropdownField(
      label: "Section",
      hint: selectedClass == null
          ? "Select Class First"
          : "Select Section",
      value: selectedSection,
      items: assignedClasses
          .where(
            (item) => item["class"] == selectedClass,
          )
          .map((item) => item["section"]!)
          .toSet()
          .toList(),
      onChanged: selectedClass == null
          ? (_) {}
          : (value) {
              setState(() {
                selectedSection = value;
                selectedStudentId = null;
                students = [];
              });
            },
    ),
  ],
),

              const SizedBox(height: 20),

              // =================================================
              // LOAD STUDENTS
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: isLoadingStudents
                      ? null
                      : _loadStudents,

                  icon: isLoadingStudents
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.people_alt_outlined,
                        ),

                  label: Text(
                    isLoadingStudents
                        ? "Loading Students..."
                        : "Load Students",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarksScreen.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        MarksScreen.primaryBlue.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // STUDENT DROPDOWN
              // =================================================

              _buildStudentDropdown(),

              const SizedBox(height: 30),

              // =================================================
              // ASSESSMENT
              // =================================================

              
_buildDropdownField(
  label: "Assessment Category",
  hint: "Select Category",
  value: selectedCategory,
  items: assessmentCategories,
  onChanged: (value) {
    setState(() {
      selectedCategory = value!;

      if (selectedCategory == "Extracurricular") {
        selectedMonth = null;
      }
    });
  },
),

if (selectedCategory == "Academic") ...[
  const SizedBox(height: 15),

  Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _buildAssessmentButton("Monthly Test"),
      _buildAssessmentButton("Quarterly"),
      _buildAssessmentButton("Half Yearly"),
      _buildAssessmentButton("Annual"),
    ],
  ),
],
if (selectedCategory == "Academic" &&
    selectedAssessment == "Monthly Test") ...[
        const SizedBox(height: 15),

  _buildDropdownField(
    label: "Month",
    hint: "Select Month",
    value: selectedMonth,
    items: months,
    onChanged: (value) {
      setState(() {
        selectedMonth = value;
      });
    },
  ),
],
              if (selectedCategory == "Extracurricular") ...[
  const SizedBox(height: 20),

  _buildDropdownField(
    label: "Activity Category",
    hint: "Select Category",
    value: selectedActivityCategory,
    items: activityCategories,
    onChanged: (value) {
      setState(() {
        selectedActivityCategory = value!;
        selectedActivity = null;
      });
    },
  ),

  if (selectedActivityCategory == "Sports") ...[
    const SizedBox(height: 15),

    _buildDropdownField(
      label: "Activity",
      hint: "Select Activity",
      value: selectedActivity,
      items: sportsActivities,
      onChanged: (value) {
        setState(() {
          selectedActivity = value;
        });
      },
    ),
  ],

  const SizedBox(height: 15),

  _buildDropdownField(
    label: "Achievement",
    hint: "Select Achievement",
    value: selectedAchievement,
    items: achievements,
    onChanged: (value) {
      setState(() {
        selectedAchievement = value;
      });
    },
  ),

  const SizedBox(height: 15),

  _buildDropdownField(
    label: "Level",
    hint: "Select Level",
    value: selectedLevel,
    items: levels,
    onChanged: (value) {
      setState(() {
        selectedLevel = value;
      });
    },
  ),
],

const SizedBox(height: 30),
if (selectedCategory == "Academic") ...[

// =================================================
// SUBJECT MARKS
// =================================================

              const Text(
                "Subject Marks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 15),

              ...subjects.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSubjectMarkField(subject),
                ),
              ),
],
              const SizedBox(height: 13),

              // =================================================
              // SAVE
              // =================================================

              SizedBox(
  width: double.infinity,
  height: 52,

  child: ElevatedButton.icon(
    onPressed: _saveMarks,

    icon: const Icon(Icons.save_outlined),

    label: const Text(
      "Save Marks",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    style: ElevatedButton.styleFrom(
      backgroundColor: MarksScreen.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

// ===========================================================
// LOAD TEACHER ASSIGNED CLASSES
// ===========================================================

Future<void> _loadAssignedClasses() async {
  if (Session.teacherId == null) {
    return;
  }

  setState(() {
    isLoadingAssignedClasses = true;
  });

  try {
    final result = await ApiService.getTeacherClasses(
      Session.teacherId!,
    );

    if (!mounted) return;

    final List<Map<String, String>> loadedClasses = [];

    for (final item in result) {
      if (item is Map<String, dynamic>) {
        final className =
            item["class"]?.toString() ??
            item["class_name"]?.toString() ??
            "";

        final section =
            item["section"]?.toString() ?? "";

        if (className.isNotEmpty && section.isNotEmpty) {
          loadedClasses.add({
            "class": className,
            "section": section,
          });
        }
      }
    }

    setState(() {
      assignedClasses = loadedClasses;
      isLoadingAssignedClasses = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoadingAssignedClasses = false;
      assignedClasses = [];
    });

    _showMessage(
      "Unable to load your assigned classes.",
    );
  }
}
  // ===========================================================
  // LOAD REAL STUDENTS
  // ===========================================================

  Future<void> _loadStudents() async {
    if (selectedClass == null || selectedSection == null) {
      _showMessage(
        "Please select Class and Section first.",
      );
      return;
    }

    setState(() {
      isLoadingStudents = true;
      students = [];
      selectedStudentId = null;
    });

    try {
      final result = await ApiService.getStudents(
        studentClass: selectedClass,
        section: selectedSection,

      );

      if (!mounted) return;

      setState(() {
        students = result;
        isLoadingStudents = false;
      });

      if (students.isEmpty) {
        _showMessage(
          "No students found for Class $selectedClass - Section $selectedSection.",
        );
      } else {
        _showMessage(
          "${students.length} student(s) loaded.",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingStudents = false;
      });

      _showMessage(
        "Unable to load students.",
      );
    }
  }

// ===========================================================
// LOAD MARKS
// ===========================================================

Future<void> _loadMarks() async {
    // ===========================================================
  // STUDENT VIEW MARKS
  // ===========================================================

if (Session.role?.toLowerCase() == "student") {
      if (Session.userId == null) {
      _showMessage(
        "Student session not found. Please login again.",
      );
      return;
    }

    if (selectedViewCategory == "Academic" &&
        selectedAssessment == "Monthly Test" &&
        selectedMonth == null) {
      _showMessage(
        "Please select the month for Monthly Test.",
      );
      return;
    }

    setState(() {
      isLoadingMarks = true;
      marksLoaded = false;
      viewMarks = [];
    });

    try {
      final result = await ApiService.getMarks(
studentId: actualStudentId,
        assessmentType:
            selectedViewCategory == "Academic"
                ? selectedAssessment
                : null,
        assessmentCategory: selectedViewCategory,
        month: selectedViewCategory == "Academic" &&
                selectedAssessment == "Monthly Test"
            ? selectedMonth
            : null,
      );

      if (!mounted) return;

      setState(() {
        viewMarks = result;
        isLoadingMarks = false;
        marksLoaded = true;
      });

      if (viewMarks.isEmpty) {
        _showMessage(
          "No marks found for this assessment.",
        );
      } else {
        _showMessage(
          "${viewMarks.length} mark record(s) loaded.",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMarks = false;
        marksLoaded = true;
        viewMarks = [];
      });

      _showMessage(
        "Unable to load your marks.",
      );
    }

    return;
  }
  if (selectedStudentId == null) {
  _showMessage(
    "Please select a student.",
  );
  return;
}
  if (selectedClass == null) {
    _showMessage(
      "Please select a class.",
    );
    return;
  }

  if (selectedSection == null) {
    _showMessage(
      "Please select a section.",
    );
    return;
  }
  if (selectedViewCategory == "Academic" &&
    selectedAssessment == "Monthly Test" &&
    selectedMonth == null) {
  _showMessage(
    "Please select the month for Monthly Test.",
  );
  return;
}
  setState(() {
    isLoadingMarks = true;
    marksLoaded = false;
    viewMarks = [];
  });

  try {
    final result = await ApiService.getMarks(
  studentClass: selectedClass!,
  section: selectedSection!,
  studentId: selectedStudentId!,
  assessmentType: selectedViewCategory == "Academic"
      ? selectedAssessment
      : null,
  assessmentCategory: selectedViewCategory,
  month: selectedViewCategory == "Academic" &&
          selectedAssessment == "Monthly Test"
      ? selectedMonth
      : null,
  teacherId: Session.teacherId,
);

    if (!mounted) return;

    setState(() {
      viewMarks = result;
      isLoadingMarks = false;
      marksLoaded = true;
    });

    if (viewMarks.isEmpty) {
      _showMessage(
        "No marks found for Class $selectedClass - Section $selectedSection.",
      );
    } else {
      _showMessage(
        "${viewMarks.length} mark record(s) loaded.",
      );
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoadingMarks = false;
      marksLoaded = true;
      viewMarks = [];
    });

    _showMessage(
      "Unable to load marks.",
    );
  }
}
  // ===========================================================
// SAVE MARKS
// ===========================================================

// ===========================================================
// SAVE MARKS
// ===========================================================

Future<void> _saveMarks() async {
  // ---------------------------------------------------------
  // CHECK CLASS
  // ---------------------------------------------------------

  if (selectedClass == null) {
    _showMessage(
      "Please select a class.",
    );
    return;
  }

  // ---------------------------------------------------------
  // CHECK SECTION
  // ---------------------------------------------------------

  if (selectedSection == null) {
    _showMessage(
      "Please select a section.",
    );
    return;
  }

  // ---------------------------------------------------------
  // CHECK STUDENT
  // ---------------------------------------------------------

  if (selectedStudentId == null) {
    _showMessage(
      "Please select a student.",
    );
    return;
  }
  if (selectedCategory == "Academic" &&
    selectedAssessment == "Monthly Test" &&
    selectedMonth == null) {
  _showMessage(
    "Please select the month for Monthly Test.",
  );
  return;
}
  // ---------------------------------------------------------
  // CHECK TEACHER
  // ---------------------------------------------------------

  if (Session.teacherId == null) {
    _showMessage(
      "Teacher session not found. Please login again.",
    );
    return;
  }

  // ---------------------------------------------------------
  // CHECK ALL SUBJECT MARKS
  // ---------------------------------------------------------

  // ---------------------------------------------------------
// EXTRACURRICULAR VALIDATION
// ---------------------------------------------------------

if (selectedCategory == "Extracurricular") {
  if (selectedActivityCategory == null) {
    _showMessage("Please select an activity category.");
    return;
  }

  if (selectedActivityCategory == "Sports" &&
      selectedActivity == null) {
    _showMessage("Please select a sports activity.");
    return;
  }

  if (selectedAchievement == null) {
    _showMessage("Please select an achievement.");
    return;
  }

  if (selectedLevel == null) {
    _showMessage("Please select a level.");
    return;
  }

  // ---------------------------------------------------------
  // SHOW LOADING
  // ---------------------------------------------------------

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    await ApiService.addMarks(
      studentId: selectedStudentId!,
      teacherId: Session.teacherId!,
      subject: selectedActivity ?? selectedActivityCategory!,
assessmentType: "Extracurricular",
      assessmentCategory: "Extracurricular",
      assessmentName: selectedActivity ?? selectedActivityCategory!,
      assessmentDate:
          DateTime.now().toIso8601String().split("T").first,
      academicYear:
          "${DateTime.now().year}-${DateTime.now().year + 1}",
      month: null,

      // Extracurricular records don't contain academic marks.
      marksObtained: null,
      totalMarks: null,
      teacherRemarks: null,

      // Extracurricular details
      activityCategory: selectedActivityCategory,
      activity: selectedActivity,
      achievement: selectedAchievement,
      level: selectedLevel,
    );

    if (!mounted) return;

    Navigator.pop(context);

    _showMessage(
      "Extracurricular activity saved successfully.",
    );

    setState(() {
      selectedActivityCategory = null;
      selectedActivity = null;
      selectedAchievement = null;
      selectedLevel = null;
    });
  } catch (e) {
    if (!mounted) return;

    Navigator.pop(context);

    _showMessage(
      "Failed to save extracurricular activity. Please try again.",
    );
  }

  return;
}

// ---------------------------------------------------------
// ACADEMIC MARK VALIDATION
// ---------------------------------------------------------

final Map<String, double> enteredMarks = {};

for (final subject in subjects) {
  final text = markControllers[subject]!.text.trim();

  if (text.isEmpty) {
    _showMessage(
      "Please enter marks for $subject.",
    );
    return;
  }

  final double? mark = double.tryParse(text);

  if (mark == null) {
    _showMessage(
      "Please enter a valid number for $subject.",
    );
    return;
  }

  if (mark < 0 || mark > 100) {
    _showMessage(
      "$subject marks must be between 0 and 100.",
    );
    return;
  }

  enteredMarks[subject] = mark;
}

  // ---------------------------------------------------------
  // SHOW LOADING
  // ---------------------------------------------------------

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    int savedCount = 0;

    // -------------------------------------------------------
    // SAVE ALL SIX SUBJECTS
    // -------------------------------------------------------

    for (final subject in subjects) {
      final double marksObtained = enteredMarks[subject]!;

      await ApiService.addMarks(
        studentId: selectedStudentId!,
        teacherId: Session.teacherId!,
        subject: subject,

        // Example:
        // Monthly
        // Quarterly
        // Half Yearly
        // Annual
assessmentType: selectedAssessment,        // This represents that these are exam marks.
        assessmentCategory: "Academic",

        // Example:
        // Monthly
        // Quarterly
        // Half Yearly
        // Annual
assessmentName: selectedAssessment == "Monthly Test"
        ? "$selectedMonth Monthly Test"
        : selectedAssessment,

        assessmentDate:
            DateTime.now().toIso8601String().split("T").first,

        academicYear:
            "${DateTime.now().year}-${DateTime.now().year + 1}",
        month: selectedAssessment == "Monthly Test"
    ? selectedMonth
    : null,

        marksObtained: marksObtained,

        // Every subject is currently out of 100.
        totalMarks: 100,

        teacherRemarks: null,
      );

      savedCount++;
    }

    // -------------------------------------------------------
    // CLOSE LOADING
    // -------------------------------------------------------

    if (!mounted) return;

    Navigator.pop(context);

    // -------------------------------------------------------
    // SUCCESS MESSAGE
    // -------------------------------------------------------

    _showMessage(
      "$selectedAssessment marks saved successfully for all $savedCount subjects.",
    );

    // -------------------------------------------------------
    // CLEAR MARKS
    // -------------------------------------------------------

    setState(() {
      for (final controller in markControllers.values) {
        controller.clear();
      }
    });
  } catch (e) {
    // -------------------------------------------------------
    // CLOSE LOADING
    // -------------------------------------------------------

    if (!mounted) return;

    Navigator.pop(context);

    _showMessage(
      "Failed to save $selectedAssessment marks. Please try again.",
    );
  }
}

  // ===========================================================
  // STUDENT DROPDOWN
  // ===========================================================

  Widget _buildStudentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Student",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<int>(
          initialValue: selectedStudentId,

          decoration: InputDecoration(
            hintText: students.isEmpty
                ? "Load students first"
                : "Select Student",

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: MarksScreen.primaryBlue,
                width: 2,
              ),
            ),
          ),

          items: students.map<DropdownMenuItem<int>>((student) {
            final int id = _getStudentId(student);
            final String name = _getStudentName(student);

            return DropdownMenuItem<int>(
              value: id,
              child: Text(name),
            );
          }).toList(),

          onChanged: students.isEmpty
              ? null
              : (value) {
                  setState(() {
                    selectedStudentId = value;
                  });
                },
        ),
      ],
    );
  }

  // ===========================================================
  // GET STUDENT ID
  // ===========================================================

  int _getStudentId(dynamic student) {
    if (student is Map<String, dynamic>) {
      return int.tryParse(
            student["student_id"]?.toString() ?? "",
          ) ??
          int.tryParse(
            student["id"]?.toString() ?? "",
          ) ??
          0;
    }

    return 0;
  }

  // ===========================================================
  // GET STUDENT NAME
  // ===========================================================

  String _getStudentName(dynamic student) {
    if (student is Map<String, dynamic>) {
      return student["full_name"]?.toString() ??
          student["name"]?.toString() ??
          "Student";
    }

    return "Student";
  }

  // ===========================================================
  // DROPDOWN FIELD
  // ===========================================================

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: value,

          decoration: InputDecoration(
            hintText: hint,

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: MarksScreen.primaryBlue,
                width: 2,
              ),
            ),
          ),

          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }

  // ===========================================================
  // ASSESSMENT BUTTON
  // ===========================================================

  Widget _buildAssessmentButton(String title) {
  final String assessmentValue = title;
  final bool selected = selectedAssessment == assessmentValue;

  return InkWell(
    borderRadius: BorderRadius.circular(10),

    onTap: () {
      setState(() {
        selectedAssessment = assessmentValue;

        // Clear month when switching away from Monthly
        if (assessmentValue != "Monthly Test") {
          selectedMonth = null;
        }
      });
    },

    child: Container(
      decoration: BoxDecoration(
        color: selected
            ? MarksScreen.primaryBlue
            : Colors.white,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: selected
              ? MarksScreen.primaryBlue
              : Colors.grey.shade300,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black87,

            fontSize: 14,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

  // ===========================================================
// VIEW ASSESSMENT BUTTON
// ===========================================================

Widget _buildViewAssessmentButton(String title) {
  final String assessmentValue = title;
  final bool selected = selectedAssessment == assessmentValue;

  return InkWell(
    borderRadius: BorderRadius.circular(10),

    onTap: () {
      setState(() {
        selectedAssessment = assessmentValue;

        viewMarks = [];
        marksLoaded = false;

        if (assessmentValue != "Monthly Test") {
          selectedMonth = null;
        }
      });
    },

    child: Container(
      decoration: BoxDecoration(
        color: selected
            ? MarksScreen.primaryBlue
            : Colors.white,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: selected
              ? MarksScreen.primaryBlue
              : Colors.grey.shade300,
        ),
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),

      child: Text(
        title,
        style: TextStyle(
          color: selected
              ? Colors.white
              : Colors.black87,

          fontSize: 14,

          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
  // ===========================================================
  // SUBJECT MARK FIELD
  // ===========================================================

  Widget _buildSubjectMarkField(String subject) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              subject,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(
            width: 100,

            child: TextField(
              controller: markControllers[subject],
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: "Marks",

                filled: true,
                fillColor: const Color(0xffF5F7FB),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // VIEW MARKS PAGE
  // ===========================================================
Widget _buildStudentViewMarksPage(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xffF5F7FB),

    appBar: AppBar(
      backgroundColor: MarksScreen.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      title: const Text(
        "My Marks",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "My Marks",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select an assessment to view your marks.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // ASSESSMENT CATEGORY
            // =================================================

            _buildDropdownField(
  label: "Assessment Category",
  hint: "Select Category",
  value: selectedViewCategory,
  items: assessmentCategories,
  onChanged: (value) {
    setState(() {
      selectedViewCategory = value!;

      viewMarks = [];
      marksLoaded = false;

      if (selectedViewCategory == "Extracurricular") {
        selectedAssessment = "Monthly Test";
        selectedMonth = null;
      }
    });
  },
),

            // =================================================
            // ACADEMIC ASSESSMENT TYPE
            // =================================================

            if (selectedViewCategory == "Academic") ...[
              const SizedBox(height: 20),

              const Text(
                "Assessment Type",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildViewAssessmentButton("Monthly Test"),
                  _buildViewAssessmentButton("Quarterly"),
                  _buildViewAssessmentButton("Half Yearly"),
                  _buildViewAssessmentButton("Annual"),
                ],
              ),
            ],

            // =================================================
            // MONTH
            // =================================================

            if (selectedViewCategory == "Academic" &&
                selectedAssessment == "Monthly Test") ...[
              const SizedBox(height: 15),

              _buildDropdownField(
                label: "Month",
                hint: "Select Month",
                value: selectedMonth,
                items: months,
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value;
                    viewMarks = [];
                    marksLoaded = false;
                  });
                },
              ),
            ],

            const SizedBox(height: 25),

            // =================================================
            // VIEW MY MARKS
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: isLoadingMarks
                    ? null
                    : _loadMarks,

                icon: isLoadingMarks
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                      ),

                label: Text(
                  isLoadingMarks
                      ? "Loading Marks..."
                      : "View My Marks",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      MarksScreen.primaryBlue,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // MARKS RESULT
            // =================================================

            if (viewMarks.isNotEmpty)
              _buildMarksResult(),

            // =================================================
            // NO DATA
            // =================================================

            if (marksLoaded && viewMarks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: const Column(
                  children: [

                    Icon(
                      Icons.assignment_outlined,
                      size: 45,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "No marks found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "No marks have been recorded for this assessment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
  // ===========================================================
// VIEW MARKS PAGE
// ===========================================================

Widget _buildViewMarksPage(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xffF5F7FB),

    appBar: AppBar(
      backgroundColor: MarksScreen.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      title: const Text(
        "View Marks",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "View Student Marks",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select class and section to view entered marks.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // CLASS + SECTION
            // =================================================

            // =================================================
// CLASS + SECTION
// =================================================

Column(
  children: [
    _buildDropdownField(
      label: "Class",
      hint: isLoadingAssignedClasses
          ? "Loading Classes..."
          : "Select Class",
      value: selectedClass,
      items: assignedClasses
          .map((item) => item["class"]!)
          .toSet()
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedClass = value;
          selectedSection = null;
          selectedStudentId = null;
students = [];
          viewMarks = [];
          marksLoaded = false;
        });
      },
    ),

    const SizedBox(height: 15),

    _buildDropdownField(
      label: "Section",
      hint: selectedClass == null
          ? "Select Class First"
          : "Select Section",
      value: selectedSection,
      items: assignedClasses
          .where(
            (item) => item["class"] == selectedClass,
          )
          .map((item) => item["section"]!)
          .toSet()
          .toList(),
      onChanged: selectedClass == null
    ? (_) {}
    : (value) {
        setState(() {
          selectedSection = value;
          selectedStudentId = null;
          students = [];
          viewMarks = [];
          marksLoaded = false;
        });
      },
    ),
  ],
),

const SizedBox(height: 20),

// =================================================
// LOAD STUDENTS
// =================================================

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: isLoadingStudents
        ? null
        : _loadStudents,

    icon: isLoadingStudents
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.people_alt_outlined),

    label: Text(
      isLoadingStudents
          ? "Loading Students..."
          : "Load Students",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    style: ElevatedButton.styleFrom(
      backgroundColor: MarksScreen.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

const SizedBox(height: 20),

// =================================================
// STUDENT
// =================================================

_buildStudentDropdown(),
            const SizedBox(height: 20),

            // =================================================
            // LOAD MARKS BUTTON
            // =================================================


_buildDropdownField(
  label: "Assessment Category",
  hint: "Select Category",
  value: selectedViewCategory,
  items: assessmentCategories,
  onChanged: (value) {
    setState(() {
      selectedViewCategory = value!;

      viewMarks = [];
      marksLoaded = false;

      if (selectedViewCategory == "Extracurricular") {
        selectedMonth = null;
      }
    });
  },
),

if (selectedViewCategory == "Academic") ...[
  const SizedBox(height: 15),

  const Text(
    "Assessment",
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),

  const SizedBox(height: 12),

  Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _buildViewAssessmentButton("Monthly Test"),
      _buildViewAssessmentButton("Quarterly"),
      _buildViewAssessmentButton("Half Yearly"),
      _buildViewAssessmentButton("Annual"),
    ],
  ),
],

if (selectedViewCategory == "Academic" &&
    selectedAssessment == "Monthly Test") ...[
  const SizedBox(height: 15),

  _buildDropdownField(
    label: "Month",
    hint: "Select Month",
    value: selectedMonth,
    items: months,
    onChanged: (value) {
      setState(() {
        selectedMonth = value;
        viewMarks = [];
        marksLoaded = false;
      });
    },
  ),
],

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: isLoadingMarks ? null : _loadMarks,

    icon: isLoadingMarks
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.visibility_outlined),

    label: Text(
      isLoadingMarks
          ? "Loading Marks..."
          : "Load Marks",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    style: ElevatedButton.styleFrom(
      backgroundColor: MarksScreen.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

            const SizedBox(height: 25),

            // =================================================
            // MARKS RESULT
            // =================================================

            if (viewMarks.isNotEmpty)
                _buildMarksResult(),

            if (marksLoaded && viewMarks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: const Column(
                  children: [

                    Icon(
                      Icons.assignment_outlined,
                      size: 45,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "No marks found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "No marks have been entered for this class and section.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
// ===========================================================
// MARKS RESULT
// ===========================================================

Widget _buildMarksResult() {
  // =========================================================
  // GROUP ALL RECORDS BY STUDENT
  // =========================================================

  final Map<String, List<dynamic>> recordsByStudent = {};

  for (final record in viewMarks) {
    if (record is Map<String, dynamic>) {
      final studentId =
          record["student_id"]?.toString() ?? "";

      if (studentId.isNotEmpty) {
        recordsByStudent.putIfAbsent(
          studentId,
          () => [],
        );

        recordsByStudent[studentId]!.add(record);
      }
    }
  }

  if (recordsByStudent.isEmpty) {
    return const SizedBox();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Student Marks",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 12),

      // =======================================================
      // EACH STUDENT
      // =======================================================

      ...recordsByStudent.entries.map(
        (entry) {
          final studentRecords = entry.value;

          final firstRecord = studentRecords.first;

          final studentName =
              firstRecord is Map<String, dynamic>
                  ? firstRecord["student_name"]?.toString() ??
                      "Student"
                  : "Student";

          // ===================================================
          // SEPARATE ACADEMIC + EXTRACURRICULAR
          // ===================================================

          final academicRecords = studentRecords.where((record) {
            if (record is Map<String, dynamic>) {
              return record["assessment_category"]
                      ?.toString()
                      .toLowerCase() ==
                  "academic";
            }

            return false;
          }).toList();

          final extracurricularRecords =
              studentRecords.where((record) {
            if (record is Map<String, dynamic>) {
              return record["assessment_category"]
                      ?.toString()
                      .toLowerCase() ==
                  "extracurricular";
            }

            return false;
          }).toList();

          // ===================================================
          // ACADEMIC MARKS
          // ===================================================

          double totalObtained = 0;
          double totalMaximum = 0;

          final Map<String, dynamic> marksBySubject = {};

          for (final record in academicRecords) {
            if (record is Map<String, dynamic>) {
              final subject =
                  record["subject"]?.toString() ?? "";

              if (subject.isNotEmpty) {
                marksBySubject[subject] = record;
              }

              final obtained =
                  double.tryParse(
                        record["marks_obtained"]
                                ?.toString() ??
                            "",
                      ) ??
                      0;

              final maximum =
                  double.tryParse(
                        record["total_marks"]
                                ?.toString() ??
                            "",
                      ) ??
                      0;

              totalObtained += obtained;
              totalMaximum += maximum;
            }
          }

          final percentage = totalMaximum > 0
              ? (totalObtained / totalMaximum) * 100
              : 0;

          String performance;

          if (percentage >= 90) {
            performance = "Excellent";
          } else if (percentage >= 75) {
            performance = "Very Good";
          } else if (percentage >= 60) {
            performance = "Good";
          } else if (percentage >= 40) {
            performance = "Average";
          } else {
            performance = "Needs Improvement";
          }

          // ===================================================
          // STUDENT CARD
          // ===================================================

          return Container(
            width: double.infinity,

            margin: const EdgeInsets.only(bottom: 14),

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =============================================
                // STUDENT NAME
                // =============================================

                Text(
                  studentName,

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Class $selectedClass - Section $selectedSection",

                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 15),

                // =============================================
                // ACADEMIC MARKS
                // =============================================

                if (selectedViewCategory == "Academic" &&
    academicRecords.isNotEmpty) ...[
                  const Text(
                    "Academic Marks",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    selectedAssessment,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MarksScreen.primaryBlue,
                    ),
                  ),

                  if (selectedAssessment == "Monthly Test" &&
                      selectedMonth != null) ...[
                    const SizedBox(height: 3),

                    Text(
                      selectedMonth!,

                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // =========================================
                  // SUBJECT MARKS
                  // =========================================

                  ...subjects.map(
                    (subject) {
                      final mark =
                          marksBySubject[subject];

                      return _buildViewSubjectCard(
                        subject: subject,
                        mark: mark,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // =========================================
                  // SUMMARY
                  // =========================================

                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FB),

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [
                        _buildSummaryRow(
                          "Total Marks",
                          "${_formatNumber(totalObtained)} / ${_formatNumber(totalMaximum)}",
                        ),

                        const Divider(height: 22),

                        _buildSummaryRow(
                          "Percentage",
                          "${percentage.toStringAsFixed(2)}%",
                        ),

                        const Divider(height: 22),

                        _buildSummaryRow(
                          "Performance",
                          performance,
                        ),
                      ],
                    ),
                  ),
                ],

                // =============================================
                // SPACE BETWEEN ACADEMIC AND EXTRA
                // =============================================

                if (academicRecords.isNotEmpty &&
                    extracurricularRecords.isNotEmpty)
                  const SizedBox(height: 18),

                // =============================================
                // EXTRACURRICULAR ACTIVITIES
                // =============================================

                if (extracurricularRecords.isNotEmpty) ...[
                  const Divider(height: 1),

                  const SizedBox(height: 15),

                  const Text(
                    "Extracurricular Activities",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...extracurricularRecords.map(
                    (record) =>
                        _buildExtracurricularCard(record),
                  ),
                ],

                // =============================================
                // NO DATA
                // =============================================

                if (academicRecords.isEmpty &&
                    extracurricularRecords.isEmpty)
                  const Text(
                    "No marks or extracurricular activities recorded.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

Widget _buildExtracurricularCard(dynamic record) {
  if (record is! Map<String, dynamic>) {
    return const SizedBox();
  }

  final activityCategory =
      record["activity_category"]?.toString() ?? "";

  final activity =
      record["activity"]?.toString() ?? "";

  final achievement =
      record["achievement"]?.toString() ?? "";

  final level =
      record["level"]?.toString() ?? "";

  final activityDate =
      record["assessment_date"]?.toString() ?? "";

  final displayActivity =
      activity.isNotEmpty ? activity : activityCategory;

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: const Color(0xffF5F7FB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Singing + Date
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 105,
              child: Text(
                displayActivity,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: Text(
                activityDate.isNotEmpty
                    ? _formatDate(activityDate)
                    : "",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // Achievement + Second Prize
        if (achievement.isNotEmpty)
          _buildActivityDetailRow(
            "Achievement",
            achievement,
          ),

        const SizedBox(height: 5),

        // Level + School
        if (level.isNotEmpty)
          _buildActivityDetailRow(
            "Level",
            level,
          ),
      ],
    ),
  );
}


Widget _buildActivityDetailRow(
  String title,
  String value,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 105,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),

      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}
String _formatDate(String date) {
  try {
    // Example input:
    // 2026-08-21
    // Fri, 21 Aug 2026 00:00:00 GMT

    int day;
    int month;
    int year;

    // -----------------------------------------------
    // Handle ISO date: 2026-08-21
    // -----------------------------------------------

    final isoMatch = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})',
    ).firstMatch(date);

    if (isoMatch != null) {
      year = int.parse(isoMatch.group(1)!);
      month = int.parse(isoMatch.group(2)!);
      day = int.parse(isoMatch.group(3)!);
    } else {

      // ---------------------------------------------
      // Handle:
      // Fri, 21 Aug 2026 00:00:00 GMT
      // ---------------------------------------------

      final httpMatch = RegExp(
        r'^[A-Za-z]{3},\s+(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})',
      ).firstMatch(date);

      if (httpMatch == null) {
        return date;
      }

      day = int.parse(httpMatch.group(1)!);
      year = int.parse(httpMatch.group(3)!);

      const monthNumbers = {
        "Jan": 1,
        "Feb": 2,
        "Mar": 3,
        "Apr": 4,
        "May": 5,
        "Jun": 6,
        "Jul": 7,
        "Aug": 8,
        "Sep": 9,
        "Oct": 10,
        "Nov": 11,
        "Dec": 12,
      };

      month = monthNumbers[httpMatch.group(2)!] ?? 1;
    }

    // -----------------------------------------------
    // Month name
    // -----------------------------------------------

    const monthNames = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    // -----------------------------------------------
    // Day suffix
    // -----------------------------------------------

    String suffix;

    if (day >= 11 && day <= 13) {
      suffix = "th";
    } else {
      switch (day % 10) {
        case 1:
          suffix = "st";
          break;
        case 2:
          suffix = "nd";
          break;
        case 3:
          suffix = "rd";
          break;
        default:
          suffix = "th";
      }
    }

    // -----------------------------------------------
    // Calculate actual weekday
    // -----------------------------------------------

    final parsedDate = DateTime(year, month, day);

    const weekdays = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    final weekday = weekdays[parsedDate.weekday - 1];

    return "$weekday, $day$suffix ${monthNames[month]} $year";
  } catch (e) {
    return date;
  }
}
// ===========================================================
// VIEW SUBJECT CARD
// ===========================================================

Widget _buildViewSubjectCard({
  required String subject,
  required dynamic mark,
}) {
  if (mark == null) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 7),

      padding: const EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 10,
),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              subject,

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const Text(
            "Not entered",

            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  final double obtained =
      double.tryParse(
            mark["marks_obtained"]?.toString() ??
                "",
          ) ??
          0;

  final double total =
      double.tryParse(
            mark["total_marks"]?.toString() ??
                "",
          ) ??
          0;

  final double percentage =
      total > 0
          ? (obtained / total) * 100
          : 0;

  return Container(
    width: double.infinity,

    margin: const EdgeInsets.only(bottom: 7),

padding: const EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 10,
),
    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(12),

      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),

    child: Row(
      children: [
        // ===================================================
        // SUBJECT
        // ===================================================

        Expanded(
          child: Text(
            subject,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        // ===================================================
        // MARKS
        // ===================================================

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              "${_formatNumber(obtained)} / ${_formatNumber(total)}",

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MarksScreen.primaryBlue,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              "${percentage.toStringAsFixed(1)}%",

              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
// ===========================================================
// SUMMARY ROW
// ===========================================================

Widget _buildSummaryRow(
  String title,
  String value,
) {
  return Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [
      Text(
        title,

        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),

      Text(
        value,

        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: MarksScreen.primaryBlue,
        ),
      ),
    ],
  );
}
// ===========================================================
// FORMAT NUMBER
// ===========================================================

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}
  // ===========================================================
  // MANAGEMENT CARD
  // ===========================================================

  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: MarksScreen.primaryBlue
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: MarksScreen.primaryBlue,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // MESSAGE
  // ===========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}