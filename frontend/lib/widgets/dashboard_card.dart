import 'package:flutter/material.dart';


class DashboardCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;


  const DashboardCard({

    super.key,

    required this.title,

    required this.icon,

    required this.backgroundColor,

    required this.iconBackgroundColor,

    required this.iconColor,

    this.onTap,

  });



  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(18),


      child: Container(

        decoration: BoxDecoration(

          color: backgroundColor,

          borderRadius: BorderRadius.circular(18),

        ),


        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,


          children: [


            Container(

              padding: const EdgeInsets.all(18),


              decoration: BoxDecoration(

                color: iconBackgroundColor,

                shape: BoxShape.circle,

              ),


              child: Icon(

                icon,

                size: 40,

                color: iconColor,

              ),

            ),



            const SizedBox(height: 15),



            Text(

              title,

              style: const TextStyle(

                fontSize: 18,

                fontWeight: FontWeight.bold,

              ),

            ),



          ],

        ),

      ),

    );

  }

}