import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = doctor['name'] ?? 'Doctor';
    final initials = name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EDF5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF0064FA),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor['category'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}