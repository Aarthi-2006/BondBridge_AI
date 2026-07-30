import 'package:flutter/material.dart';
import '../../services/api_service.dart';


class EditScreen extends StatefulWidget {

  final Map student;


  const EditScreen({

    super.key,

    required this.student,

  });



  @override
  State<EditScreen> createState() =>
      _EditScreenState();

}



class _EditScreenState extends State<EditScreen> {


  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController rollController;
  late TextEditingController classController;
  late TextEditingController sectionController;
  late TextEditingController genderController;



  bool isLoading = false;



  @override
  void initState() {

    super.initState();


    nameController = TextEditingController(

      text: widget.student["full_name"].toString(),

    );


    emailController = TextEditingController(

      text: widget.student["email"].toString(),

    );


    rollController = TextEditingController(

      text: widget.student["roll_no"].toString(),

    );


    classController = TextEditingController(

      text: widget.student["class"].toString(),

    );


    sectionController = TextEditingController(

      text: widget.student["section"].toString(),

    );


    genderController = TextEditingController(

      text: widget.student["gender"].toString(),

    );


  }





  Future<void> updateStudent() async {


    setState(() {

      isLoading = true;

    });



    final studentData = {


      "full_name": nameController.text,


      "email": emailController.text,


      "roll_no": rollController.text,


      "class": classController.text,


      "section": sectionController.text,


      "gender": genderController.text,


    };




    final result =
        await ApiService.updateStudent(


          widget.student["student_id"],


          studentData,


        );




    setState(() {

      isLoading = false;

    });




    ScaffoldMessenger.of(context).showSnackBar(


      SnackBar(

        content: Text(

          result["message"],

        ),

      ),


    );




    if(result["message"]
        .toString()
        .contains("successfully")){


      Navigator.pop(context);


    }


  }






  Widget textField(

      String label,

      TextEditingController controller,

      ){

    return Padding(

      padding:

          const EdgeInsets.symmetric(vertical:8),


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

              "Edit Student",

            ),


        backgroundColor: Colors.blue,

      ),




      body: Padding(


        padding:

            const EdgeInsets.all(16),



        child: ListView(


          children: [



            textField(

              "Full Name",

              nameController,

            ),




            textField(

              "Email",

              emailController,

            ),




            textField(

              "Roll Number",

              rollController,

            ),




            textField(

              "Class",

              classController,

            ),




            textField(

              "Section",

              sectionController,

            ),




            textField(

              "Gender",

              genderController,

            ),




            const SizedBox(height:20),




            ElevatedButton(


              onPressed:

                  isLoading

                  ? null

                  : updateStudent,



              child:


                  isLoading


                  ? const CircularProgressIndicator()


                  : const Text(

                      "Update Student",

                    ),



            ),



          ],


        ),


      ),



    );


  }


}