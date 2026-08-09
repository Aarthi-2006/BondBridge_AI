import 'dart:convert';
import 'package:http/http.dart' as http;



class ApiService {

  // Emulator -> Flask
  static const String baseUrl = "http://10.0.2.2:5000";


  // ==========================
  // LOGIN API
  // ==========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {

    try {

      final response = await http.post(

        Uri.parse("$baseUrl/login"),

        headers: {

          "Content-Type": "application/json",

        },

        body: jsonEncode({

          "email": email,
          "password": password,

        }),

      );


      return jsonDecode(response.body);


    } catch (e) {

      return {

        "message": "Unable to connect to server",

      };

    }

  }




  // ==========================
  // ADD STUDENT API
  // ==========================
  static Future<Map<String, dynamic>> addStudent({

    required String fullName,
    required String email,
    required String password,
    required String rollNo,
    required String studentClass,
    required String section,
    required String dateOfBirth,
    required String gender,
    required String admissionDate,

  }) async {


    try {


      final response = await http.post(

        Uri.parse("$baseUrl/students"),

        headers: {

          "Content-Type": "application/json",

        },


        body: jsonEncode({

          "full_name": fullName,
          "email": email,
          "password": password,
          "roll_no": rollNo,
          "class": studentClass,
          "section": section,
          "date_of_birth": dateOfBirth,
          "gender": gender,
          "admission_date": admissionDate,

        }),

      );


      return jsonDecode(response.body);



    } catch (e) {


      return {

        "message": "Unable to connect to server",

      };


    }


  }





  // ==========================
  // GET ALL STUDENTS API
  // ==========================
  // ==========================
