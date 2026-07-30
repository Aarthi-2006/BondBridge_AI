import 'package:flutter/material.dart';
import '../../services/api_service.dart';


class AddStudentScreen extends StatefulWidget {

  const AddStudentScreen({super.key});


  @override
  State<AddStudentScreen> createState() =>
      _AddStudentScreenState();

}



class _AddStudentScreenState extends State<AddStudentScreen> {


  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final rollController = TextEditingController();
final classController = TextEditingController();

final sectionController = TextEditingController();
  
  final dobController = TextEditingController();

  final genderController = TextEditingController();

  final admissionController = TextEditingController();



  bool isLoading = false;

  bool showPassword = false;
String? selectedClass;
String? selectedSection;


  // ==========================
  // DATE PICKER
  // ==========================

  Future<void> pickDate(
      TextEditingController controller,
      ) async {


    DateTime? picked = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(1990),

      lastDate: DateTime.now(),

    );



    if(picked != null){


      controller.text =
          "${picked.year}-"
          "${picked.month.toString().padLeft(2,'0')}-"
          "${picked.day.toString().padLeft(2,'0')}";


    }

  }







  // ==========================
  // ADD STUDENT
  // ==========================

  Future<void> addStudent() async {



    if(nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        rollController.text.isEmpty ||
        selectedClass == null ||
        selectedSection == null ||
        dobController.text.isEmpty ||
        genderController.text.isEmpty ||
        admissionController.text.isEmpty){


      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content:
          Text("Please fill all fields"),

        ),

      );


      return;

    }





    setState(() {

      isLoading = true;

    });





    final result = await ApiService.addStudent(


      fullName: nameController.text,


      email: emailController.text,


      password: passwordController.text,


      rollNo: rollController.text,


      studentClass: selectedClass!,

section: selectedSection!,

      dateOfBirth: dobController.text,


      gender: genderController.text,


      admissionDate: admissionController.text,


    );





    setState(() {

      isLoading = false;

    });






    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content:

        Text(

          result["message"].toString(),

        ),

      ),

    );





    if(result["message"]
        .toString()
        .contains("successfully")){


      Navigator.pop(context);


    }



  }







  // ==========================
  // TEXT FIELD
  // ==========================

  Widget inputField(

      String label,

      TextEditingController controller,

      ){

    return Padding(

      padding:

      const EdgeInsets.only(bottom:15),


      child: TextField(

        controller: controller,


        decoration: InputDecoration(

          labelText: label,

          border:

          const OutlineInputBorder(),

        ),

      ),

    );

  }








  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(


        title:

        const Text(

          "Add Student",

        ),


        backgroundColor: Colors.blue,


      ),






      body: SingleChildScrollView(



        padding:

        const EdgeInsets.all(16),




        child: Column(



          children: [




            inputField(

              "Full Name",

              nameController,

            ),





            inputField(

              "Email",

              emailController,

            ),






            TextField(


              controller: passwordController,


              obscureText: !showPassword,


              decoration: InputDecoration(


                labelText: "Password",


                border:

                const OutlineInputBorder(),



                suffixIcon:

                IconButton(


                  icon:

                  Icon(

                    showPassword

                        ? Icons.visibility

                        : Icons.visibility_off,

                  ),



                  onPressed: (){


                    setState(() {


                      showPassword =
                      !showPassword;


                    });


                  },


                ),


              ),


            ),





            const SizedBox(height:15),





            inputField(

              "Roll Number",

              rollController,

            ),





            DropdownButtonFormField<String>(
  value: selectedClass,
  decoration: const InputDecoration(
    labelText: "Class",
    border: OutlineInputBorder(),
  ),
  items: List.generate(
    12,
    (index) => DropdownMenuItem(
      value: "${index + 1}",
      child: Text("${index + 1}"),
    ),
  ),
  onChanged: (value) {
    setState(() {
      selectedClass = value;
      classController.text = value!;
    });
  },
),



            DropdownButtonFormField<String>(
  value: selectedSection,
  decoration: const InputDecoration(
    labelText: "Section",
    border: OutlineInputBorder(),
  ),
  items: const [
    DropdownMenuItem(
      value: "A",
      child: Text("A"),
    ),
    DropdownMenuItem(
      value: "B",
      child: Text("B"),
    ),
    DropdownMenuItem(
      value: "C",
      child: Text("C"),
    ),
    DropdownMenuItem(
      value: "D",
      child: Text("D"),
    ),
  ],
  onChanged: (value) {
    setState(() {
      selectedSection = value;
      sectionController.text = value!;
    });
  },
),





            // DOB


            TextField(


              controller: dobController,


              readOnly:true,


              onTap: (){

                pickDate(dobController);

              },


              decoration: const InputDecoration(


                labelText:

                "Date of Birth (YYYY-MM-DD)",


                border:

                OutlineInputBorder(),


                suffixIcon:

                Icon(Icons.calendar_month),


              ),


            ),





            const SizedBox(height:15),






            // GENDER DROPDOWN


            DropdownButtonFormField<String>(


              decoration:

              const InputDecoration(


                labelText:"Gender",


                border:

                OutlineInputBorder(),

              ),




              items: const [



                DropdownMenuItem(

                  value:"Male",

                  child:

                  Text("Male"),

                ),




                DropdownMenuItem(

                  value:"Female",

                  child:

                  Text("Female"),

                ),



              ],




              onChanged:(value){


                genderController.text =
                    value!;


              },


            ),





            const SizedBox(height:15),






            // ADMISSION DATE


            TextField(


              controller: admissionController,


              readOnly:true,


              onTap: (){


                pickDate(admissionController);


              },



              decoration: const InputDecoration(


                labelText:

                "Admission Date (YYYY-MM-DD)",


                border:

                OutlineInputBorder(),


                suffixIcon:

                Icon(Icons.calendar_month),


              ),


            ),






            const SizedBox(height:25),





            SizedBox(


              width:double.infinity,



              child: ElevatedButton(



                onPressed:

                isLoading

                    ? null

                    : addStudent,



                child:


                isLoading


                    ?

                const CircularProgressIndicator(

                  color: Colors.white,

                )


                    :

                const Text(

                  "Add Student",

                ),



              ),



            )





          ],


        ),


      ),


    );


  }


}