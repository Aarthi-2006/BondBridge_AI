import 'package:flutter/material.dart';

import '../services/class_permission_service.dart';
import '../services/api_service.dart';
import '../services/session.dart';
enum AIReportsMode {
  teacher,
  student,
  parent,
}
class AIReportsScreen extends StatefulWidget {
  final AIReportsMode mode;

  const AIReportsScreen({
    super.key,
    this.mode = AIReportsMode.teacher,
  });

  @override
  State<AIReportsScreen> createState() => _AIReportsScreenState();
}

class _AIReportsScreenState extends State<AIReportsScreen> {
  String? selectedClass;
  String? selectedSection;
  int? selectedStudentId;
  // =========================================================
// STUDENT AI MENU
// =========================================================

String studentAIView = "menu";
final TextEditingController _askAIController =
    TextEditingController();

bool isAskingAI = false;
String? aiAnswer;
  int? selectedReportYear;
  int? selectedMonth;
  List<String> availableClasses = [];
  List<String> availableSections = [];

  List<dynamic> students = [];

  bool isLoadingClasses = true;
bool isLoadingStudents = false;
bool isGeneratingReport = false;
Map<String, dynamic>? generatedReport;
bool reportAlreadyExists = false;
Map<String, dynamic>? reportSummary;
bool isApprovingReport = false;
bool reportApproved = false;

int? generatedReportId;

// =========================================================
// PENDING AI REPORTS
// =========================================================

List<dynamic> pendingReports = [];
bool isLoadingPendingReports = false;
// =========================================================
// VERIFIED REPORTS FOR STUDENT
// =========================================================

List<dynamic> verifiedReports = [];
bool isLoadingVerifiedReports = false;
// =========================================================
// PARENT CHILD
// =========================================================

int? parentChildStudentId;
String? parentChildName;
@override
void dispose() {
  _askAIController.dispose();
  super.dispose();
}

  @override
void initState() {
  super.initState();

  if (widget.mode == AIReportsMode.teacher) {

    _loadClasses();
    _loadPendingAIReports();

  } else if (widget.mode == AIReportsMode.student) {

    _loadVerifiedReports();

  } else if (widget.mode == AIReportsMode.parent) {

  _loadParentChild();



  }
}

  // =========================================================
  // LOAD TEACHER ASSIGNED CLASSES
  // =========================================================

