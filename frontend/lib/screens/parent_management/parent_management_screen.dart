import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentManagementScreen extends StatefulWidget {
  const ParentManagementScreen({super.key});

  @override
  State<ParentManagementScreen> createState() =>
      _ParentManagementScreenState();
}

class _ParentManagementScreenState
    extends State<ParentManagementScreen> {
  //=============================
  // VARIABLES
  //=============================

  bool loading = false;

  List<dynamic> parents = [];
  List<dynamic> students = [];

  String? selectedClass;
  String? selectedSection;

  final List<String> classes = [
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
    "12"
  ];

  final List<String> sections = [
    "A",
    "B",
    "C",
    "D",
  ];

  final List<String> relationships = [
    "Father",
    "Mother",
    "Guardian",
    "Other",
  ];

  //=============================
  // INIT
  //=============================

  @override
  void initState() {
    super.initState();
    loadParents();
  }

  //=============================
  // LOAD PARENTS
  //=============================

  Future<void> loadParents() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.getParents(
        className: selectedClass,
        section: selectedSection,
      );

      setState(() {
        parents = result["parents"] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  //=============================
  // LOAD STUDENTS
  //=============================

  Future<void> loadStudents({
    required String className,
    required String section,
  }) async {
    try {
      students = await ApiService.getParentStudents(
        className: className,
        section: section,
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //==================================================
  // ADD / EDIT PARENT DIALOG
  //==================================================

  void openParentDialog({
    Map<String, dynamic>? parent,
  }) {
    final nameController = TextEditingController(
      text: parent?["parent_name"] ?? "",
    );

    final emailController = TextEditingController(
      text: parent?["email"] ?? "",
    );

    final passwordController = TextEditingController();

    String? dialogClass = parent?["class"];
    String? dialogSection = parent?["section"];

    String? studentId =
        parent?["student_id"]?.toString();

    String relationship =
        parent?["relationship"] ?? "Father";

    students = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
                        return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                parent == null ? "Add Parent" : "Edit Parent",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Parent Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      if (parent == null) ...[
                        const SizedBox(height: 15),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: dialogClass,
                        decoration: const InputDecoration(
                          labelText: "Class",
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                        ),
                        items: classes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            dialogClass = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: dialogSection,
                        decoration: const InputDecoration(
                          labelText: "Section",
                          prefixIcon: Icon(Icons.group),
                          border: OutlineInputBorder(),
                        ),
                        items: sections
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            dialogSection = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text("Load Students"),
                          onPressed: () async {

                            if (dialogClass == null ||
                                dialogSection == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select Class & Section",
                                  ),
                                ),
                              );
                              return;
                            }

                           final result = await ApiService.getStudents(
  studentClass: dialogClass!,
  section: dialogSection!,
);
print(result);
setDialogState(() {
  students = result;
});
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: students.any(
                                (s) =>
                                    s["student_id"].toString() ==
                                    studentId)
                            ? studentId
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Student",
                          border: OutlineInputBorder(),
                        ),
                        items: students.map((student){

                        return DropdownMenuItem<String>(
                                value: student["student_id"]
                                    .toString(),
                                child: Text(
                                  student["full_name"]??"",
                                ),
                              );
          })
                            .toList(),
                        onChanged: (value) {
                          setDialogState((){
                          studentId = value;
                        });
                        },
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: relationship,
                        decoration: const InputDecoration(
                          labelText: "Relationship",
                          prefixIcon: Icon(Icons.family_restroom),
                          border: OutlineInputBorder(),
                        ),
                        items: relationships
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          relationship = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: () async {

                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        studentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill all required fields.",
                          ),
                        ),
                      );
                      return;
                    }

                    final data = {
                      "full_name": nameController.text.trim(),
                      "email": emailController.text.trim(),
                      "password": passwordController.text.trim(),
                      "student_id": int.parse(studentId!),
                      "relationship": relationship,
                    };

                    if (parent == null) {
                      await ApiService.addParent(data);
                    } else {
                      await ApiService.updateParent(
                        parent["parent_id"],
                        data,
                      );
                    }

                    if (mounted) {
                      Navigator.pop(context);
                    }

                    loadParents();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
    //=========================================================
  // DELETE PARENT
  //=========================================================

  void deleteParent(int parentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Delete Parent"),
        content: const Text(
          "Are you sure you want to delete this parent?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await ApiService.deleteParent(parentId);

              if (mounted) {
                Navigator.pop(context);
              }

              loadParents();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //=========================================================
  // UI
  //=========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Parent Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          openParentDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Parent"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            //------------------------------------------------
            // FILTER CARD
            //------------------------------------------------

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedClass,
                            decoration: const InputDecoration(
                              labelText: "Class",
                              border: OutlineInputBorder(),
                            ),
                            items: classes
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedClass = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSection,
                            decoration: const InputDecoration(
                              labelText: "Section",
                              border: OutlineInputBorder(),
                            ),
                            items: sections
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSection = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text("Search"),
                            onPressed: loadParents,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Show All"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedClass = null;
                                selectedSection = null;
                              });

                              loadParents();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            //------------------------------------------------
            // TOTAL PARENTS CARD
            //------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.groups,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Total Parents",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        parents.length.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            //------------------------------------------------
            // LIST STARTS
            //------------------------------------------------

            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  
                                    : parents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.people_outline,
                                size: 90,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "No Parents Found",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: parents.length,
                          itemBuilder: (context, index) {
                            final p = parents[index];

                            return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  elevation: 3,
  child: ListTile(
    leading: CircleAvatar(
      child: Text(
        p["parent_name"]
            .toString()
            .substring(0, 1)
            .toUpperCase(),
      ),
    ),

    title: Text(
      p["parent_name"],
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text("Email : ${p["email"]}"),

        Text("Child : ${p["student_name"]}"),

        Text("Relationship : ${p["relationship"]}"),

        Text(
          "Class : ${p["class"]} - ${p["section"]}",
        ),
      ],
    ),

    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          onPressed: () => openParentDialog(parent:p),
        ),

        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () => deleteParent(p["parent_id"]),
        ),
      ],
    ),
  ),
);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
