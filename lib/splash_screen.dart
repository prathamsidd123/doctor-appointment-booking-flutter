import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'database_helper.dart';
import 'package:dlivehealthy/auth/login.dart';
import 'package:dlivehealthy/doctor/d_login.dart';
import 'package:dlivehealthy/patient/p_login.dart';



class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    checkAuthStatus();//check user status
  }
  //check login status
  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 5));

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
      else {
        final doctorSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('Doctors')
            .child(user.uid)
            .get();

        if (!mounted) return;

        if (doctorSnapshot.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DoctorHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PatientHomePage()),
          );
        }
      }
    }
    catch (e) {
      print("SPLASH ERROR: $e");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }
  // void _navigateToLogin() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => LoginScreen()),
  //   );
  // }
  //
  // void _navigateToDoctorHome() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => DoctorHome()),
  //   );
  // }
  //
  // void _navigateToPatientHome() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => PatientHomePage()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

    body: Container(

      child: Image.asset(
        "assets/images/img3.png",
         height: 1000,
         width: 1000,
        fit: BoxFit.cover,
      ),
    ),
    );
  }
}