// GET STUDENTS API
// ==========================
static Future<List<dynamic>> getStudents({
  String? studentClass,
  String? section,
}) async {
  try {
    String url = "$baseUrl/students";

    // Add query parameters if class and section are provided
    if (studentClass != null &&
        studentClass.isNotEmpty &&
        section != null &&
        section.isNotEmpty) {
      url += "?class=$studentClass&section=$section";
    }

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

// ==========================
// GET TOTAL STUDENTS
// ==========================

static Future<int> getStudentCount() async {

  try {

    final response = await http.get(
      Uri.parse("$baseUrl/students/count"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data["total_students"];

    } else {

      return 0;

    }

  } catch (e) {

    return 0;

  }

}


  // ==========================
  // UPDATE STUDENT API
  // ==========================
  static Future<Map<String, dynamic>> updateStudent(

    int studentId,
    Map<String, dynamic> studentData,

  ) async {


    try {


      final response = await http.put(


        Uri.parse(
          "$baseUrl/students/$studentId"
        ),


        headers: {

          "Content-Type": "application/json",

        },


        body: jsonEncode(studentData),


      );



      return jsonDecode(response.body);



    } catch (e) {


      return {

        "message": "Unable to connect to server",

      };


    }


  }





  // ==========================
  // DELETE STUDENT API
  // ==========================
  static Future<Map<String, dynamic>> deleteStudent(

    int studentId,

  ) async {


    try {


      final response = await http.delete(


        Uri.parse(
          "$baseUrl/students/$studentId"
        ),


      );



      return jsonDecode(response.body);



    } catch (e) {


      return {

        "message": "Unable to connect to server",

      };


    }


  }
    // ==========================
  // ADD TEACHER API
  // ==========================

  static Future<Map<String, dynamic>> addTeacher({

    required String fullName,
    required String email,
    required String password,
    required String employeeId,
    required String subject,
    required String qualification,
    required int experience,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String joiningDate,

  }) async {


    try {


      final response = await http.post(

        Uri.parse("$baseUrl/teachers"),

        headers: {

          "Content-Type": "application/json",

        },


        body: jsonEncode({

          "full_name": fullName,
          "email": email,
          "password": password,
          "employee_id": employeeId,
          "subject": subject,
          "qualification": qualification,
          "experience": experience,
          "phone_number": phoneNumber,
          "gender": gender,
          "date_of_birth": dateOfBirth,
          "joining_date": joiningDate,

        }),

      );


      return jsonDecode(response.body);



    } catch (e) {


      return {

        "message": "Unable to connect to server",

      };


    }


  }




  // ==========================
  // GET ALL TEACHERS API
  // ==========================

  // ==========================
// GET TEACHERS API
// ==========================
static Future<List<dynamic>> getTeachers({
  String? subject,
}) async {

  try {

    String url = "$baseUrl/teachers";

    if (subject != null && subject.isNotEmpty) {

      url += "?subject=$subject";

    }

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      return [];

    }

  } catch (e) {

    return [];

  }

}
  // ==========================
  // UPDATE TEACHER API
  // ==========================

  static Future<Map<String, dynamic>> updateTeacher(

    int teacherId,
    Map<String, dynamic> teacherData,

  ) async {


    try {


      final response = await http.put(

        Uri.parse(
          "$baseUrl/teachers/$teacherId"
        ),


        headers: {

          "Content-Type": "application/json",

        },


        body: jsonEncode(teacherData),


      );


      return jsonDecode(response.body);



    } catch(e){


      return {

        "message": "Unable to connect to server",

      };


    }


  }





  // ==========================
  // DELETE TEACHER API
  // ==========================
static Future<Map<String, dynamic>> deleteTeacher(
  int teacherId,
) async {

  try {

    final response = await http.delete(

      Uri.parse(
        "$baseUrl/teachers/$teacherId"
      ),

    );




    return jsonDecode(response.body);


  } catch(e) {


    return {

      "message": "Unable to connect to server",

    };

  }

}
 
 // ======================================
// GET TEACHERS LIST
// ======================================

static Future<List<dynamic>> getTeachersList() async {

  try {

    final response = await http.get(
      Uri.parse("$baseUrl/teachers_list"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];

  } catch (e) {

    return [];

  }

}

// ======================================
// ASSIGN CLASS TEACHER
// ======================================

static Future<Map<String,dynamic>> assignClassTeacher({

  required int teacherId,
  required String className,
  required String section,

}) async {

  try {

    final response = await http.post(

      Uri.parse("$baseUrl/assign_class_teacher"),

      headers: {
        "Content-Type":"application/json"
      },

      body: jsonEncode({

        "teacher_id": teacherId,
        "class": className,
        "section": section

      }),

    );

    return jsonDecode(response.body);

  } catch(e){

    return {
      "success":false,
      "message":"Unable to connect to server"
    };

  }

}
// ======================================
// GET ASSIGNED CLASSES OF TEACHER
// ======================================

static Future<List<dynamic>> getTeacherClasses(
    int teacherId,
) async {

  try {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/teacher_classes/$teacherId",
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data["classes"];

    }

    return [];

  } catch (e) {

    return [];

  }

}

  // =====================================================
// GET PARENTS
// =====================================================

static Future<Map<String, dynamic>> getParents({
  String? className,
  String? section,
  String? search,
}) async {

  String url = "$baseUrl/parents";


  List<String> params = [];


  if (className != null && className.isNotEmpty) {
    params.add("class=$className");
  }


  if (section != null && section.isNotEmpty) {
    params.add("section=$section");
  }


  if (search != null && search.isNotEmpty) {
    params.add("search=$search");
  }


  if (params.isNotEmpty) {

    url = "$url?${params.join("&")}";

  }



  final response = await http.get(
    Uri.parse(url),
  );


  if(response.statusCode == 200){

    return jsonDecode(response.body);

  }

  else{

    throw Exception(
      "Failed to load parents"
    );

  }

}



// =====================================================
// GET STUDENTS BY CLASS AND SECTION
// =====================================================


static Future<List<dynamic>> getParentStudents({

required String className,

required String section,

}) async {


String url =
"$baseUrl/parent_students?class=$className&section=$section";



final response = await http.get(
Uri.parse(url)
);



if(response.statusCode==200){

return jsonDecode(response.body);

}


else{

throw Exception(
"Failed to load students"
);

}


}




// =====================================================
// ADD PARENT
// =====================================================


static Future<bool> addParent(
Map<String,dynamic> data
) async {


final response = await http.post(

Uri.parse(
"$baseUrl/parents"
),


headers:{

"Content-Type":
"application/json"

},


body:
jsonEncode(data)

);



return response.statusCode==200;



}




// =====================================================
// UPDATE PARENT
// =====================================================


static Future<bool> updateParent(

int parentId,

Map<String,dynamic> data

) async {


final response = await http.put(

Uri.parse(
"$baseUrl/parents/$parentId"
),


headers:{

"Content-Type":
"application/json"

},


body:
jsonEncode(data)

);



return response.statusCode==200;


}




// =====================================================
// DELETE PARENT
// =====================================================


static Future<bool> deleteParent(

int parentId

) async {



final response = await http.delete(

Uri.parse(
"$baseUrl/parents/$parentId"
)

);



return response.statusCode==200;


}
// ======================================
// GET ALL ANNOUNCEMENTS
// ======================================

static Future<Map<String, dynamic>> getAnnouncements() async {
  final response = await http.get(
    Uri.parse("$baseUrl/announcements"),
  );

  return jsonDecode(response.body);
}

// ======================================
// GET SINGLE ANNOUNCEMENT
// ======================================

static Future<Map<String, dynamic>> getAnnouncement(int id) async {
  final response = await http.get(
    Uri.parse("$baseUrl/announcements/$id"),
  );

  return jsonDecode(response.body);
}

// ======================================
// ADD ANNOUNCEMENT
// ======================================

static Future<Map<String, dynamic>> addAnnouncement(
    Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse("$baseUrl/announcements"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  return jsonDecode(response.body);
}

// ======================================
// UPDATE ANNOUNCEMENT
// ======================================

static Future<Map<String, dynamic>> updateAnnouncement(
    int id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse("$baseUrl/announcements/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  return jsonDecode(response.body);
}

// ======================================
// DELETE ANNOUNCEMENT
// ======================================

static Future<Map<String, dynamic>> deleteAnnouncement(int id) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/announcements/$id"),
  );

  return jsonDecode(response.body);
}
// ======================================
// SAVE ATTENDANCE
// ======================================

static Future<bool> saveAttendance(
Map<int, String> attendanceStatus,
String attendanceDate,
int teacherId,
) async {

try {

final response = await http.post(

Uri.parse("$baseUrl/attendance"),

headers: {

"Content-Type": "application/json",

},

body: jsonEncode({

"teacher_id": teacherId,

"attendance_date": attendanceDate,

"attendance": attendanceStatus.entries.map((entry){

return {

"student_id": entry.key,

"status": entry.value,

};

}).toList(),

}),

);


return response.statusCode == 201;


}

catch(e){

return false;

}

}
// ======================================
// VIEW ATTENDANCE
// ======================================

static Future<Map<String, dynamic>> viewAttendance({
  required String studentClass,
  required String section,
  required String date,
}) async {

  try {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/attendance/view?class=$studentClass&section=$section&date=$date",
      ),
    );

    return jsonDecode(response.body);

  } catch (e) {

    return {
      "success": false,
      "students": [],
      "total": 0,
      "message": e.toString(),
    };

  }

}
// ======================================
// GET MARKS
// ======================================

// ======================================
// GET MARKS
// ======================================

static Future<List> getMarks({
  required String studentClass,
  required String section,
}) async {

  try {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/marks?class=$studentClass&section=$section",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];

  } catch (e) {
    return [];
  }

}


// ======================================
// ADD MARKS
// ======================================


static Future<Map<String, dynamic>> addMarks({
  required int studentId,
  required int teacherId,
  required String subject,
  required String assessmentType,
  required String assessmentCategory,
  required String assessmentName,
  String? assessmentDate,
  String? academicYear,
  required double marksObtained,
  required double totalMarks,
  String? teacherRemarks,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/marks"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "student_id": studentId,
      "teacher_id": teacherId,
      "subject": subject,
      "assessment_type": assessmentType,
      "assessment_category": assessmentCategory,
      "assessment_name": assessmentName,
      "assessment_date": assessmentDate,
      "academic_year": academicYear,
      "marks_obtained": marksObtained,
      "total_marks": totalMarks,
      "teacher_remarks": teacherRemarks,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return data;
  } else {
    throw Exception(
      data["error"] ?? "Failed to add marks",
    );
  }
}
}
