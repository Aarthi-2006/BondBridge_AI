import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class DeleteTeacherScreen extends StatelessWidget {

  final int teacherId;

  const DeleteTeacherScreen({

    super.key,

    required this.teacherId,

  });

  Future<void> deleteTeacher(BuildContext context) async {

    final response = await ApiService.deleteTeacher(
      teacherId,
    );
    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(
          response["message"],
        ),

      ),

    );

    if (response["message"] == "Teacher deleted successfully") {

      Navigator.pop(context, true);

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Delete Teacher",
        ),

      ),

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(

                Icons.delete,

                color: Colors.red,

                size: 80,

              ),

              const SizedBox(height: 20),

              const Text(

                "Are you sure you want to delete this teacher?",

                textAlign: TextAlign.center,

                style: TextStyle(

                  fontSize: 18,

                ),

              ),

              const SizedBox(height: 30),

              ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,

                ),

                onPressed: () async {

  await deleteTeacher(context);

},
                child: const Text(

                  "Delete Teacher",

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}