import 'package:animation_2/screens/home/components/cart_Order.dart';
import 'package:animation_2/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'controllers/home_controller.dart';
import 'package:animation_2/controllers/home_controller.dart';

void main() {

  HomeController controller = HomeController();
  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final HomeController controller;
  MyApp({required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            shape: StadiumBorder(),
            backgroundColor: primaryColor,
          ),
        ),
      ),
        home: HomeScreen(),
    );
  }
}
