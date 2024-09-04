import 'package:ambient/screens/area_screen.dart';
import 'package:ambient/screens/setting.dart';
import 'package:ambient/screens/timeZone.dart';
import 'package:ambient/screens/setting_tab.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ambient/screens/customize_tab.dart';

import 'package:ambient/screens/hometab.dart';
import 'scenes_tab.dart';
import 'setting_tab.dart';
import 'package:ambient/widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur effect if menu is open
          if (_isMenuOpen)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          // Main content
          _buildMainContent(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildMainContent() {
    // Switch between different tab content
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return Roofline();
      case 2:
        return const CustomizeTab();
      case 3:
        return SettingsPage();
      default:
        return const HomeTab();
    }
  }
}
