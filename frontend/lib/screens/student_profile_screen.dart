import 'package:flutter/material.dart';
import '../services/session.dart';
import '../services/api_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
    String? classTeacher;

  @override
  void initState() {
    super.initState();
    _loadClassTeacher();
  }

  Future<void> _loadClassTeacher() async {
    if (Session.studentClass == null ||
        Session.studentSection == null) {
      return;
    }

    final teacher = await ApiService.getStudentClassTeacher(
      studentClass: Session.studentClass!,
      section: Session.studentSection!,
    );

    if (mounted) {
      setState(() {
        classTeacher = teacher;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final studentName = Session.fullName ?? "Student";

  return Scaffold(
    backgroundColor: const Color(0xffF6F8FC),

    appBar: AppBar(
      backgroundColor: const Color(0xff1F4FB8),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "My Profile",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          // =====================================================
          // PROFILE HEADER
          // =====================================================

          // =====================================================
// PROFILE HEADER
// =====================================================

Column(
  children: [

    CircleAvatar(
      radius: 43,
      backgroundColor: const Color(0xffEAF3FF),

      child: const Icon(
        Icons.person,
        size: 52,
        color: Color(0xff1F4FB8),
      ),
    ),

    const SizedBox(height: 14),

    Text(
      studentName,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),

    const SizedBox(height: 5),

    Text(
      Session.email ?? "Not available",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
    ),
  ],
),

const SizedBox(height: 28),
          const SizedBox(height: 20),

          // =====================================================
          // PROFILE INFORMATION
          // =====================================================

          // =====================================================
// PROFILE INFORMATION
// =====================================================

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Profile Information",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xff1F4FB8),
    ),
  ),
),

const SizedBox(height: 12),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),

  child: Column(
    children: [

      _profileRow(
        icon: Icons.person_outline,
        title: "Name",
        value: studentName,
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.wc_outlined,
        title: "Gender",
        value: Session.gender ?? "Not available",
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.school_outlined,
        title: "Class",
        value: Session.studentClass ?? "Not available",
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.groups_outlined,
        title: "Section",
        value: Session.studentSection ?? "Not available",
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.person_outline,
        title: "Class Teacher",
        value: classTeacher ?? "Not available",
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.badge_outlined,
        title: "Roll No",
        value: Session.rollNumber ?? "Not available",
      ),

      _profileDivider(),

      _profileRow(
        icon: Icons.email_outlined,
        title: "Email",
        value: Session.email ?? "Not available",
      ),
    ],
  ),
),

const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
  Widget _profileRow({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Row(
    children: [

      Container(
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: const Color(0xffEAF3FF),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Icon(
          icon,
          color: const Color(0xff1F4FB8),
          size: 22,
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _profileDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Divider(
      height: 1,
      color: Color(0xffEEEEEE),
    ),
  );
}
}