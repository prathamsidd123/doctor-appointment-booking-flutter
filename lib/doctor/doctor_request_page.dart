import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorRequestPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorRequestPage({super.key, required this.doctor});

  @override
  State<DoctorRequestPage> createState() => _DoctorRequestPageState();
}

class _DoctorRequestPageState extends State<DoctorRequestPage> {
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> sendRequest() async {
    if (_descController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseDatabase.instance.ref('Requests').push();

      await ref.set({
        'sender': uid,
        'doctorId': widget.doctor['uid'] ?? '',
        'doctorName': widget.doctor['name'] ?? '',
        'description': _descController.text.trim(),
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0064FA), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Book appointment',
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
            // Doctor info chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Color(0xFF0064FA)),
                  const SizedBox(width: 8),
                  Text(
                    widget.doctor['name'] ?? 'Doctor',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0064FA),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ${widget.doctor['category'] ?? ''}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecor('Describe your issue', Icons.notes_outlined),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: _inputDecor('Select date', Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF0064FA)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  _dateController.text =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: _inputDecor('Select time', Icons.access_time_outlined),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF0064FA)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  _timeController.text = picked.format(context);
                }
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0064FA),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFB3CEFD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Send request',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}