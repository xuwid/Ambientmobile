import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Total number of items
    const int itemCount = 4;
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic bar height: using a factor of the screen height,
    // but ensuring it doesn't go below 105.
    final barHeight = screenHeight * 0.12;

    // Compute image width as a fraction of screen width
    final imageWidth = screenWidth * 0.06; // e.g. ~24px on a 400px wide screen

    // Calculate each navigation item's width.
    final itemWidth = screenWidth / itemCount;
    // Set indicator width as a fraction of the item width.
    final indicatorWidth = itemWidth * 0.5;
    // Center the indicator above the current tab.
    final indicatorLeft =
        selectedIndex * itemWidth + (itemWidth - indicatorWidth) / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // BottomNavigationBar container
        Container(
          padding: const EdgeInsets.all(0),
          color: Colors.transparent,
          height: barHeight,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: onItemTapped,
            backgroundColor: const Color(0xFF161616).withOpacity(0.98),
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color(0xFFBBBBBB),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/home_un.png",
                  width: imageWidth,
                  color: selectedIndex == 0
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/scenes_un.png",
                  width: imageWidth,
                  color: selectedIndex == 1
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Scenes',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/customize_un.png",
                  width: imageWidth,
                  color: selectedIndex == 2
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Customize',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/settings_un.png",
                  width: imageWidth,
                  color: selectedIndex == 3
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Settings',
              ),
            ],
            selectedLabelStyle: GoogleFonts.montserrat(color: Colors.white),
            unselectedLabelStyle: GoogleFonts.montserrat(color: Colors.white),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        // Custom indicator positioned above the BottomNavigationBar
        Positioned(
          bottom: barHeight, // Align it with the top of the navigation bar
          left: indicatorLeft,
          child: Container(
            width: indicatorWidth,
            height: 6, // You may adjust this relative value if desired
            decoration: const BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
