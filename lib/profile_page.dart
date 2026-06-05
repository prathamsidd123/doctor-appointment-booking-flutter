// Import required packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dlivehealthy/auth/login.dart';

// Profile Screen (Patient)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref('Requests');

  // Store booking data
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings(); // Load bookings on start
  }

  // Fetch bookings from Firebase
  Future<void> fetchBookings() async {
    try {
      final uid = _auth.currentUser?.uid;

      // If user not logged in
      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      // Get bookings where sender = current user
      final snapshot = await _db.orderByChild('sender').equalTo(uid).get();

      bookings.clear();

      // Convert Firebase data to list
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        bookings = data.values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Sort by latest bookings
        bookings.sort((a, b) =>
            (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
      }
    } catch (e) {
      print("ERROR: $e"); // Debug error
    }

    if (mounted) setState(() => isLoading = false);
  }

  // Logout function
  void logout() async {
    await _auth.signOut();

    if (!mounted) return;

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    // Define colors for consistent styling
    final primaryColor = Colors.indigo;
    final backgroundColor = Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.shade700),
            onPressed: () {
              setState(() => isLoading = true);
              fetchBookings();
            },
          ),
          // Logout button
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red.shade400),
            onPressed: logout,
          ),
        ],
      ),

      // Body
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : RefreshIndicator(
        onRefresh: fetchBookings,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            // Profile Header Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C6EF5), Color(0xFF3B5BDD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: user?.photoURL != null
                            ? ClipOval(
                          child: Image.network(user!.photoURL!, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Patient',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  user?.email ?? 'No Email',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bookings Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Bookings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${bookings.length} Requests",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bookings List
            if (bookings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final b = bookings[index];
                      final status = (b['status'] ?? 'pending').toString().toLowerCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            b['description'] ?? 'No Description',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Text(
                                  "${b['date'] ?? ''}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Text(
                                  "${b['time'] ?? ''}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: _buildStatusBadge(status),
                        ),
                      );
                    },
                    childCount: bookings.length,
                  ),
                ),
              ),
            // Add bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // Build Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your requests will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Return widget based on booking status
  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        icon = Icons.schedule;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}