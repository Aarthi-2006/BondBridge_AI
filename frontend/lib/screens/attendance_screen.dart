import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
import '../../services/class_permission_service.dart';
import 'dart:io';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}


class _AttendanceScreenState extends State<AttendanceScreen> {


  String? selectedClass;
  String? selectedSection;
    String? classTeacher;
  int? classTeacherId;
  String selectedPage = "";
  DateTime selectedDate = DateTime.now();
List<dynamic> students = [];
bool isLoading = false;
bool isSaving = false;
Map<int, String> attendanceStatus = {};
List viewAttendanceList = [];
int totalStudents = 0;
List assignedClasses = [];
List<dynamic> studentAttendance = [];
List<dynamic> displayedAttendance = [];
bool isLoadingAttendance = false;
bool showAll = false;


DateTime? selectedStudentDate;
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
    "D"

  ];
  @override
void initState() {
  super.initState();

  if (Session.role == "Teacher") {
    loadTeacherClasses();
  }

  if (Session.role == "Student") {
    loadStudentAttendance();
  }
}
Future<void> loadTeacherClasses() async {
  await ClassPermissionService.loadPermissions();

  if (!mounted) return;

  setState(() {
    assignedClasses = ClassPermissionService.getClasses();
  });
}
  Future<void> loadStudents() async {


if(selectedClass == null || selectedSection == null){

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

content:Text(
"Please select class and section"
),

),

);

return;

}

// Teacher can only view attendance for assigned classes
if (Session.role == "Teacher") {
  final allowed = assignedClasses.any(
    (assignedClass) =>
        assignedClass["class"]?.toString() == selectedClass &&
        assignedClass["section"]?.toString() == selectedSection,
  );

  if (!allowed) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You are not assigned to this class and section",
        ),
      ),
    );
    return;
  }
}

setState(() {

isLoading=true;

});



try{


final result =
await ApiService.getStudents(

studentClass: selectedClass,

section: selectedSection,

);


setState(() {

students=result;

isLoading=false;

});


}

catch(e){


setState(() {

isLoading=false;

});

if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

content:Text(
"Failed to load students"
),

),

);


}


}
Future<void> loadStudentAttendance() async {
  if (Session.studentId == null) return;

  setState(() {
    isLoadingAttendance = true;
  });

  try {
      final result = await ApiService.viewStudentAttendance(
  studentId: Session.studentId!,
);
    

    setState(() {
      studentAttendance = result["attendance"] ?? [];
displayedAttendance = List.from(studentAttendance);
      isLoadingAttendance = false;
    });
  } catch (e) {
    setState(() {
      isLoadingAttendance = false;
    });

    debugPrint("Attendance error: $e");
  }
}
Future loadAttendance() async {

  if (selectedClass == null || selectedSection == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select class and section"),
      ),
    );

    return;
  }
 

  setState(() {
    isLoading = true;
  });

  try {

    final result = await ApiService.viewAttendance(
      studentClass: selectedClass!,
      section: selectedSection!,
      date:
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
    );

    setState(() {
      viewAttendanceList = result["students"] ?? [];
      totalStudents = result["total"] ?? 0;
      isLoading = false;
    });

  } catch (e) {

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to load attendance"),
      ),
    );

  }

}



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Attendance Management",
        ),

        backgroundColor:Colors.blue,

      ),



     body: Padding(
  padding: const EdgeInsets.all(16),
  child: Session.role == "Student"
      ? viewAttendance()
      : selectedPage == ""
          ? attendanceMenu()
          : selectedPage == "take"
              ? takeAttendance()
              : viewAttendance(),
),

    );

  }






// MAIN ATTENDANCE MENU

