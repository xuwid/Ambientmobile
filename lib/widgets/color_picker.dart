import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(ColorPickerApp());

class ColorPickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          // Uncomment the below line to test the ColorPicker
          child: ColorPicker(
              size: 225,
              initialBrightness: 1.0,
              initialSaturation: 1.0,
              initialColor: Colors.white,
              onColorChanged: (color, brightness, sat) {},
              onBrightnessChanged: (value, d, dd) {},
              onSaturationChanged: (value, d, f) {},
              whiteLight: true),
        ),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final double size;
  final Color initialColor;
  final double initialBrightness;
  final double initialSaturation;
  final void Function(Color, double, double) onColorChanged;
  final void Function(double, double, Color) onBrightnessChanged;
  final void Function(double, Color, double) onSaturationChanged;
  final bool whiteLight;

  ColorPicker({
    this.whiteLight = false,
    required this.size,
    required this.initialBrightness,
    required this.initialSaturation,
    required this.initialColor,
    required this.onColorChanged,
    required this.onBrightnessChanged,
    required this.onSaturationChanged,
  });

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color selectedColor;
  double brightness = 1.0;
  double saturation = 1.0;
  double hue = 0.0;
  Offset selectorPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    final hsvColor = HSVColor.fromColor(selectedColor);
    hue = hsvColor.hue;

    saturation = widget.initialSaturation;
    brightness = widget.initialBrightness;
    _updateSelectorPosition(hue * pi / 180);
  }

  void resetToDefaults() {
    setState(() {
      selectedColor = Colors.green;
      brightness = 1.0;
      saturation = 1.0;
    });
    widget.onColorChanged(selectedColor, brightness, saturation);
    widget.onBrightnessChanged(brightness, saturation, selectedColor);
    widget.onSaturationChanged(saturation, selectedColor, brightness);
  }

  void _onColorChanged(Color color, double brightness, double saturation) {
    setState(() {
      selectedColor = color;
    });
    widget.onColorChanged(color, brightness, saturation);
  }

  void _onBrightnessChanged(double value, Color color, double saturation) {
    setState(() {
      brightness = value;
      if (widget.whiteLight) {
        // When whiteLight is true, only change the opacity based on brightness
        selectedColor = selectedColor.withOpacity(brightness);
      } else {
        // When whiteLight is false, adjust brightness normally
        selectedColor =
            HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
      }
    });
    widget.onBrightnessChanged(brightness, saturation, color);
  }

  void _onSaturationChanged(double saturation, Color color, double brightness) {
    setState(() {
      this.saturation = saturation;
      selectedColor = HSLColor.fromColor(selectedColor)
          .withSaturation(saturation)
          .toColor();
    });
    widget.onSaturationChanged(saturation, color, brightness);
  }

  void _updateSelectorPosition(double angle) {
    final ringWidth = 18.0;
    final ringRadius = (widget.size / 2) - 10.0;
    final middleRingRadius = ringRadius - ringWidth / 2;

    selectorPosition = Offset(
      widget.size / 2 + middleRingRadius * cos(angle),
      widget.size / 2 + middleRingRadius * sin(angle),
    );
  }

  void _updateColor(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final direction = position - center;
    final angle = atan2(direction.dy, direction.dx);
    hue = (angle * 180 / pi + 360) % 360;

    setState(() {
      if (widget.whiteLight) {
        // Calculate brightness based on the radial distance from the center
        final radius = direction.distance;
        final maxRadius = size.width / 2;
        final normalizedBrightness = (radius / maxRadius).clamp(0.0, 1.0);
        selectedColor = Colors.white.withOpacity(normalizedBrightness);
      } else {
        selectedColor =
            HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
      }
      widget.onColorChanged(selectedColor, brightness, saturation);
      _updateSelectorPosition(angle);
    });
  }

  void _updateBrightness(double value) {
    setState(() {
      brightness = value;
      if (widget.whiteLight) {
        selectedColor = selectedColor.withOpacity(brightness);
      } else {
        selectedColor =
            HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
      }
      widget.onBrightnessChanged(value, saturation, selectedColor);
    });
  }

  void _updateSaturation(double value) {
    setState(() {
      saturation = value;
      selectedColor =
          HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
      widget.onColorChanged(selectedColor, brightness, saturation);
      widget.onSaturationChanged(value, selectedColor, brightness);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CurvedSlider(
          startAngle: -pi,
          sweepAngle: pi,
          size: widget.size,
          value: brightness,
          onChanged: _updateBrightness,
          label: 'Brightness',
        ),
        GestureDetector(
          onPanUpdate: (details) {
            final localPosition = (context.findRenderObject() as RenderBox)
                .globalToLocal(details.globalPosition);
            _updateColor(localPosition, Size(widget.size, widget.size));
          },
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ColorWheelPainter(selectedColor, selectorPosition,
                widget.size, widget.whiteLight),
          ),
        ),
        if (!widget.whiteLight)
          CurvedSlider(
            startAngle: pi,
            sweepAngle: -pi,
            size: widget.size,
            value: saturation,
            onChanged: _updateSaturation,
            label: 'Saturation',
          ),
      ],
    );
  }
}

