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
        BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_sharp),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              label: 'Scenes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_sharp),
              label: 'Customize',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
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
        // Custom purple circular rectangle indicator
        Positioned(
          bottom:
              55, // Adjust the bottom position to place the indicator higher
          left: selectedIndex * (MediaQuery.of(context).size.width / 4) +
              8, // Adjust position
          child: Container(
            width: MediaQuery.of(context).size.width / 4 -
                16, // Adjust width to fit tab
            height:
                8, // Adjust height for the top part of the circular rectangle
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