Widget attendanceMenu(){


  return Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [


      const Text(

        "Attendance Management",

        style: TextStyle(

          fontSize:26,

          fontWeight:FontWeight.bold,

          color:Color(0xff1F4FB8),

        ),

      ),



      const SizedBox(height:8),



      const Text(

        "Take and manage student attendance.",

        style:TextStyle(

          color:Colors.grey,

          fontSize:15,

        ),

      ),



      const SizedBox(height:25),




      Card(

        elevation:5,

        child:ListTile(


          leading:const Icon(

            Icons.fact_check,

            size:35,

            color:Color(0xff1F4FB8),

          ),



          title:const Text(

            "Take Attendance",

            style:TextStyle(

              fontSize:18,

              fontWeight:FontWeight.bold,

            ),

          ),



          subtitle:const Text(

            "Mark student attendance",

          ),



          trailing:const Icon(

            Icons.arrow_forward_ios,

          ),



          onTap:(){

            setState(() {

              selectedPage="take";

            });

          },


        ),

      ),




      const SizedBox(height:20),




      Card(

        elevation:5,

        child:ListTile(


          leading:const Icon(

            Icons.visibility,

            size:35,

            color:Color(0xff1F4FB8),

          ),



          title:const Text(

            "View Attendance",

            style:TextStyle(

              fontSize:18,

              fontWeight:FontWeight.bold,

            ),

          ),



          subtitle:const Text(

            "View attendance records",

          ),



          trailing:const Icon(

            Icons.arrow_forward_ios,

          ),



          onTap:(){

            setState(() {

              selectedPage="view";

            });

          },


        ),

      ),



    ],

  );


}







// TAKE ATTENDANCE PAGE

Widget takeAttendance(){


return SingleChildScrollView(

child:Column(

crossAxisAlignment:CrossAxisAlignment.start,

children:[



IconButton(

icon:const Icon(Icons.arrow_back),

onPressed:(){
setState(() {

selectedPage="";

});

},

),




const Text(

"Take Attendance",

style:TextStyle(

fontSize:24,

fontWeight:FontWeight.bold,

),

),



const SizedBox(height:25),




DropdownButtonFormField(
  decoration: const InputDecoration(
    labelText: "Select Class",
    border: OutlineInputBorder(),
  ),
  initialValue: selectedClass,
  items: Session.role == "Teacher"
      ? assignedClasses
          .map<DropdownMenuItem<String>>((assignedClass) {
          final className =
              assignedClass["class"]?.toString();

          return DropdownMenuItem<String>(
            value: className,
            child: Text("Class $className"),
          );
        }).toList()
      : classes.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text("Class $value"),
          );
        }).toList(),

  onChanged: (value) {
    setState(() {
      selectedClass = value;
      selectedSection = null;
    });
  },
),




const SizedBox(height:20),




DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: "Select Section",
    border: OutlineInputBorder(),
  ),
  initialValue: selectedSection,
  items: Session.role == "Teacher"
      ? assignedClasses
          .where(
            (assignedClass) =>
                assignedClass["class"]?.toString() ==
                selectedClass,
          )
          .map<DropdownMenuItem<String>>((assignedClass) {
            final sectionName =
                assignedClass["section"]?.toString();

            return DropdownMenuItem<String>(
              value: sectionName,
              child: Text("Section $sectionName"),
            );
          })
          .toList()
      : sections.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text("Section $value"),
          );
        }).toList(),

  onChanged: (value) {
    setState(() {
      selectedSection = value;
    });
  },
),





const SizedBox(height:25),

InkWell(

onTap:() async {


DateTime? pickedDate = await showDatePicker(

context: context,

initialDate: selectedDate,

firstDate: DateTime(2020),

lastDate: DateTime(2030),

);



if(pickedDate != null){

setState(() {

selectedDate = pickedDate;

});

}


},



child: InputDecorator(

decoration: const InputDecoration(

labelText:"Select Date",

border:OutlineInputBorder(),

),



child: Text(

"${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",

),


),

),


const SizedBox(height:25),


SizedBox(

width:double.infinity,


child:ElevatedButton(



onPressed: loadStudents,



child:const Text(

"Load Students",

),


),

),
const SizedBox(height:20),


if(isLoading)

const Center(

child:CircularProgressIndicator(),

)


