import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
import '../../services/class_permission_service.dart';

class AnnouncementManagementScreen extends StatefulWidget {
  const AnnouncementManagementScreen({super.key});

  @override
  State<AnnouncementManagementScreen> createState() =>
      _AnnouncementManagementScreenState();
}

class _AnnouncementManagementScreenState
    extends State<AnnouncementManagementScreen> {

  //=====================================================
  // FORM KEY
  //=====================================================

  final _formKey = GlobalKey<FormState>();

  //=====================================================
  // CONTROLLERS
  //=====================================================

  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final searchController = TextEditingController();

  //=====================================================
  // DATA
  //=====================================================

  List announcements = [];
  List filteredAnnouncements = [];

  Map<String, dynamic>? editingAnnouncement;

  bool isLoading = false;

  String? selectedAudience = "All";
  String? selectedClass;
String? selectedSection;

List<String> teacherClasses = [];
List<String> teacherSections = [];

  final List<String> audiences = [
    "All",
    "Teachers",
    "Parents",
    "Students",
  ];

  //=====================================================
  // INIT
  //=====================================================

  @override
void initState() {
  super.initState();

  loadAnnouncements();

  if (Session.role?.toLowerCase() == "teacher") {
    loadTeacherClasses();
  }

  searchController.addListener(() {
    searchAnnouncements(searchController.text);
  });
}

Future<void> loadTeacherClasses() async {
  await ClassPermissionService.loadPermissions();

  if (!mounted) return;

  setState(() {
    teacherClasses =
        ClassPermissionService.getAvailableClasses();

    if (teacherClasses.isNotEmpty) {
      selectedClass = teacherClasses.first;
      teacherSections =
          ClassPermissionService.getAvailableSections(
        selectedClass!,
      );

      if (teacherSections.isNotEmpty) {
        selectedSection = teacherSections.first;
      }
    }
  });
}

  //=====================================================
  // LOAD ANNOUNCEMENTS
  //=====================================================

  Future<void> loadAnnouncements() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response =
          await ApiService.getAnnouncements();

      if (response["success"] == true) {

        announcements =
            response["announcements"] ?? [];

        filteredAnnouncements =
            List.from(announcements);
      }

    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }

    }

    setState(() {
      isLoading = false;
    });
  }

  //=====================================================
  // SEARCH
  //=====================================================

  void searchAnnouncements(String value) {

    if (value.trim().isEmpty) {

      setState(() {
        filteredAnnouncements =
            List.from(announcements);
      });

      return;
    }

    setState(() {

      filteredAnnouncements =
          announcements.where((announcement) {

        final title =
            announcement["title"]
                    ?.toString()
                    .toLowerCase() ??
                "";

        final message =
            announcement["message"]
                    ?.toString()
                    .toLowerCase() ??
                "";

        return title.contains(
                  value.toLowerCase(),
                ) ||
            message.contains(
                  value.toLowerCase(),
                );

      }).toList();

    });
  }

  //=====================================================
  // CLEAR FORM
  //=====================================================

  void clearForm() {
  titleController.clear();
  messageController.clear();

  selectedAudience = "All";

  selectedClass = null;
  selectedSection = null;

  if (Session.role?.toLowerCase() == "teacher" &&
      teacherClasses.isNotEmpty) {
    selectedClass = teacherClasses.first;

    teacherSections =
        ClassPermissionService.getAvailableSections(
      selectedClass!,
    );

    if (teacherSections.isNotEmpty) {
      selectedSection = teacherSections.first;
    }
  }

  editingAnnouncement = null;
}

  

  //=====================================================
  // OPEN ADD
  //=====================================================

  void openAddAnnouncement() {

    clearForm();

    showAnnouncementDialog();
  }

  //=====================================================
  // OPEN EDIT
  //=====================================================

  void openEditAnnouncement(
    Map<String, dynamic> announcement) {

  editingAnnouncement = announcement;

  titleController.text =
      announcement["title"] ?? "";

  messageController.text =
      announcement["message"] ?? "";

  selectedAudience =
      announcement["target_audience"] ?? "All";

  selectedClass =
      announcement["target_class"]?.toString();

  selectedSection =
      announcement["target_section"]?.toString();

  if (Session.role?.toLowerCase() == "teacher" &&
      selectedClass != null) {
    teacherSections =
        ClassPermissionService.getAvailableSections(
      selectedClass!,
    );
  }

  showAnnouncementDialog();
}
    //=====================================================
  // SAVE ANNOUNCEMENT
  //=====================================================

  Future<void> saveAnnouncement() async {

  if (!_formKey.currentState!.validate()) return;

  final isTeacher =
      Session.role?.toLowerCase() == "teacher";

  if (isTeacher &&
      (selectedClass == null ||
       selectedSection == null)) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select class and section",
        ),
      ),
    );

    return;
  }

  setState(() {
    isLoading = true;
  });

  Map<String, dynamic> data = {

    "title": titleController.text.trim(),

    "message": messageController.text.trim(),

    "target_audience": selectedAudience,

  };

  // Teacher announcements must contain class + section
  if (isTeacher) {

    data["target_class"] = selectedClass;

    data["target_section"] = selectedSection;

  }

  Map<String, dynamic> result;

  if (editingAnnouncement == null) {

    result =
        await ApiService.addAnnouncement(data);

  } else {

    result =
        await ApiService.updateAnnouncement(
      editingAnnouncement!["announcement_id"],
      data,
    );

  }

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result["message"] ??
            "Operation completed",
      ),
    ),
  );

  if (result["success"] == true) {

    Navigator.pop(context);

    loadAnnouncements();

  }
}
  //=====================================================
  // DELETE
  //=====================================================

  Future<void> deleteAnnouncement(int id) async {

    bool? confirm = await showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: const Text("Delete Announcement"),

        content: const Text(
          "Are you sure you want to delete this announcement?",
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
        await ApiService.deleteAnnouncement(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(result["message"]),
      ),

    );

    loadAnnouncements();
  }

  //=====================================================
  // DISPOSE
  //=====================================================

  @override
  void dispose() {

    titleController.dispose();
    messageController.dispose();
    searchController.dispose();

    super.dispose();
  }

  //=====================================================
  // BUILD
  //=====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Colors.blue,

        title: const Text(
          "Announcement Management",
        ),

      ),

      floatingActionButton: FloatingActionButton(

        backgroundColor: Colors.blue,

        onPressed: openAddAnnouncement,

        child: const Icon(Icons.add),

      ),

      body: Column(

        children: [

          //====================================
          // SEARCH
          //====================================

          Padding(

            padding: const EdgeInsets.all(12),

            child: TextField(

              controller: searchController,

              decoration: InputDecoration(

                hintText: "Search announcements...",

                prefixIcon:
                    const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),

              ),

            ),

          ),

          //====================================
          // TOTAL CARD
          //====================================

          Card(

            margin: const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            color: Colors.blue.shade50,

            elevation: 3,

            child: Padding(

              padding: const EdgeInsets.all(16),

              child: Row(

                children: [

                  const Icon(

                    Icons.campaign,

                    color: Colors.blue,

                    size: 42,

                  ),

                  const SizedBox(width: 16),

                  Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(

                        "Total Announcements",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),

                      ),

                      Text(

                        filteredAnnouncements.length
                            .toString(),

                        style: const TextStyle(

                          fontSize: 28,

                          color: Colors.blue,

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

          ),

          const SizedBox(height: 10),
                    //====================================
          // ANNOUNCEMENT LIST
          //====================================

          Expanded(

            child: isLoading

                ? const Center(
                    child: CircularProgressIndicator(),
                  )

                : filteredAnnouncements.isEmpty

                    ? const Center(
                        child: Text(
                          "No Announcements Found",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )

                    : RefreshIndicator(

                        onRefresh: loadAnnouncements,

                        child: ListView.builder(

                          itemCount:
                              filteredAnnouncements.length,

                          itemBuilder: (context, index) {

                            final announcement =
                                filteredAnnouncements[index];

                            return Card(

                              margin:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              elevation: 3,

                              child: Padding(

                                padding:
                                    const EdgeInsets.all(16),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Row(

                                      children: [

                                        const Icon(
                                          Icons.campaign,
                                          color: Colors.blue,
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(

                                          child: Text(

                                            announcement["title"] ?? "",

                                            style:
                                                const TextStyle(

                                              fontSize: 18,

                                              fontWeight:
                                                  FontWeight.bold,

                                            ),

                                          ),

                                        ),

                                      ],

                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      announcement["message"] ?? "",
                                    ),

                                    const SizedBox(height: 14),

                                    Row(

                                      children: [

                                        const Icon(
                                          Icons.groups,
                                          size: 18,
                                          color: Colors.grey,
                                        ),

                                        const SizedBox(width: 6),

                                        Text(
                                          "Audience : ${announcement["target_audience"]}",
                                        ),

                                      ],

                                    ),

                                    const SizedBox(height: 8),

                                    Row(

                                      children: [

                                        const Icon(
                                          Icons.calendar_month,
                                          size: 18,
                                          color: Colors.grey,
                                        ),

                                        const SizedBox(width: 6),

                                       Text(
  "Posted On : ${announcement["created_at"]?.toString().split(" ")[0] ?? ""}",
),
                                      ],

                                    ),

                                    const SizedBox(height: 8),

                                    Row(

                                      children: [

                                        const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Colors.grey,
                                        ),

                                        const SizedBox(width: 6),

                                        Text(
                                          announcement["created_by"] ??
                                              "Admin",
                                        ),

                                      ],

                                    ),

                                    const SizedBox(height: 12),
if (
  Session.role?.toLowerCase() == "admin" ||
  (
    Session.role?.toLowerCase() == "teacher" &&
    announcement["created_by"] == "Teacher" &&
    announcement["teacher_id"]?.toString() ==
        Session.teacherId?.toString()
  )
)
  Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [

      IconButton(
        icon: const Icon(
          Icons.edit,
          color: Colors.blue,
        ),
        onPressed: () {
          openEditAnnouncement(
            announcement,
          );
        },
      ),

      IconButton(
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          deleteAnnouncement(
            announcement["announcement_id"],
          );
        },
      ),

    ],
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

  //=====================================================
  // ADD / EDIT DIALOG
  //=====================================================

  void showAnnouncementDialog() {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: Text(

            editingAnnouncement == null
                ? "Add Announcement"
                : "Edit Announcement",

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

                      controller: titleController,

                      decoration: const InputDecoration(

                        labelText: "Announcement Title",

                      ),

                      validator: (value) =>
                          value == null || value.isEmpty
                              ? "Required"
                              : null,

                    ),

                    const SizedBox(height: 15),

                    TextFormField(

                      controller: messageController,

                      maxLines: 5,

                      decoration: const InputDecoration(

                        labelText: "Description",

                        alignLabelWithHint: true,

                      ),

                      validator: (value) =>
                          value == null || value.isEmpty
                              ? "Required"
                              : null,

                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

                      initialValue: selectedAudience,

                      decoration: const InputDecoration(

                        labelText: "Target Audience",

                      ),

                      items: audiences.map((e) {

                        return DropdownMenuItem(

                          value: e,

                          child: Text(e),

                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedAudience = value;

                        });

                      },

                    ),
                    if (Session.role?.toLowerCase() == "teacher") ...[

  const SizedBox(height: 15),

  DropdownButtonFormField<String>(
    initialValue: selectedClass,
    decoration: const InputDecoration(
      labelText: "Class",
    ),
    items: teacherClasses.map((className) {
      return DropdownMenuItem<String>(
        value: className,
        child: Text(className),
      );
    }).toList(),
    onChanged: (value) {

      setState(() {

        selectedClass = value;

        teacherSections =
            ClassPermissionService
                .getAvailableSections(
          value!,
        );

        selectedSection =
            teacherSections.isNotEmpty
                ? teacherSections.first
                : null;

      });

    },
    validator: (value) {

      if (Session.role?.toLowerCase() == "teacher" &&
          value == null) {
        return "Required";
      }

      return null;
    },
  ),

  const SizedBox(height: 15),

  DropdownButtonFormField<String>(
    initialValue: selectedSection,
    decoration: const InputDecoration(
      labelText: "Section",
    ),
    items: teacherSections.map((section) {
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
    validator: (value) {

      if (Session.role?.toLowerCase() == "teacher" &&
          value == null) {
        return "Required";
      }

      return null;
    },
  ),
],

                    const SizedBox(height: 15),

                    
                    const SizedBox(height: 25),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed:
                            isLoading ? null : saveAnnouncement,

                        child: isLoading

                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )

                            : Text(

                                editingAnnouncement == null

                                    ? "Add Announcement"

                                    : "Update Announcement",

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

}