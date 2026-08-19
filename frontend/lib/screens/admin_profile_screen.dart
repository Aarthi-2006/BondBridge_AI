import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {

  Map<String, dynamic>? admin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  Future<void> loadAdminProfile() async {

    final data = await ApiService.getAdminProfile();

    if (data["success"] == true) {
      setState(() {
        admin = data["admin"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Admin Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff1F4FB8),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : admin == null
              ? const Center(
                  child: Text("Unable to load admin profile"),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      const SizedBox(height: 20),

                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xffEAF3FF),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xff1F4FB8),
                        ),
                      ),

                      const SizedBox(height: 25),

                      _profileItem(
                        Icons.person,
                        "Full Name",
                        admin!["full_name"] ?? "",
                      ),

                      _profileItem(
                        Icons.email,
                        "Email",
                        admin!["email"] ?? "",
                      ),

                      _profileItem(
                        Icons.admin_panel_settings,
                        "Role",
                        admin!["role"] ?? "",
                      ),

                      _profileItem(
                        Icons.calendar_month,
                        "Account Created",
                        formatDate(admin!["created_at"]),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _profileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xff1F4FB8),
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
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

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
      ),
    );
  }

  String formatDate(dynamic date) {

    if (date == null) {
      return "";
    }

    final text = date.toString();

    if (text.length >= 10) {
      final parts = text.substring(0, 10).split("-");

      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }

    return text;
  }
}