else
Column(
children: [

ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: students.length,
  itemBuilder: (context, index) {
    final student = students[index];
    final int id = int.parse(student["student_id"].toString());

    return Card(
      child: ListTile(
        title: Text(student["full_name"] ?? ""),
        subtitle: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  attendanceStatus[id] = "Present";
                });
              },
              child: const Text("Present"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  attendanceStatus[id] = "Absent";
                });
              },
              child: const Text("Absent"),
            ),
          ],
        ),
        trailing: Text(
          attendanceStatus[id] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  },
),


const SizedBox(height:20),


// SAVE BUTTON

SizedBox(
width:double.infinity,

child:ElevatedButton(

onPressed: () async {

  if (attendanceStatus.length != students.length) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please mark attendance for all students."),
    ),
  );
  return;
}

  bool success = await ApiService.saveAttendance(
    attendanceStatus,
    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
    Session.teacherId!,
  );

  if (success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance saved successfully"),
      ),
    );

    attendanceStatus.clear();

    setState(() {});
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to save attendance"),
      ),
    );
  }
},

child:const Text(
"Save Attendance",
),

),

),


],
),
],
),
);
}









// VIEW ATTENDANCE PAGE

// VIEW ATTENDANCE PAGE

Widget viewAttendance() {
  if (Session.role == "Student") {
    return studentViewAttendance();
  }

  return teacherViewAttendance();
}

Widget teacherViewAttendance() {
  return SingleChildScrollView(

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        IconButton(

          icon: const Icon(Icons.arrow_back),

          onPressed: () {

            setState(() {

              selectedPage = "";

              viewAttendanceList.clear();

              totalStudents = 0;

            });

          },

        ),

        const Text(

          "View Attendance",

          style: TextStyle(

            fontSize: 24,

            fontWeight: FontWeight.bold,

          ),

        ),

        const SizedBox(height: 25),

        DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: "Select Class",
    border: OutlineInputBorder(),
  ),

  initialValue: selectedClass,

  items: Session.role == "Teacher"
      ? assignedClasses
          .map<DropdownMenuItem<String>>((assignedClass) {
            final className =
                assignedClass["class"]?.toString();

            return DropdownMenuItem<String>(
              value: className,
              child: Text("Class $className"),
            );
          })
          .toList()
      : classes.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text("Class $value"),
          );
        }).toList(),

  onChanged: (value) {
    setState(() {
      selectedClass = value;
      selectedSection = null;
    });
  },
),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: "Select Section",
    border: OutlineInputBorder(),
  ),

  initialValue: selectedSection,

  items: Session.role == "Teacher"
      ? assignedClasses
          .where(
            (assignedClass) =>
                assignedClass["class"]?.toString() ==
                selectedClass,
          )
          .map<DropdownMenuItem<String>>((assignedClass) {
            final sectionName =
                assignedClass["section"]?.toString();

            return DropdownMenuItem<String>(
              value: sectionName,
              child: Text("Section $sectionName"),
            );
          })
          .toList()
      : sections.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text("Section $value"),
          );
        }).toList(),

  onChanged: (value) {
    setState(() {
      selectedSection = value;
    });
  },
),
        const SizedBox(height: 20),

        InkWell(

          onTap: () async {

            DateTime? pickedDate = await showDatePicker(

              context: context,

              initialDate: selectedDate,

              firstDate: DateTime(2020),

              lastDate: DateTime(2030),

            );

            if (pickedDate != null) {

              setState(() {

                selectedDate = pickedDate;

              });

            }

          },

          child: InputDecorator(

            decoration: const InputDecoration(

              labelText: "Select Date",

              border: OutlineInputBorder(),

            ),

            child: Text(

              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",

            ),

          ),

        ),

        const SizedBox(height: 25),

        SizedBox(

          width: double.infinity,

          child: ElevatedButton(

            onPressed: loadAttendance,

            child: const Text("View Attendance"),

          ),

        ),
        const SizedBox(height: 20),

if (isLoading)
  const Center(
    child: CircularProgressIndicator(),
  )
