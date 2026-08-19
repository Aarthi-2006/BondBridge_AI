import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() =>
      _TeacherProfileScreenState();
}

class _TeacherProfileScreenState
    extends State<TeacherProfileScreen> {

  Map<String, dynamic>? teacher;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    if (Session.teacherId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result =
        await ApiService.getTeacherProfile(
      Session.teacherId!,
    );

    if (!mounted) return;

    if (result["success"] == true) {

      setState(() {
        teacher = Map<String, dynamic>.from(
          result["teacher"],
        );
        isLoading = false;
      });

    } else {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ??
                "Failed to load profile",
          ),
        ),
      );
    }
  }

  Widget profileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: const Color(0xff1F4FB8),
            size: 22,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Teacher Profile",
        ),
        backgroundColor:
            const Color(0xff1F4FB8),
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : teacher == null
              ? const Center(
                  child: Text(
                    "Teacher profile not found",
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      // =========================
                      // PROFILE ICON
                      // =========================

                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            const Color(0xffEAF3FF),

                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xff1F4FB8),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        teacher!["full_name"]
                            .toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        teacher!["email"]
                            .toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // PROFILE DETAILS
                      // =========================

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),

                          child: Column(
                            children: [

                              profileItem(
                                Icons.badge,
                                "Employee ID",
                                teacher![
                                  "employee_id"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.menu_book,
                                "Subject",
                                teacher![
                                  "subject"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.school,
                                "Qualification",
                                teacher![
                                  "qualification"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.work_history,
                                "Experience",
                                "${teacher!["experience"]} Years",
                              ),

                              profileItem(
                                Icons.phone,
                                "Phone Number",
                                teacher![
                                  "phone_number"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.person_outline,
                                "Gender",
                                teacher![
                                  "gender"
                                ].toString(),
                              ),

                              profileItem(
  Icons.cake,
  "Date of Birth",
  teacher!["date_of_birth"].toString(),
),

                             profileItem(
  Icons.calendar_month,
  "Joining Date",
  teacher!["joining_date"].toString(),
),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}