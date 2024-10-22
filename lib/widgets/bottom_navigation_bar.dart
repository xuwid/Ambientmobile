// lib/widgets/bottom_navigation_bar.dart
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Increase height using a Container around BottomNavigationBar
        Container(
          padding: const EdgeInsets.all(0),
          color: Colors.transparent,
          height: 90, // Increase height here
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
                  width: 25,
                  color: selectedIndex == 0
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/scenes_un.png",
                  width: 25,
                  color: selectedIndex == 1
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Scenes',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/customize_un.png",
                  width: 25,
                  color: selectedIndex == 2
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Customize',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/settings_un.png",
                  width: 25,
                  color: selectedIndex == 3
                      ? Colors.white
                      : const Color(0xFFBBBBBB),
                ),
                label: 'Settings',
              ),
            ],
            selectedLabelStyle: GoogleFonts.montserrat(
              color: Colors.white,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              color: Colors.white,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        // Custom purple circular rectangle indicator positioned just above the bottom navigation bar
        Positioned(
          bottom: 90, // Set to match the height of the BottomNavigationBar
          left: selectedIndex * (MediaQuery.of(context).size.width / 4) +
              27, // Adjust position
          child: Container(
            width: MediaQuery.of(context).size.width / 7 -
                16, // Adjust width to fit tab
            height:
                6, // Adjust height for the top part of the circular rectangle
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