  Future<void> _loadClasses() async {
    setState(() {
      isLoadingClasses = true;
    });

    await ClassPermissionService.loadPermissions();

    if (!mounted) return;

    setState(() {
      availableClasses =
          ClassPermissionService.getAvailableClasses();

      isLoadingClasses = false;
    });
  }
  // =========================================================
// CLASS CHANGED
// =========================================================

Future<void> _onClassChanged(String? className) async {
  if (className == null) return;

  setState(() {
    selectedClass = className;

    selectedSection = null;
    selectedStudentId = null;

    availableSections = [];
    students = [];

    selectedReportYear = null;
    selectedMonth = null;

    generatedReport = null;
    reportSummary = null;
    generatedReportId = null;

    reportApproved = false;
    reportAlreadyExists = false;

    isLoadingStudents = false;
  });

  // Load sections for selected class
  final sections =
      ClassPermissionService.getAvailableSections(className);

  if (!mounted) return;

  setState(() {
    availableSections = sections;
  });
}

// =========================================================
// SECTION CHANGED
// =========================================================

// =========================================================
// SECTION CHANGED
// =========================================================

Future<void> _onSectionChanged(String? section) async {
  if (section == null || selectedClass == null) return;

  setState(() {
    selectedSection = section;

    selectedStudentId = null;
    students = [];

    selectedReportYear = null;
    selectedMonth = null;

    generatedReport = null;
    reportSummary = null;
    generatedReportId = null;

    reportApproved = false;
    reportAlreadyExists = false;

    isLoadingStudents = true;
  });

  try {
    final result = await ApiService.getStudents();

    if (!mounted) return;

    // Filter students according to selected class and section
    final filteredStudents = result.where((student) {
      if (student is! Map) return false;

      final studentClass =
          student["class_name"]?.toString() ??
          student["class"]?.toString() ??
          "";

      final studentSection =
          student["section"]?.toString() ?? "";

      return studentClass == selectedClass &&
          studentSection == section;
    }).toList();

    setState(() {
      students = filteredStudents;
      isLoadingStudents = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      students = [];
      isLoadingStudents = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to load students: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  // =========================================================
// LOAD PENDING AI REPORTS
// =========================================================

Future<void> _loadPendingAIReports() async {

  if (Session.teacherId == null) {
    return;
  }

  setState(() {
    isLoadingPendingReports = true;
  });

  try {

    final reports = await ApiService.getPendingAIReports(
      teacherId: Session.teacherId!,
    );

    if (!mounted) return;

    setState(() {
      pendingReports = reports;
      isLoadingPendingReports = false;
    });

  } catch (e) {

    if (!mounted) return;

    setState(() {
      pendingReports = [];
      isLoadingPendingReports = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to load pending reports: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// =========================================================
// LOAD PARENT'S CHILD
// =========================================================

Future<void> _loadParentChild() async {

  if (Session.parentId == null) {
    return;
  }

  try {

    final children = await ApiService.getParentChildren(
      parentId: Session.parentId!,
    );

    if (!mounted) return;

    if (children.isNotEmpty) {

      final child = children.first;

      if (child is Map) {

        final studentId =
            int.tryParse(
          (child["student_id"] ?? child["id"]).toString(),
        );

       setState(() {
  parentChildStudentId = studentId;

  parentChildName =
      child["full_name"]?.toString() ??
      child["name"]?.toString() ??
      "Child";
});

// =======================================================
// LOAD CHILD'S VERIFIED AI REPORTS
// =======================================================

await _loadVerifiedReports();

      }

    } else {

      setState(() {
        parentChildStudentId = null;
        parentChildName = null;
      });

    }

  } catch (e) {

    if (!mounted) return;

    setState(() {
      parentChildStudentId = null;
      parentChildName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to load child's information: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// =========================================================
// LOAD VERIFIED AI REPORTS
// =========================================================

Future<void> _loadVerifiedReports() async {

  int? studentId;

  // =======================================================
  // STUDENT MODE
  // =======================================================

  if (widget.mode == AIReportsMode.student) {

    studentId = Session.studentId;

  }

  // =======================================================
  // PARENT MODE
  // =======================================================

  else if (widget.mode == AIReportsMode.parent) {

    studentId = parentChildStudentId;

  }

  // =======================================================
  // VALIDATE STUDENT ID
  // =======================================================

  if (studentId == null) {

    if (!mounted) return;

    setState(() {
      verifiedReports = [];
      isLoadingVerifiedReports = false;
    });

    return;
  }

  // =======================================================
  // START LOADING
  // =======================================================

  setState(() {
    isLoadingVerifiedReports = true;
  });

  try {

    final result =
        await ApiService.getStudentVerifiedAIReports(
      studentId: studentId,
    );

    if (!mounted) return;

    if (result["success"] == true) {

      setState(() {
  final reports = result["reports"];

  if (reports is List) {
  verifiedReports = reports.where((report) {
    if (report is! Map) {
      return false;
    }

    final status =
        report["status"]?.toString().trim().toLowerCase();

    // Parent/Student can see ONLY verified reports.
    return status == "verified";
  }).toList();
} else {
  verifiedReports = [];
}

  isLoadingVerifiedReports = false;
});
    } else {

      setState(() {
        verifiedReports = [];
        isLoadingVerifiedReports = false;
      });

    }

  } catch (e) {

    if (!mounted) return;

    setState(() {
      verifiedReports = [];
      isLoadingVerifiedReports = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to load AI reports: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // =========================================================
  // STUDENT SELECTED
  // =========================================================

  void _onStudentChanged(int? value) {
  setState(() {
    selectedStudentId = value;

    selectedReportYear = null;
    selectedMonth = null;

    generatedReport = null;
    reportSummary = null;
    generatedReportId = null;
    reportApproved = false;
    reportAlreadyExists = false;
  });
}
  final List<String> monthNames = [
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
List<int> get reportYears {
  final currentYear = DateTime.now().year;

  return List.generate(
    5,
    (index) => currentYear - 2 + index,
  );
}
  // =========================================================
// GENERATE AI REPORT
// =========================================================

Future<void> _generateAIReport() async {

  // =======================================================
  // VALIDATE CLASS
  // =======================================================

  if (selectedClass == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a class"),
      ),
    );
    return;
  }

  // =======================================================
  // VALIDATE SECTION
  // =======================================================

  if (selectedSection == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a section"),
      ),
    );
    return;
  }

  // =======================================================
  // VALIDATE STUDENT
  // =======================================================

  if (selectedStudentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a student"),
      ),
    );
    return;
  }

  // =======================================================
  // GET CURRENT MONTH
  // =======================================================

 // =======================================================
// VALIDATE REPORT YEAR
// =======================================================

if (selectedReportYear == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please select a report year"),
    ),
  );
  return;
}

// =======================================================
// VALIDATE REPORT MONTH
// =======================================================

if (selectedMonth == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please select a report month"),
    ),
  );
  return;
}

// =======================================================
// CREATE REPORT MONTH
// Format: YYYY-MM
// =======================================================

final month =
    "$selectedReportYear-${selectedMonth.toString().padLeft(2, '0')}";
    // =======================================================
  // CHECK IF REPORT ALREADY EXISTS
  // =======================================================

  final reportAlreadyExists =
      await _checkExistingReport(month);

  if (reportAlreadyExists) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "A report already exists for this student and month.",
        ),
        backgroundColor: Colors.orange,
      ),
    );

    return;
  }

  // =======================================================
  // START LOADING
  // =======================================================

  setState(() {
    isGeneratingReport = true;
  });

  try {

    // =====================================================
    // CALL BACKEND
    // =====================================================

    final result = await ApiService.generateAIReport(
      studentId: selectedStudentId!,
      month: month,
    );

    if (!mounted) return;

    // =====================================================
    // SUCCESS
    // =====================================================

    if (result["success"] == true) {
  setState(() {
  generatedReport = result["ai_report"];

  reportSummary = result["summary"];

  generatedReportId =
      int.tryParse(
        result["report_id"].toString(),
      );

  reportApproved = false;
});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "AI report generated successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
            await _loadPendingAIReports();

      // TODO:
      // Next step will display the generated report
      // inside this screen.

    } else {

      // ===================================================
      // BACKEND ERROR
      // ===================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ??
                "Failed to generate AI report",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error generating AI report: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );

  } finally {

    if (mounted){

    setState(() {
      isGeneratingReport = false;
    });
  }
  }
}
// =========================================================
// APPROVE AI REPORT
// =========================================================

Future<void> _approveAIReport() async {

  if (generatedReportId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Report ID not found"),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }

  if (Session.teacherId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Teacher information not found"),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }

  setState(() {
    isApprovingReport = true;
  });

  try {

    final result = await ApiService.approveAIReport(
      reportId: generatedReportId!,
      teacherId: Session.teacherId!,
    );

    if (!mounted) return;

    if (result["success"] == true) {

      setState(() {
        reportApproved = true;
      });
        await _loadPendingAIReports();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "AI report approved successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ??
                "Failed to approve report",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error approving report: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );

  } finally {

    if (!mounted) return;

    setState(() {
      isApprovingReport = false;
    });
  }
}
// =========================================================
// CHECK EXISTING AI REPORT
// =========================================================

Future<bool> _checkExistingReport(String month) async {

  if (selectedStudentId == null) {
    return false;
  }

  try {

    final result = await ApiService.getStudentAIReports(
      studentId: selectedStudentId!,
    );

    if (result["success"] != true) {
      return false;
    }

    final reports = result["reports"];

    if (reports is! List) {
      return false;
    }

    for (final report in reports) {

      if (report is! Map) {
        continue;
      }

      final reportMonth =
          report["report_month"]?.toString();

      if (reportMonth == month) {

        // =============================================
        // LOAD EXISTING REPORT INTO SCREEN
        // =============================================

        if (!mounted) return true;

        setState(() {

  reportAlreadyExists = true;

  generatedReportId =
      int.tryParse(
        report["report_id"].toString(),
      );

  reportSummary = {
    "attendance_percentage":
        report["attendance_percentage"],

    "average_marks":
        report["average_marks"],

    "homework_completion":
        report["homework_completion"],
  };

  generatedReport = {
    "strengths":
        report["strengths"] ?? "",

    "improvement_areas":
        report["improvement_areas"] ?? "",

    "ai_suggestions":
        report["ai_suggestions"] ?? "",
  };

  reportApproved =
      report["status"]?.toString() == "Verified";
});
        return true;
      }
    }

    return false;

  } catch (e) {

    debugPrint(
      "Error checking existing AI report: $e",
    );

    return false;
  }
}

  // =========================================================
  // GET STUDENT DISPLAY NAME
  // =========================================================

  String _getStudentName(dynamic student) {
    if (student is Map<String, dynamic>) {
      return student["full_name"]?.toString() ??
          student["name"]?.toString() ??
          "Unknown Student";
    }

    return "Unknown Student";
  }

  // =========================================================
  // GET STUDENT ID
  // =========================================================

  int? _getStudentId(dynamic student) {
    if (student is! Map<String, dynamic>) {
      return null;
    }

    final value =
        student["student_id"] ?? student["id"];

    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }
  Widget _buildReportSummaryCard(
  String title,
  String value,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Column(
      children: [
        Icon(
          icon,
          color: const Color(0xff1F4FB8),
          size: 26,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
  // =========================================================
  // GET PENDING REPORT STUDENT NAME
  // =========================================================

  String _getPendingReportStudentName(dynamic report) {
    if (report is! Map) {
      return "Unknown Student";
    }

    return report["student_name"]?.toString() ??
        report["full_name"]?.toString() ??
        report["name"]?.toString() ??
        "Unknown Student";
  }

  // =========================================================
  // GET PENDING REPORT MONTH
  // =========================================================

  String _getPendingReportMonth(dynamic report) {
    if (report is! Map) {
      return "Unknown Month";
    }

    return report["report_month"]?.toString() ??
        "Unknown Month";
  }

  // =========================================================
  // GET PENDING REPORT VALUE
  // =========================================================

  String _getPendingReportValue(
    dynamic report,
    String key,
  ) {
    if (report is! Map) {
      return "0";
    }

    return report[key]?.toString() ?? "0";
  }

  // =========================================================
  // PENDING REPORT CARD
  // =========================================================

  Widget _buildPendingReportCard(dynamic report) {
    final studentName =
        _getPendingReportStudentName(report);

    final reportMonth =
        _getPendingReportMonth(report);

    final attendance =
        _getPendingReportValue(
      report,
      "attendance_percentage",
    );

    final averageMarks =
        _getPendingReportValue(
      report,
      "average_marks",
    );

    final homework =
        _getPendingReportValue(
      report,
      "homework_completion",
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // =============================================
            // STUDENT NAME
            // =============================================

            Row(
              children: [
                const CircleAvatar(
                  backgroundColor:
                      Color(0xff1F4FB8),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================
            // REPORT MONTH
            // =============================================

            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: Color(0xff1F4FB8),
                ),

                const SizedBox(width: 8),

                const Text(
                  "Report Month: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Expanded(
                  child: Text(
                    reportMonth,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =============================================
            // PERFORMANCE SUMMARY
            // =============================================

            Row(
              children: [
                Expanded(
                  child: _buildReportSummaryCard(
                    "Attendance",
                    "$attendance%",
                    Icons.calendar_today,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _buildReportSummaryCard(
                    "Average Marks",
                    "$averageMarks%",
                    Icons.school,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _buildReportSummaryCard(
                    "Homework",
                    "$homework%",
                    Icons.assignment,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================
            // VIEW REPORT BUTTON
            // 2G-3 WILL IMPLEMENT THIS
            // =============================================

            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton.icon(
                onPressed: () {
  _openPendingReport(report);
},
                icon: const Icon(
                  Icons.visibility,
                ),
                label: const Text(
                  "View Report",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =========================================================
  // OPEN PENDING AI REPORT
  // =========================================================

  void _openPendingReport(dynamic report) {
    if (report is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid report data"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reportId =
        int.tryParse(
      report["report_id"].toString(),
    );

    if (reportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report ID not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // =============================================
      // LOAD REPORT ID
      // =============================================

      generatedReportId = reportId;

      // =============================================
      // LOAD REPORT CONTENT
      // =============================================

      generatedReport = {
        "strengths":
            report["strengths"] ?? "",

        "improvement_areas":
            report["improvement_areas"] ?? "",

        "ai_suggestions":
            report["ai_suggestions"] ?? "",
      };

      // =============================================
      // LOAD PERFORMANCE SUMMARY
      // =============================================

      reportSummary = {
        "attendance_percentage":
            report["attendance_percentage"] ?? 0,

        "average_marks":
            report["average_marks"] ?? 0,

        "homework_completion":
            report["homework_completion"] ?? 0,
      };

      // =============================================
      // REPORT IS ALREADY GENERATED
      // =============================================

      reportAlreadyExists = true;

      // =============================================
      // PENDING REPORT IS NOT APPROVED
      // =============================================

      reportApproved = false;
    });

    // =============================================
    // SCROLL TO REPORT AREA
    // =============================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Pending AI report opened for review.",
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
  // =========================================================
// VERIFIED REPORT CARD
// =========================================================

Widget _buildVerifiedReportCard(dynamic report) {

  if (report is! Map) {
    return const SizedBox();
  }

  final reportMonth =
      report["report_month"]?.toString() ??
      "Unknown Month";

  final attendance =
      report["attendance_percentage"]?.toString() ??
      "0";

  final averageMarks =
      report["average_marks"]?.toString() ??
      "0";

  final homework =
      report["homework_completion"]?.toString() ??
      "0";

  final strengths =
      report["strengths"]?.toString() ??
      "No information available.";

  final improvementAreas =
      report["improvement_areas"]?.toString() ??
      "No information available.";

  final suggestions =
      report["ai_suggestions"]?.toString() ??
      "No information available.";
  final celebration =
    report["celebration"]?.toString() ??
    report["celebration_suggestion"]?.toString() ??
    "No celebration suggestion available.";

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // =================================================
          // HEADER
          // =================================================

          Row(
            children: [

              const Icon(
                Icons.auto_awesome,
                color: Color(0xff1F4FB8),
                size: 28,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  "AI Progress Report",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Text(
                  "Verified",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // =================================================
          // REPORT MONTH
          // =================================================

          Row(
            children: [

              const Icon(
                Icons.calendar_month,
                color: Color(0xff1F4FB8),
                size: 20,
              ),

              const SizedBox(width: 8),

              const Text(
                "Report Month: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(
                child: Text(reportMonth),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =================================================
          // SUMMARY
          // =================================================

          Row(
            children: [

              Expanded(
                child: _buildReportSummaryCard(
                  "Attendance",
                  "$attendance%",
                  Icons.calendar_today,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildReportSummaryCard(
                  "Average Marks",
                  "$averageMarks%",
                  Icons.school,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildReportSummaryCard(
                  "Homework",
                  "$homework%",
                  Icons.assignment,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =================================================
          // STRENGTHS
          // =================================================

          const Text(
            "Strengths",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            strengths,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // IMPROVEMENT AREAS
          // =================================================

          const Text(
            "Improvement Areas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            improvementAreas,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // AI SUGGESTIONS
          // =================================================

          const Text(
            "AI Suggestions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            suggestions,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

// =================================================
// FAMILY CELEBRATION
// =================================================

const Text(
  "Family Celebration",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.orange.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.orange.shade200,
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(
        Icons.celebration,
        color: Colors.orange,
        size: 28,
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Text(
          celebration,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    ],
  ),
),
        ],
      ),
    ),
  );
}
// =========================================================
// STUDENT AI MENU
// =========================================================

Widget _buildStudentAIMenu() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // =======================================================
      // TITLE
      // =======================================================

      const Text(
        "AI Fields",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xff1F4FB8),
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "Choose an AI feature",
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 25),

      // =======================================================
      // VIEW REPORT
      // =======================================================

      Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),

          onTap: () {
            setState(() {
              studentAIView = "reports";
            });
          },

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Row(
              children: [

                Container(
                  width: 58,
                  height: 58,

                  decoration: BoxDecoration(
                    color: const Color(0xffEAF3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.analytics,
                    color: Color(0xff1F4FB8),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        "View Report",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "View your verified monthly AI progress reports.",
                        style: TextStyle(
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
      ),

      const SizedBox(height: 18),

      // =======================================================
      // ASK AI
      // =======================================================

      Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),

          onTap: () {
            setState(() {
              studentAIView = "ask";
            });
          },

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Row(
              children: [

                Container(
                  width: 58,
                  height: 58,

                  decoration: BoxDecoration(
                    color: const Color(0xffF3E8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.chat,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Ask AI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Ask academic questions and get AI-powered answers.",
                        style: TextStyle(
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
      ),
    ],
  );
}
// =========================================================
// ASK AI QUESTION
// =========================================================

Future<void> _askAIQuestion() async {

  final question =
      _askAIController.text.trim();

  if (question.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter an academic question.",
        ),
        backgroundColor: Colors.orange,
      ),
    );

    return;
  }

  setState(() {
    isAskingAI = true;
    aiAnswer = null;
  });

  try {

    // =====================================================
    // CALL FLASK → OLLAMA
    // =====================================================

    final result = await ApiService.askAI(
      question: question,
    );

    if (!mounted) return;

    // =====================================================
    // SUCCESS
    // =====================================================

    if (result["success"] == true) {

      setState(() {

        aiAnswer =
            result["answer"]?.toString() ??
            "No answer received from AI.";

      });

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ??
                "Failed to get AI answer.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$e",
        ),
        backgroundColor: Colors.red,
      ),
    );

  } finally {

    if (!mounted) return;

    setState(() {
      isAskingAI = false;
    });
  }
}
// =========================================================
// STUDENT ASK AI
// =========================================================

Widget _buildStudentAskAIView() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // =====================================================
      // HEADER
      // =====================================================

      Row(
        children: [

          IconButton(
            onPressed: isAskingAI
                ? null
                : () {
                    setState(() {
                      studentAIView = "menu";
                      aiAnswer = null;
                      _askAIController.clear();
                    });
                  },
            icon: const Icon(Icons.arrow_back),
          ),

          const SizedBox(width: 5),

          const Text(
            "Ask AI",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F4FB8),
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      // =====================================================
      // DESCRIPTION
      // =====================================================

      const Text(
        "Ask your academic doubt",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "Ask questions about your subjects and get help from AI.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 20),

      // =====================================================
      // QUESTION FIELD
      // =====================================================

      TextField(
        controller: _askAIController,
        enabled: !isAskingAI,
        maxLines: 6,
        textInputAction: TextInputAction.newline,

        decoration: InputDecoration(
          hintText: "Type your academic doubt here...",

          prefixIcon: const Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 12,
            ),
            child: Icon(
              Icons.help_outline,
              color: Color(0xff1F4FB8),
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xff1F4FB8),
              width: 2,
            ),
          ),

          alignLabelWithHint: true,
        ),
      ),

      const SizedBox(height: 20),

      // =====================================================
      // ASK AI BUTTON
      // =====================================================

      SizedBox(
        width: double.infinity,
        height: 52,

        child: ElevatedButton.icon(
          onPressed: isAskingAI
              ? null
              : _askAIQuestion,

          icon: isAskingAI
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                ),

          label: Text(
            isAskingAI
                ? "Thinking..."
                : "Ask AI",

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xff1F4FB8),

            disabledBackgroundColor:
                Colors.grey,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      // =====================================================
      // AI ANSWER
      // =====================================================

      if (aiAnswer != null) ...[

        const SizedBox(height: 30),

        const Text(
          "AI Answer",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff1F4FB8),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xff1F4FB8),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  aiAnswer!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
// =========================================================
// STUDENT AI REPORT VIEW
// =========================================================

Widget _buildStudentAIReportsView() {
  if (isLoadingVerifiedReports) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (verifiedReports.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 55,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            "No verified AI reports available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your verified monthly progress reports will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "My AI Progress Reports",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xff1F4FB8),
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "View your verified monthly performance reports.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 25),

      ...verifiedReports.map(
        (report) => _buildVerifiedReportCard(report),
      ),
    ],
  );
}
// =========================================================
// PARENT AI REPORT VIEW
// =========================================================

Widget _buildParentAIReportsView() {
  if (isLoadingVerifiedReports) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (verifiedReports.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 55,
            color: Colors.grey,
          ),

          SizedBox(height: 12),

          Text(
            "No verified AI reports available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Your child's verified monthly progress reports will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Child's AI Progress Reports",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xff1F4FB8),
      ),
    ),

    const SizedBox(height: 8),

    // =====================================================
    // CHILD NAME
    // =====================================================

    Row(
      children: [
        const Icon(
          Icons.person,
          color: Color(0xff1F4FB8),
          size: 22,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            "Child: ${parentChildName ?? "Child"}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),

    const SizedBox(height: 8),

    const Text(
      "View your child's verified monthly performance reports.",
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),

    const SizedBox(height: 25),

    ...verifiedReports.map(
      (report) => _buildVerifiedReportCard(report),
    ),
  ],
);
}
// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {

  // =======================================================
  // STUDENT VIEW
  // =======================================================

  // =======================================================
// STUDENT VIEW
// =======================================================

if (widget.mode == AIReportsMode.student) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xff1F4FB8),
      foregroundColor: Colors.white,

      title: const Text(
        "AI Fields",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: RefreshIndicator(
      onRefresh: studentAIView == "reports"
          ? _loadVerifiedReports
          : () async {},

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),

        child: studentAIView == "menu"
            ? _buildStudentAIMenu()
            : studentAIView == "reports"
                ? _buildStudentAIReportsView()
                : _buildStudentAskAIView(),
      ),
    ),
  );
}
  // =======================================================
// PARENT VIEW
// =======================================================

if (widget.mode == AIReportsMode.parent) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xff1F4FB8),
      foregroundColor: Colors.white,
      title: const Text(
        "AI Reports",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: RefreshIndicator(
      onRefresh: _loadVerifiedReports,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),

        child: _buildParentAIReportsView(),
      ),
    ),
  );
}

  // =======================================================
  // TEACHER VIEW
  // =======================================================

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xff1F4FB8),
      foregroundColor: Colors.white,

      title: const Text(
        "AI Reports",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =================================================
          // TITLE
          // =================================================

          const Text(
            "Generate Student AI Report",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F4FB8),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Select a class, section and student to generate an AI-based progress report.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          // =========================================================
          // PENDING AI REPORTS
          // =========================================================

          const Text(
            "Pending AI Reports",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F4FB8),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "AI reports waiting for teacher verification.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          if (isLoadingPendingReports)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (pendingReports.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 45,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No pending AI reports",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "All generated reports have been reviewed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: pendingReports.map((report) {
                return _buildPendingReportCard(report);
              }).toList(),
            ),

          const SizedBox(height: 35),

          // =================================================
          // CLASS
          // =================================================

          const Text(
            "Class",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedClass,

            decoration: InputDecoration(
              hintText: isLoadingClasses
                  ? "Loading classes..."
                  : "Select Class",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              prefixIcon: const Icon(
                Icons.school,
              ),
            ),

            items: availableClasses.map((className) {
              return DropdownMenuItem<String>(
                value: className,
                child: Text(className),
              );
            }).toList(),

            onChanged:
                isLoadingClasses
                    ? null
                    : _onClassChanged,
          ),

          const SizedBox(height: 20),

          // =================================================
          // SECTION
          // =================================================

          const Text(
            "Section",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedSection,

            decoration: InputDecoration(
              hintText: selectedClass == null
                  ? "Select Class first"
                  : "Select Section",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              prefixIcon: const Icon(
                Icons.class_,
              ),
            ),

            items: availableSections.map((section) {
              return DropdownMenuItem<String>(
                value: section,
                child: Text(section),
              );
            }).toList(),

            onChanged:
                selectedClass == null
                    ? null
                    : _onSectionChanged,
          ),

          const SizedBox(height: 20),

          // =================================================
          // STUDENT
          // =================================================

          const Text(
            "Student",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<int>(
            initialValue: selectedStudentId,

            decoration: InputDecoration(
              hintText: selectedSection == null
                  ? "Select Section first"
                  : isLoadingStudents
                      ? "Loading students..."
                      : students.isEmpty
                          ? "No students found"
                          : "Select Student",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              prefixIcon: const Icon(
                Icons.person,
              ),
            ),

            items: students
                .map((student) {
                  final studentId =
                      _getStudentId(student);

                  if (studentId == null) {
                    return null;
                  }

                  return DropdownMenuItem<int>(
                    value: studentId,
                    child: Text(
                      _getStudentName(student),
                    ),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList(),

            onChanged:
                selectedSection == null ||
                        isLoadingStudents ||
                        students.isEmpty
                    ? null
                    : _onStudentChanged,
          ),

          const SizedBox(height: 35),

          // =================================================
          // REPORT YEAR
          // =================================================

          const Text(
            "Report Year",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<int>(
            initialValue: selectedReportYear,

            decoration: InputDecoration(
              hintText: "Select Report Year",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              prefixIcon: const Icon(
                Icons.calendar_today,
              ),
            ),

            items: reportYears.map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),

            onChanged: selectedStudentId == null
                ? null
                : (value) {
                    setState(() {
                      selectedReportYear = value;
                      selectedMonth = null;

                      generatedReport = null;
                      reportSummary = null;
                      generatedReportId = null;
                      reportApproved = false;
                      reportAlreadyExists = false;
                    });
                  },
          ),

          const SizedBox(height: 20),

          // =================================================
          // REPORT MONTH
          // =================================================

          const Text(
            "Report Month",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<int>(
            initialValue: selectedMonth,

            decoration: InputDecoration(
              hintText: selectedReportYear == null
                  ? "Select Report Year first"
                  : "Select Report Month",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              prefixIcon: const Icon(
                Icons.calendar_month,
              ),
            ),

            items: List.generate(
              monthNames.length,
              (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(monthNames[index]),
                );
              },
            ),

            onChanged: selectedReportYear == null
                ? null
                : (value) {
                    setState(() {
                      selectedMonth = value;

                      generatedReport = null;
                      reportSummary = null;
                      generatedReportId = null;
                      reportApproved = false;
                      reportAlreadyExists = false;
                    });
                  },
          ),

          const SizedBox(height: 35),

          // =================================================
          // GENERATE AI REPORT
          // =================================================

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed:
                  isGeneratingReport ||
                          reportAlreadyExists ||
                          selectedClass == null ||
                          selectedSection == null ||
                          selectedStudentId == null ||
                          selectedReportYear == null ||
                          selectedMonth == null
                      ? null
                      : _generateAIReport,

              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ),

              label: Text(
                reportAlreadyExists
                    ? "Report Already Generated"
                    : "Generate AI Report",

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff1F4FB8),

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // =================================================
          // GENERATED AI REPORT
          // =================================================

          if (generatedReport != null) ...[
            const SizedBox(height: 30),

            const Text(
              "AI Student Progress Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff1F4FB8),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // =====================================
                    // MONTHLY PERFORMANCE SUMMARY
                    // =====================================

                    const Text(
                      "Monthly Performance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildReportSummaryCard(
                            "Attendance",
                            "${reportSummary?["attendance_percentage"] ?? 0}%",
                            Icons.calendar_today,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child:
                              _buildReportSummaryCard(
                            "Average Marks",
                            "${reportSummary?["average_marks"] ?? 0}%",
                            Icons.school,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child:
                              _buildReportSummaryCard(
                            "Homework",
                            "${reportSummary?["homework_completion"] ?? 0}%",
                            Icons.assignment,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =====================================
                    // STRENGTHS
                    // =====================================

                    const Text(
                      "Strengths",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      generatedReport!["strengths"]
                              ?.toString() ??
                          "No information available.",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // IMPROVEMENT AREAS
                    // =====================================

                    const Text(
                      "Improvement Areas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      generatedReport![
                                  "improvement_areas"]
                              ?.toString() ??
                          "No information available.",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // AI SUGGESTIONS
                    // =====================================

                    const Text(
                      "AI Suggestions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      generatedReport![
                                  "ai_suggestions"]
                              ?.toString() ??
                          "No information available.",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =====================================
                    // REPORT APPROVAL
                    // =====================================

                    if (reportApproved)
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color:
                              Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Report Approved",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child:
                            ElevatedButton.icon(
                          onPressed:
                              isApprovingReport
                                  ? null
                                  : _approveAIReport,

                          icon:
                              isApprovingReport
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .check_circle,
                                      color:
                                          Colors.white,
                                    ),

                          label: Text(
                            isApprovingReport
                                ? "Approving..."
                                : "Approve Report",

                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}
