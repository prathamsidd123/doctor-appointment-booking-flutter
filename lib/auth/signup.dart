import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../doctor/d_login.dart';
import '../patient/p_login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  // Firebase
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref();

  // Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  final qualification = TextEditingController();
  final experience = TextEditingController();

  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  // State
  String userType = "Patient";
  String? city;
  String? gender;
  String? category;
  bool loading = false;

  // Dropdown data
  List<String> cities = ["Ahmedabad","Mumbai","Delhi","Rajkot","Vadodara"];
  List<String> genders = ["Male","Female","Other"];
  List<String> categories = ["General Physician","Dentist","Cardiologist"];

  // ---------- COMMON INPUT STYLE (CSS Like) ----------
  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
        const BorderSide(color: Color(0xFF0064FA), width: 1.5),
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [

            // Logo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.person,
                  size: 34, color: Color(0xFF0064FA)),
            ),

            const SizedBox(height: 12),

            const Text(

              "Create Account",
              style: TextStyle(

                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            // MAIN CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: Column(
                children: [

                  // ---------- Toggle ----------
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            userType == "Patient"
                                ? const Color(0xFF0064FA)
                                : Colors.grey.shade200,
                          ),
                          onPressed: () =>
                              setState(() => userType = "Patient"),
                          child: Text("Patient",
                              style: TextStyle(
                                  color: userType == "Patient"
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            userType == "Doctor"
                                ? const Color(0xFF0064FA)
                                : Colors.grey.shade200,
                          ),
                          onPressed: () =>
                              setState(() => userType = "Doctor"),
                          child: Text("Doctor",
                              style: TextStyle(
                                  color: userType == "Doctor"
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // -------- Common Fields --------
                  TextField(controller: name,
                      decoration: inputStyle("Full Name")),

                  const SizedBox(height: 10),

                  TextField(controller: email,
                      decoration: inputStyle("Email")),

                  const SizedBox(height: 10),

                  TextField(controller: phone,
                      decoration: inputStyle("Phone")),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    hint: const Text("City"),
                    value: city,
                    decoration: inputStyle(""),
                    items: cities.map((c) =>
                        DropdownMenuItem(
                            value: c, child: Text(c))).toList(),
                    onChanged: (v) => city = v,
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: inputStyle("Password"),
                  ),

                  const SizedBox(height: 15),

                  // -------- Patient Fields --------
                  if (userType == "Patient") ...[
                    TextField(controller: age,
                        decoration: inputStyle("Age")),
                    const SizedBox(height: 10),

                    TextField(controller: height,
                        decoration: inputStyle("Height")),
                    const SizedBox(height: 10),

                    TextField(controller: weight,
                        decoration: inputStyle("Weight")),
                  ],

                  // -------- Doctor Fields --------
                  if (userType == "Doctor") ...[
                    TextField(controller: qualification,
                        decoration: inputStyle("Qualification")),
                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      hint: const Text("Specialization"),
                      value: category,
                      decoration: inputStyle(""),
                      items: categories.map((c) =>
                          DropdownMenuItem(
                              value: c, child: Text(c))).toList(),
                      onChanged: (v) => category = v,
                    ),

                    const SizedBox(height: 10),

                    TextField(controller: experience,
                        decoration: inputStyle("Experience")),
                  ],

                  const SizedBox(height: 20),

                  // -------- Signup Button --------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF0064FA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: signup,
                      child: const Text("Create Account",style: TextStyle(),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Signup Logic ----------
  Future<void> signup() async {

    setState(() => loading = true);

    try {

      UserCredential cred =
      await auth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim());

      String uid = cred.user!.uid;

      Map<String, dynamic> data = {
        "uid": uid,
        "name": name.text,
        "email": email.text,
        "phone": phone.text,
        "city": city ?? "",
        "userType": userType,
      };

      if (userType == "Patient") {
        data["age"] = age.text;
        data["height"] = height.text;
        data["weight"] = weight.text;
      }
      else {
        data["qualification"] = qualification.text;
        data["experience"] = experience.text;
        data["category"] = category ?? "";
      }

      await db.child(userType == "Doctor"
          ? "Doctors"
          : "Patients")
          .child(uid)
          .set(data);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
              userType == "Doctor"
                  ? DoctorHome()
                  : PatientHomePage()));

    }
    catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => loading = false);
  }
}