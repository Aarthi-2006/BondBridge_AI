import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'parent_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;

  Future<void> loginUser() async {

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final result = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
     debugPrint("LOGIN RESPONSE: $result");
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result["message"] == "Login successful") {
       Session.userId = result["user"]["user_id"];

Session.teacherId = result["user"]["teacher_id"];

Session.studentId = result["user"]["student_id"];

Session.studentClass =
    result["user"]["class"]?.toString();

Session.studentSection =
    result["user"]["section"]?.toString();

Session.rollNumber =
    result["user"]["roll_no"]?.toString();

Session.gender =
    result["user"]["gender"]?.toString();

Session.email =
    result["user"]["email"]?.toString();

Session.role =
    result["user"]["role"];

Session.fullName =
    result["user"]["full_name"];

        String role = result["role"].toString().toLowerCase();

        if (role == "admin") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboard(),
            ),
          );

        } else if (role == "teacher") {

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => TeacherDashboard(
        teacherName:
            result["user"]?["full_name"]?.toString() ?? "Teacher",

        teacherEmail:
            emailController.text.trim(),
      ),
    ),
  );

}
        else if (role == "student") {

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => StudentDashboard(
        studentName:
            result["user"]?["full_name"]?.toString() ?? "Student",

        studentEmail:
            emailController.text.trim(),
      ),
    ),
  );

}

        else if (role == "parent") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ParentDashboard(),
            ),
          );

        }

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Email or Password"),
          ),
        );

      }

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF6F8FC),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),

          child: Column(

            children: 
            [

              const SizedBox(height: 10),

              Hero(
                tag: "logo",
                child: Image.asset(
                  "assets/images/bondbridge_logo.png",
                  height: 190,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "BondBridge AI",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1D3557),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "CONNECT • ENGAGE • GROW TOGETHER",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              Container(

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [

                    BoxShadow(

                      color: Colors.black.withValues(alpha:.08),

                      blurRadius: 20,

                      offset: const Offset(0,10),

                    )

                  ],

                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Center(
                      child: Text(
                        "Welcome Back 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Center(
                      child: Text(
                        "Login to continue",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(

                      controller: emailController,

                      keyboardType: TextInputType.emailAddress,

                      decoration: InputDecoration(

                        hintText: "Email Address",

                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xff2F80ED),
                        ),

                        filled: true,

                        fillColor: const Color(0xffF5F7FB),

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide.none,

                        ),

                        focusedBorder: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(18),

                          borderSide: const BorderSide(
                            color: Color(0xff2F80ED),
                            width: 2,
                          ),

                        ),

                      ),

                    ),

                    const SizedBox(height: 18),
                    TextField(

  controller: passwordController,

  obscureText: _obscurePassword,

  decoration: InputDecoration(

    hintText: "Password",

    prefixIcon: const Icon(
      Icons.lock_outline,
      color: Color(0xff2F80ED),
    ),

    suffixIcon: IconButton(

      icon: Icon(

        _obscurePassword
            ? Icons.visibility_off
            : Icons.visibility,

        color: Colors.grey,

      ),

      onPressed: () {

        setState(() {

          _obscurePassword = !_obscurePassword;

        });

      },

    ),

    filled: true,

    fillColor: const Color(0xffF5F7FB),

    border: OutlineInputBorder(

      borderRadius: BorderRadius.circular(18),

      borderSide: BorderSide.none,

    ),

    focusedBorder: OutlineInputBorder(

      borderRadius: BorderRadius.circular(18),

      borderSide: const BorderSide(

        color: Color(0xff2F80ED),

        width: 2,

      ),

    ),

  ),

),

const SizedBox(height: 10),

Row(

  mainAxisAlignment: MainAxisAlignment.spaceBetween,

  children: [

    Row(

      children: [

        Checkbox(

          value: rememberMe,

          activeColor: const Color(0xff2F80ED),

          onChanged: (value) {

            setState(() {

              rememberMe = value!;

            });

          },

        ),

        Text(

          "Remember Me",

          style: GoogleFonts.poppins(
            fontSize: 13,
          ),

        ),

      ],

    ),

    TextButton(

      onPressed: () {},

      child: Text(

        "Forgot Password?",

        style: GoogleFonts.poppins(

          color: const Color(0xff2F80ED),

          fontWeight: FontWeight.w600,

        ),

      ),

    ),

  ],

),

const SizedBox(height: 20),

SizedBox(

  width: double.infinity,

  height: 58,

  child: Container(

    decoration: BoxDecoration(

      gradient: const LinearGradient(

        colors: [

          Color(0xff2F80ED),

          Color(0xff7B61FF),

        ],

      ),

      borderRadius: BorderRadius.circular(18),

      boxShadow: [

        BoxShadow(

          color: Colors.blue.withValues(alpha:.30),

          blurRadius: 15,

          offset: const Offset(0,8),

        )

      ],

    ),

    child: ElevatedButton(

      onPressed: isLoading ? null : loginUser,

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.transparent,

        shadowColor: Colors.transparent,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(18),

        ),

      ),

      child: isLoading

          ? const CircularProgressIndicator(

              color: Colors.white,

            )

          : Text(

              "LOGIN",

              style: GoogleFonts.poppins(

                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.bold,

                letterSpacing: 1,

              ),

            ),

    ),

  ),

),

const SizedBox(height: 30),



                   Center(
  child: Text(
    "© 2026 BondBridge AI",
    style: GoogleFonts.poppins(
      color: Colors.grey,
      fontSize: 12,
    ),
  ),
),
                 ], // Column children
                ), // Column
              ), // Container
            ], // Outer Column children
          ), // Outer Column
        ), // SingleChildScrollView
      ), // SafeArea
    );
   } // Scaffold
}