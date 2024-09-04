import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';

class ControllerWidget extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function(bool)? onToggle;
  final int index; // Add index to determine the background image

  const ControllerWidget({
    Key? key,
    required this.title,
    required this.isActive,
    this.onToggle,
    required this.index, // Initialize index
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust width and height based on screen size
    final containerWidth = screenWidth * 0.9; // 90% of screen width
    final containerHeight = screenHeight * 0.1; // 10% of screen height

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01), // Margin relative to screen height
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Stack(
        children: [
          // Background image with blur effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    image: DecorationImage(
                      image: AssetImage(index % 2 == 0
                          ? 'assets/item_background1.jpg'
                          : 'assets/item_background2.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
          // Title and toggle
          Positioned(
            left: containerWidth *
                0.07, // Adjust left padding based on container width
            top: containerHeight *
                0.4, // Adjust top padding based on container height
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize:
                    screenHeight * 0.02, // Font size relative to screen height
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: containerWidth *
                0.07, // Adjust right padding based on container width
            top: containerHeight * 0.3, // Align toggle button with text
            child: Switch(
              value: isActive,
              onChanged: onToggle,
              activeColor: const Color(0xFFA427CA), // Matching active color
              inactiveThumbColor: Colors.white, // Matching thumb color
              inactiveTrackColor: Colors.grey, // Matching track color
              thumbIcon: MaterialStateProperty.all(
                Icon(Icons.circle,
                    size: 24, color: Colors.white), // Larger thumb size
              ),
              trackColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.purple
                        .withOpacity(0.5); // Matching track color when selected
                  }
                  return Colors.grey; // Matching track color when not selected
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
