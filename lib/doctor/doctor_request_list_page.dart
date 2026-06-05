import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorRequestListPage extends StatefulWidget {
  const DoctorRequestListPage({super.key});

  @override
  State<DoctorRequestListPage> createState() => _DoctorRequestListPageState();
}

class _DoctorRequestListPageState extends State<DoctorRequestListPage> {
  final db = FirebaseDatabase.instance.ref('Requests');
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await db.orderByChild('doctorId').equalTo(user.uid).get();
      requests.clear();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        requests = data.entries.map((e) {
          final map = Map<String, dynamic>.from(e.value);
          map['id'] = e.key;
          return map;
        }).toList();
        requests.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
      }
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      await db.child(id).update({
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      await fetchRequests();
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    if (status == 'approved') return const Color(0xFF16A34A);
    if (status == 'rejected') return const Color(0xFFDC2626);
    return const Color(0xFFD97706);
  }

  Color _statusBg(String status) {
    if (status == 'approved') return const Color(0xFFDCFCE7);
    if (status == 'rejected') return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7);
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
          'Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(
              0xFF000000)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF6B7280), size: 22),
            onPressed: fetchRequests,
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
          : requests.isEmpty
          ? const Center(
        child: Text('No requests yet', style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF))),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: requests.length,
        itemBuilder: (_, i) {
          final r = requests[i];
          final status = r['status']?.toString().toLowerCase() ?? 'pending';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${r['date'] ?? ''} · ${r['time'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient: ${r['patientName'] ?? r['doctorName'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),

                // Action buttons — only for pending
                if (status == 'pending') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE8EDF5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => updateStatus(r['id'], 'rejected'),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => updateStatus(r['id'], 'approved'),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}