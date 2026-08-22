import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState
    extends State<ParentProfileScreen> {

  Map<String, dynamic>? parent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    if (Session.parentId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result =
        await ApiService.getParentProfile(
      Session.parentId!,
    );

    if (!mounted) return;

    if (result["success"] == true) {

      setState(() {
        parent = Map<String, dynamic>.from(
          result["parent"],
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
          "Parent Profile",
        ),
        backgroundColor:
            const Color(0xff1F4FB8),
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : parent == null
              ? const Center(
                  child: Text(
                    "Parent profile not found",
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
                        parent!["full_name"]
                            .toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        parent!["email"]
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
                                Icons.family_restroom,
                                "Relationship",
                                parent![
                                  "relationship"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.person,
                                "Child Name",
                                parent![
                                  "child_name"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.school,
                                "Class",
                                parent![
                                  "class"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.class_,
                                "Section",
                                parent![
                                  "section"
                                ].toString(),
                              ),

                              profileItem(
                                Icons.format_list_numbered,
                                "Roll Number",
                                parent![
                                  "roll_no"
                                ].toString(),
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