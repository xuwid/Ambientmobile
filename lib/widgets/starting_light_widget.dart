import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartingLightWidget extends StatefulWidget {
  final Color containerColor;
  final double containerWidth;
  final double containerHeight;
  final int initialValue;
  final int maxValue; // Maximum value boundary
  final String title;
  final ValueChanged<int>? onValueChanged; // Callback for value changes
  final ValueChanged<int>? onEndingLightValueChanged;

  const StartingLightWidget(
      {super.key,
      required this.title,
      this.containerColor = Colors.purple,
      this.containerWidth = 210.0,
      this.containerHeight = 50.0,
      this.initialValue = 1,
      this.maxValue = 1000, // Set a default maximum value
      this.onValueChanged,
      this.onEndingLightValueChanged // Initialize the callback
      });

  @override
  _StartingLightWidgetState createState() => _StartingLightWidgetState();
}

class _StartingLightWidgetState extends State<StartingLightWidget> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    setState(() {
      if (_value < widget.maxValue) {
        // Check the boundary
        _value++;
        widget.onValueChanged?.call(_value); // Notify parent about value change
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_value > 0) {
        _value--;
        widget.onValueChanged?.call(_value); // Notify parent about value change
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            widget.title,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: widget.containerWidth,
            height: widget.containerHeight,
            decoration: BoxDecoration(
              color: widget.containerColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                // Subtraction Button
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: _decrement,
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Text(
                        '$_value',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Addition Button
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _increment,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
