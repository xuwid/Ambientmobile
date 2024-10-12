import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  bool konsa;
  BackgroundWidget({super.key, required this.child, this.konsa = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: konsa
              ? const ColoredBox(color: Color(0xFF161616))
              : Image.asset(
                  'assets/background.png', // Replace with your image asset
                  fit: BoxFit.cover,
                ),
        ),
        child,
      ],
    );
  }
}
