import 'package:flutter/material.dart';
import 'doctor_request_page.dart';

class DoctorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final name = doctor['name'] ?? 'Doctor';
    final initials = name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doctor details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EDF5)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF0064FA),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Text(doctor['category'] ?? '',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Category', value: doctor['category'] ?? '—'),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8EDF5)),
                  _InfoRow(label: 'City', value: doctor['city'] ?? '—'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DoctorRequestPage(doctor: doctor)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0064FA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Book appointment',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
        ],
      ),
    );
  }
}