else if (viewAttendanceList.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Card(
        child: ListTile(
          leading: const Icon(Icons.people),
          title: Text("Total Students: $totalStudents"),
        ),
      ),

      const SizedBox(height: 10),

      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewAttendanceList.length,
        itemBuilder: (context, index) {

          final student = viewAttendanceList[index];

          return Card(
            child: ListTile(

              leading: const Icon(Icons.person),

              title: Text(
                student["student_name"] ?? "",
              ),

              trailing: Text(
                student["status"] ?? "Not Marked",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: student["status"] == "Present"
                      ? Colors.green
                      : student["status"] == "Absent"
                          ? Colors.red
                          : Colors.grey,
                ),
              ),

            ),
          );

        },
      ),

    ],
  ),

      ],

    ),

  );
  

}
Widget studentViewAttendance() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "My Attendance",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff1F4FB8),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "View your attendance records.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 25),

// SELECT DATE
InkWell(
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
initialDate: selectedStudentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStudentDate = pickedDate;
      });
    }
  },
  child: InputDecorator(
    decoration: const InputDecoration(
      labelText: "Select Date",
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.calendar_today),
    ),
    child: Text(
  selectedStudentDate == null
      ? "Select Date"
      : "${selectedStudentDate!.day.toString().padLeft(2, '0')}-"
        "${selectedStudentDate!.month.toString().padLeft(2, '0')}-"
        "${selectedStudentDate!.year}",
),
  ),
),

const SizedBox(height: 15),

// SEARCH + SHOW ALL
Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
  if (selectedStudentDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a date"),
      ),
    );
    return;
  }

  final selectedDateString =
      "${selectedStudentDate!.day.toString().padLeft(2, '0')}-"
      "${selectedStudentDate!.month.toString().padLeft(2, '0')}-"
      "${selectedStudentDate!.year}";

  setState(() {
    displayedAttendance = studentAttendance.where((attendance) {
      final rawDate =
          attendance["attendance_date"]?.toString() ?? "";

      if (rawDate.isEmpty) {
        return false;
      }

      try {
        final parsedDate = HttpDate.parse(rawDate);

        final attendanceDateString =
            "${parsedDate.day.toString().padLeft(2, '0')}-"
            "${parsedDate.month.toString().padLeft(2, '0')}-"
            "${parsedDate.year}";

        return attendanceDateString == selectedDateString;
      } catch (e) {
        return false;
      }
    }).toList();
  });
},
        icon: const Icon(Icons.search),
        label: const Text("Search"),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
  setState(() {
    selectedStudentDate = null;
    displayedAttendance = List.from(studentAttendance);
  });
},
        icon: const Icon(Icons.list),
        label: const Text("Show All"),
      ),
    ),
  ],
),

const SizedBox(height: 20),

// TOTAL RECORDS


if (isLoadingAttendance)
  const Center(
    child: CircularProgressIndicator(),
  )
else if (displayedAttendance.isEmpty)
  const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "No attendance records found.",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    ),
  )
else
  Column(
    children: [
      Card(
        child: ListTile(
          leading: const Icon(
            Icons.calendar_month,
            color: Color(0xff1F4FB8),
          ),
          title: const Text(
            "Total Attendance Records",
          ),
          trailing: Text(
            displayedAttendance.length.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),

      const SizedBox(height: 10),

      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedAttendance.length,
        itemBuilder: (context, index) {
          final attendance = displayedAttendance[index];

          final status =
              attendance["status"]?.toString() ?? "Not Marked";

          final rawDate =
              attendance["attendance_date"]?.toString() ?? "";

          String date = rawDate;

          if (rawDate.isNotEmpty && rawDate.contains("-")) {
            final parts = rawDate.split("-");

            if (parts.length == 3) {
              date = "${parts[2]}-${parts[1]}-${parts[0]}";
            }
          }

          return Card(
            child: ListTile(
              leading: Icon(
                status == "Present"
                    ? Icons.check_circle
                    : Icons.cancel,
                color: status == "Present"
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(
                status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Date: $date",
              ),
            ),
          );
        },
      ),
    ],
  ),
      ],
    ),
  );
}

}