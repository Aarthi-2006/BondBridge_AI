import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}


class _AttendanceScreenState extends State<AttendanceScreen> {


  String? selectedClass;
  String? selectedSection;

  String selectedPage = "";
  DateTime selectedDate = DateTime.now();
List<dynamic> students = [];
bool isLoading = false;
bool isSaving = false;
Map<int, String> attendanceStatus = {};
List viewAttendanceList = [];
int totalStudents = 0;


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


ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

content:Text(
"Failed to load students"
),

),

);


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
          "Attendance",
        ),

        backgroundColor:
        const Color(0xff1F4FB8),

      ),



      body: Padding(

        padding: const EdgeInsets.all(16),


        child:

        selectedPage == ""

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




DropdownButtonFormField<String>(


decoration:const InputDecoration(

labelText:"Select Class",

border:OutlineInputBorder(),

),


value:selectedClass,


items:classes.map((value){


return DropdownMenuItem(

value:value,

child:Text(

"Class $value",

),

);


}).toList(),



onChanged:(value){


setState(() {

selectedClass=value.toString();

});


},


),





const SizedBox(height:20),




DropdownButtonFormField<String>(


decoration:const InputDecoration(

labelText:"Select Section",

border:OutlineInputBorder(),

),


value:selectedSection,


items:sections.map((value){


return DropdownMenuItem(

value:value,

child:Text(

"Section $value",

),

);


}).toList(),



onChanged:(value){


setState(() {

selectedSection=value.toString();

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance saved successfully"),
      ),
    );

    attendanceStatus.clear();

    setState(() {});
  } else {
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

Widget viewAttendance() {

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

        DropdownButtonFormField(

          decoration: const InputDecoration(

            labelText: "Select Class",

            border: OutlineInputBorder(),

          ),

          value: selectedClass,

          items: classes.map((value) {

            return DropdownMenuItem(

              value: value,

              child: Text("Class $value"),

            );

          }).toList(),

          onChanged: (value) {

            setState(() {

              selectedClass = value.toString();

            });

          },

        ),

        const SizedBox(height: 20),

        DropdownButtonFormField(

          decoration: const InputDecoration(

            labelText: "Select Section",

            border: OutlineInputBorder(),

          ),

          value: selectedSection,

          items: sections.map((value) {

            return DropdownMenuItem(

              value: value,

              child: Text("Section $value"),

            );

          }).toList(),

          onChanged: (value) {

            setState(() {

              selectedSection = value.toString();

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


}