class CurvedSlider extends StatelessWidget {
  final double size;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final double startAngle; // Added
  final double sweepAngle; // Added

  CurvedSlider({
    required this.size,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.startAngle, // Updated
    required this.sweepAngle, // Updated
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size / 8, // Further reduced height to bring sliders closer
      child: CustomPaint(
        painter: CurvedSliderPainter(value, label, startAngle, sweepAngle),
        child: GestureDetector(
          onPanUpdate: (details) {
            final localPosition = (context.findRenderObject() as RenderBox)
                .globalToLocal(details.globalPosition);
            final x = localPosition.dx / size;
            final newValue = x.clamp(0.0, 1.0);
            onChanged(newValue);
          },
        ),
      ),
    );
  }
}

class CurvedSliderPainter extends CustomPainter {
  final double value;
  final String label;
  final double startAngle; // Added
  final double sweepAngle; // Added

  CurvedSliderPainter(this.value, this.label, this.startAngle, this.sweepAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final trackPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; // Reduced stroke width for the slider track

    final selectorRadius = 8.0; // Size of the selector

    final path = Path()..arcTo(rect, startAngle, sweepAngle, false); // Updated

    canvas.drawPath(path, trackPaint);

    // Calculate the selector position
    final selectorAngle = startAngle + sweepAngle * value;
    final selectorPosition = Offset(
      size.width / 2 + (size.width / 2) * cos(selectorAngle),
      size.height / 2 + (size.height / 2) * sin(selectorAngle),
    );

    final selectorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(selectorPosition, selectorRadius, selectorPaint);

    // Draw the label
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final textOffset = Offset(
      size.width / 2 - textPainter.width / 2,
      size.height - textPainter.height - 5, // Adjust for placement
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorWheelPainter extends CustomPainter {
  final Color selectedColor;
  final Offset selectorPosition;
  final double size;
  final bool whiteLight;
  ColorWheelPainter(
      this.selectedColor, this.selectorPosition, this.size, this.whiteLight);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringWidth = 18.0;
    final ringRadius = radius - ringWidth / 2 - 10;

    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: whiteLight
            ? [
                Colors.white24,
                Colors.white38,
                Colors.white54,
                Colors.white60,
                Colors.white70,
                Colors.white24
              ]
            : [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.cyan,
                Colors.blue,
                Colors.red
              ],
        stops: [0.0, 0.17, 0.33, 0.5, 0.67, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    canvas.drawCircle(center, ringRadius, ringPaint);

    final innerCircleRadius = ringRadius - ringWidth / 2 - 20;
    final innerCirclePaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3); // Adjust blur radius

    canvas.drawCircle(center, innerCircleRadius, innerCirclePaint);

    final selectorRadius = 8.0;
    final borderWidth = 1.25;

    final selectorPaint = Paint()
      ..color = selectedColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawCircle(selectorPosition, selectorRadius, selectorPaint);
    canvas.drawCircle(
        selectorPosition, selectorRadius + borderWidth / 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
