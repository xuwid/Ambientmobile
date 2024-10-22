import 'package:flutter/material.dart';

class LEDWidget extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const LEDWidget({
    Key? key,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 39, // Diameter of the LED
        height: 30, // Diameter of the LED
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 1 : 0, // Set border width for selected LED
          ),
        ),
      ),
    );
  }
}
