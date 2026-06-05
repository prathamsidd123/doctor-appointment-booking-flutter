import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widget/doctor_card.dart';
import 'package:dlivehealthy/doctor/doctor_details.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final db = FirebaseDatabase.instance.ref("Doctors");
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final snapshot = await db.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        doctors = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value);
          map['uid'] = map['uid'] ?? e.key.toString();
          return map;
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Doctors',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EDF5)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0064FA), strokeWidth: 2))
          : doctors.isEmpty
          ? const Center(
        child: Text('No doctors found',
            style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF))),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: doctors.length,
        itemBuilder: (_, i) => DoctorCard(
          doctor: doctors[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorDetailsPage(doctor: doctors[i]),
            ),
          ),
        ),
      ),
    );
  }
}