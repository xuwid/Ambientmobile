import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:google_fonts/google_fonts.dart';

class StartingLightWidget extends StatefulWidget {
  final Color containerColor;
  final double containerWidth;
  final double containerHeight;
  final int initialValue;
  final int maxValue; // Maximum value boundary
  final int minValue; // Minimum value boundary
  final String title;
  final ValueChanged<int>? onValueChanged; // Callback for value changes
  bool cs;

  StartingLightWidget({
    this.cs = false,
    super.key,
    required this.title,
    this.containerColor = Colors.purple,
    this.containerWidth = 210.0,
    this.containerHeight = 50.0,
    this.initialValue = 1,
    this.minValue = 1, // Default minimum value
    this.maxValue = 1000, // Set a default maximum value
    this.onValueChanged,
  });

  @override
  _StartingLightWidgetState createState() => _StartingLightWidgetState();
}

class _StartingLightWidgetState extends State<StartingLightWidget> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue =
        widget.initialValue; // Initialize with the passed initial value
  }

  // This method is called whenever the widget is rebuilt, and it checks for changes in the initialValue
  @override
  void didUpdateWidget(covariant StartingLightWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _currentValue =
            widget.initialValue; // Update current value if it has changed
      });
    }
  }

  void _increment() {
    setState(() {
      if (_currentValue < widget.maxValue) {
        _currentValue++;
        widget.onValueChanged?.call(_currentValue); // Notify parent
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue > widget.minValue) {
        _currentValue--;
        widget.onValueChanged?.call(_currentValue); // Notify parent
      }
    });
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: _currentValue.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Apply blur effect
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(
                255, 54, 51, 51), // Set background color to grey
            title: Text(
              'Enter Value for ${widget.title}',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white for visibility
              ),
            ),
            content: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Colors.white), // Set input text color to white
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                labelText: 'Enter a value',
                labelStyle: TextStyle(
                    color: Colors.white), // Set label text color to white
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    int? newValue = int.tryParse(_controller.text);
                    if (newValue == null ||
                        newValue < widget.minValue ||
                        newValue > widget.maxValue) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Value must be between ${widget.minValue} and ${widget.maxValue}.'),
                        ),
                      );
                    } else {
                      setState(() {
                        _currentValue = newValue;
                        widget.onValueChanged
                            ?.call(_currentValue); // Notify parent
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                        color: Colors.white), // Set button text color to white
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () =>
          _showInputDialog(context), // Long-press triggers keyboard input
      child: Column(
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
          if (!widget.cs) const SizedBox(height: 10),
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
                          '$_currentValue',
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
      ),
    );
  }
}
