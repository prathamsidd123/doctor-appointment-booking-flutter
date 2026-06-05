import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dlivehealthy/auth/login.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> doctorData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorProfile();
  }

  Future<void> fetchDoctorProfile() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('Doctors/${currentUser!.uid}')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          doctorData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        doctorData = {
          'name': 'Doctor',
          'category': 'Specialist',
          'city': 'Not set',
          'phone': 'Not set',
          'email': currentUser?.email ?? 'Not set',
        };
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = doctorData['name'] ?? 'Doctor';
    final initials = name.trim().split(' ').map((w) => (w as String)[0]).take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF6B7280), size: 22),
            onPressed: logout,
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EDF5)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0064FA), strokeWidth: 2))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2FF),
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0064FA),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctorData['category'] ?? 'Specialist',
              style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 2),
            Text(
              doctorData['city'] ?? 'City not set',
              style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
            ),

            const SizedBox(height: 24),

            // Info card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: doctorData['phone'] ?? 'Not provided',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8EDF5)),
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: doctorData['email'] ?? currentUser?.email ?? 'Not provided',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // // Edit button
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: OutlinedButton.icon(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Edit profile coming soon')),
            //       );
            //     },
            //     icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0064FA)),
            //     label: const Text(
            //       'Edit profile',
            //       style: TextStyle(
            //         fontSize: 15,
            //         fontWeight: FontWeight.w600,
            //         color: Color(0xFF0064FA),
            //       ),
            //     ),
            //     style: OutlinedButton.styleFrom(
            //       side: const BorderSide(color: Color(0xFF0064FA), width: 1),
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0064FA)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
            ],
          ),
        ],
      ),
    );
  }
}