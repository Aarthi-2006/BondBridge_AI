import 'package:flutter/material.dart';
import '../../services/api_service.dart';


class DeleteScreen extends StatefulWidget {


  final Map student;


  const DeleteScreen({

    super.key,

    required this.student,

  });



  @override
  State<DeleteScreen> createState() =>
      _DeleteScreenState();

}




class _DeleteScreenState extends State<DeleteScreen> {


  bool isLoading = false;




  Future<void> deleteStudent() async {


    setState(() {

      isLoading = true;

    });



    final result =
        await ApiService.deleteStudent(

          widget.student["student_id"],

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







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(


        title:

            const Text(

              "Delete Student",

            ),


        backgroundColor: Colors.red,

      ),





      body: Center(


        child: Padding(


          padding:

              const EdgeInsets.all(20),



          child: Column(


            mainAxisAlignment:

                MainAxisAlignment.center,



            children: [




              const Icon(


                Icons.warning,

                color: Colors.red,

                size: 80,


              ),




              const SizedBox(height:20),




              Text(


                "Are you sure you want to delete?",


                style: const TextStyle(

                  fontSize:20,

                  fontWeight:FontWeight.bold,

                ),


                textAlign: TextAlign.center,


              ),





              const SizedBox(height:10),




              Text(


                widget.student["full_name"],


                style: const TextStyle(

                  fontSize:18,

                  color:Colors.blue,

                ),


              ),





              const SizedBox(height:30),






              Row(


                mainAxisAlignment:

                    MainAxisAlignment.center,



                children: [





                  ElevatedButton(


                    style:

                    ElevatedButton.styleFrom(

                      backgroundColor:

                          Colors.grey,

                    ),



                    onPressed: () {


                      Navigator.pop(context);


                    },



                    child:

                    const Text(

                      "Cancel",

                    ),


                  ),





                  const SizedBox(width:20),





                  ElevatedButton(



                    style:

                    ElevatedButton.styleFrom(

                      backgroundColor:

                          Colors.red,

                    ),




                    onPressed:

                    isLoading

                    ? null

                    : deleteStudent,



                    child:


                    isLoading


                    ? const CircularProgressIndicator(

                      color: Colors.white,

                    )



                    : const Text(

                      "Delete",

                    ),



                  ),





                ],


              )




            ],


          ),


        ),


      ),



    );


  }


}