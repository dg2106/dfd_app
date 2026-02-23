import 'package:flutter/material.dart';
import 'package:flutter_project/pages/chatpage2.dart';
import '../pages/scan_page.dart';
import '../pages/history_page.dart';
import '../pages/footcaretips_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = const [
    ScanPage(),
    HistoryPage(),
    HealthTipsPage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Added this part also. can ask chatcha to clean
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),

        // ✅ Hide bottom nav when keyboard is open
        //Remove if no chat box
        bottomNavigationBar: keyboardOpen
          ? const SizedBox.shrink()
          : NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTap,
            destinations: const [
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Tips'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'AI Chat'),
         ],
        ),
    );
  }
}