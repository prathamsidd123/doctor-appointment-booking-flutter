import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dlivehealthy/doctor/d_login.dart';
import 'package:dlivehealthy/patient/p_login.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [


              CircleAvatar(
                radius: 100,
                backgroundColor: const Color(0xFFDCEEFA),
                backgroundImage: AssetImage('assets/images/img.png'),
              ),

              const SizedBox(height: 16),

              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Sign in to continue",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),

              const SizedBox(height: 28),


              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    const Text("Email",
                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "you@example.com",
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text("Password",
                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resetPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF378ADD),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF378ADD),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("Login",
                            style: TextStyle(fontSize: 15)),
                      ),
                    ),


                    SizedBox(height: 20,),
                    Center(

                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        ),
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> loginUser() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        showError("Login failed");
        return;
      }

      final doctorSnap = await _db.child("Doctors").child(user.uid).get();
      final patientSnap = await _db.child("Patients").child(user.uid).get();

      if (!mounted) return;

      if (doctorSnap.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DoctorHome()),
        );
      } else if (patientSnap.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PatientHomePage()),
        );
      } else {
        showError("User role not found");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        showError("Wrong password. Please try again.");
      } else if (e.code == 'user-not-found') {
        showError("No account found with this email.");
      } else if (e.code == 'invalid-email') {
        showError("Please enter a valid email address.");
      } else {
        showError(e.message ?? "Login failed");
      }
    } catch (e) {
      showError("Something went wrong. Please try again.");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }
  
  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      showError("Please enter your email first");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset link sent to your email",
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Something went wrong");
    }
  }
}