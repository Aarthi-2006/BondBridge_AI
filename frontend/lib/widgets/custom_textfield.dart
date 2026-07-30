import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;


  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });


  @override
  Widget build(BuildContext context) {

    return TextField(

      controller: controller,

      keyboardType: keyboardType,

      obscureText: obscureText,


      decoration: InputDecoration(

        hintText: hintText,


        prefixIcon: Icon(
          icon,
          color: Colors.blue,
        ),


        filled: true,

        fillColor: Colors.grey.shade100,


        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide.none,

        ),


        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(18),

          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),

        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 15,
        ),

      ),

    );
  }
}