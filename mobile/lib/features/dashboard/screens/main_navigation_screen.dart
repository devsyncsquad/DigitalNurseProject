import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'home_dashboard_screen.dart';
import '../../medication/screens/medicine_list_screen.dart';
import '../../health/screens/vitals_list_screen.dart';
import '../../documents/screens/document_list_screen.dart';
import '../../profile/screens/profile_view_screen.dart';
import 'dart:io';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    MedicineListScreen(),
    VitalsListScreen(),
    DocumentListScreen(),
    ProfileViewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Always intercept back button
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (_currentIndex == 0) {
            // Show exit confirmation dialog when on Home tab
            final shouldExit = await _showExitDialog(context);
            if (shouldExit == true) {
              exit(0); // Exit the app
            }
          } else {
            // Navigate back to Home tab from other tabs
            setState(() {
              _currentIndex = 0;
            });
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false, // Let the bottom nav bar handle its own safe area
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
        bottomNavigationBar: SafeArea(
          child: FBottomNavigationBar(
            index: _currentIndex,
            onChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.house),
                label: const Text('Home'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.pill),
                label: const Text('Medicines'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.activity),
                label: const Text('Health'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.fileText),
                label: const Text('Documents'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.user),
                label: const Text('Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
