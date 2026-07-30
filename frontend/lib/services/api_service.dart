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
 


}