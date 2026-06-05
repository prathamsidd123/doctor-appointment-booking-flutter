import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'doctor_request_list_page.dart';
import 'doctor_profile.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DoctorRequestListPage(),
    DoctorProfilePage(),
  ];

  // Tab data
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.list_alt_rounded, label: 'Requests'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();
    _itemControllers = List.generate(
      _navItems.length,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: i == 0 ? 1.0 : 0.0,
      ),
    );
    _scaleAnims = _itemControllers
        .map((c) => Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOut),
    ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _itemControllers[_selectedIndex].reverse();
    setState(() => _selectedIndex = index);
    _itemControllers[index].forward();
    HapticFeedback.lightImpact();
  }

  Future<void> _showExitDialog() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Exit App"),
        content: const Text("Do you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (exit == true) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FA),
        extendBody: true, // body extends under nav bar
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _pages[_selectedIndex],
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(
          selectedIndex: _selectedIndex,
          items: _navItems,
          scaleAnims: _scaleAnims,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Floating Nav Bar Widget
// ──────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final List<Animation<double>> scaleAnims;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.items,
    required this.scaleAnims,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.40),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final isSelected = selectedIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: ScaleTransition(
                  scale: scaleAnims[i],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          child: Icon(
                            items[i].icon,
                            size: isSelected ? 26 : 22,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 280),
                          style: TextStyle(
                            fontSize: isSelected ? 11 : 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            letterSpacing: 0.3,
                          ),
                          child: Text(items[i].label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Data class
// ──────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}