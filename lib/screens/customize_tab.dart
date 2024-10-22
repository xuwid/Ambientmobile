import 'dart:ui';
import 'package:ambient/screens/effects.dart';
import 'package:ambient/widgets/led_widget.dart';
import 'package:ambient/widgets/menu_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/widgets/starting_light_widget.dart';
import 'package:ambient/widgets/color_picker.dart';
import 'package:ambient/widgets/circle_color_picker.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CustomizeTab extends StatefulWidget {
  String? selectedEvent;
  bool admin;
  CustomizeTab({super.key, this.selectedEvent, this.admin = false});

  @override
  _CustomizeTabState createState() => _CustomizeTabState();
}

class _CustomizeTabState extends State<CustomizeTab> {
  final TextEditingController _saveButtonController = TextEditingController();
  int _selectedLedIndex = 0; // Track selected LED
  List<LED> _leds = []; // List of LEDs
  Scene? scene = Scene();
  bool isWhite = false;
  String _selectedEffect = 'Static';
  Area? _selectedArea;
  CircleColorPickerController colorPickerController =
      CircleColorPickerController();
  double brightness = 0.5;
  double saturation = 1.0;
  Color selectedColor = const Color(0xFF3EFF20);

  @override
  void initState() {
    super.initState();
    _leds = List.generate(
      3,
      (index) => LED(index: index, color: const Color(0xFF3EFF20)),
    );
    scene!.setPatternID(Provider.of<HomeState>(context, listen: false)
        .convertEventToPatternId(_selectedEffect)); //
    selectedColor = _leds[_selectedLedIndex].color;
  }

  void _addLED() {
    setState(() {
      _leds.add(LED(
        index: _leds.length,
        color: const Color(0xFF3EFF20),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    HSLColor hslColor = HSLColor.fromColor(selectedColor);

    selectedColor =
        hslColor.withSaturation(saturation).withLightness(brightness).toColor();

    final selectedLED =
        _selectedLedIndex >= 0 && _selectedLedIndex < _leds.length
            ? _leds[_selectedLedIndex]
            : null;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: const Color(0xFF161616)),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Consumer<HomeState>(
                  builder: (context, homeState, child) {
                    final activeAreas =
                        homeState.areas.where((area) => area.isActive).toList();

                    String titleText;
                    if (activeAreas.isEmpty) {
                      titleText = 'Customize';
                    } else {
                      final titles = activeAreas
                          .take(2)
                          .map((area) => area.title)
                          .toList();
                      if (activeAreas.length > 2) {
                        titles.add('...');
                      }
                      titleText = titles.join(', ');
                    }

                    return AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: 80,
                      flexibleSpace: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.0),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            const Spacer(),
                            Text(
                              "Customize",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Spacer()
                          ],
                        ),
                      ),
                      centerTitle: true,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!widget.admin)
                        Container(
                          height: 40,
                          width: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC11687),
                                Color(0xFFA427CA),
                                Color(0xFF42E2FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                24), // Adjust for button shape
                          ),
                          padding: const EdgeInsets.all(
                              1.0), // This creates the gradient border
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFF161616), // Solid black inner background
                              borderRadius: BorderRadius.circular(
                                  24), // Same radius as the outer container
                            ),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Keep transparent to show inner container
                                side: const BorderSide(
                                  color: Colors
                                      .transparent, // No direct border since the outer container handles it
                                  width: 2.0,
                                ),
                              ),
                              onPressed: () {
                                _showBottomSheetMenu(context);
                              },
                              child: Text(
                                _selectedArea?.title ?? 'Select Area',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          _showSaveSceneDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Make a list of leds here,
                ),
                if (_selectedArea != null || widget.admin)
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._leds.map((led) {
                                int index = _leds.indexOf(led);
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LEDWidget(
                                    color: led.color,
                                    isSelected: _selectedLedIndex ==
                                        index, // Set the color of the LED
                                    onTap: () {
                                      setState(() {
                                        _selectedLedIndex = index;
                                        selectedColor =
                                            _leds[_selectedLedIndex].color;
                                      });
                                      //
                                    },
                                  ),
                                );
                              }).toList(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: _addLED,
                                  child: const CircleAvatar(
                                    radius: 25,
                                    backgroundColor:
                                        Colors.blue, // Color for the plus sign
                                    child: const Text(
                                      '+',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_selectedArea != null || widget.admin)
                  StartingLightWidget(
                    cs: true,
                    initialValue: _selectedLedIndex + 1,
                    title: "",
                    containerWidth: 180,
                    containerHeight: 50,
                    maxValue: _leds.length,
                    onValueChanged: (value) => setState(() {
                      _selectedLedIndex = value - 1;
                      selectedColor = _leds[_selectedLedIndex].color;
                    }),
                  ),
                const SizedBox(height: 5),
                if (_selectedArea != null || widget.admin) ...[
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedLED != null || widget.admin) ...[
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isWhite = !isWhite;
                              if (isWhite) {
                                _leds[_selectedLedIndex].color =
                                    selectedColor.withOpacity(brightness);
                              } else {
                                _leds[_selectedLedIndex].color = selectedColor;
                              }
                            });
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(isWhite
                                    ? 'assets/rgb.png'
                                    : 'assets/whitelight.png'),
                                radius: 16,
                              ),
                              Text(
                                !isWhite ? 'White Light' : 'RGB Light',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Effects(onEffectSelected: onEffectSelected),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/effects.png'),
                                radius: 16,
                              ),
                              Text(
                                'Effects',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DeferredPointerHandler(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Circular Brightness Slider
                          Positioned(
                            top: -32,
                            left: 0,
                            right: 0,
                            child: DeferPointer(
                              child: SleekCircularSlider(
                                appearance: CircularSliderAppearance(
                                  customColors: CustomSliderColors(
                                    trackColor: Colors.grey,
                                    progressBarColor: Colors.white,
                                    shadowColor: Colors.white.withOpacity(0.5),
                                    shadowMaxOpacity: 0.2,
                                    shadowStep: 10.0,
                                  ),
                                  customWidths: CustomSliderWidths(
                                    trackWidth: 2,
                                    progressBarWidth: 2,
                                    handlerSize: 12,
                                  ),
                                  size: 250, // Adjusted size
                                  startAngle: 220,
                                  angleRange: 100,
                                ),
                                min: 0,
                                max: 1,
                                initialValue: brightness,
                                onChange: (double value) {
                                  setState(() {
                                    brightness = value;
                                    isWhite
                                        ? colorPickerController.selectedColor =
                                            colorPickerController.selectedColor
                                                .withOpacity(brightness)
                                        : null;
                                    _leds[_selectedLedIndex].color = isWhite
                                        ? colorPickerController.selectedColor
                                            .withOpacity(brightness)
                                        : selectedColor;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Circular Saturation Slider
                          Visibility(
                            visible: !isWhite,
                            child: Positioned(
                              bottom: -34,
                              left: 0,
                              right: 0,
                              child: DeferPointer(
                                child: SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                    customColors: CustomSliderColors(
                                      trackColor: Colors.grey,
                                      progressBarColor: Colors.white,
                                      shadowColor:
                                          Colors.white.withOpacity(0.5),
                                      shadowMaxOpacity: 0.2,
                                      shadowStep: 10.0,
                                    ),
                                    customWidths: CustomSliderWidths(
                                      trackWidth: 2,
                                      progressBarWidth: 2,
                                      handlerSize: 12,
                                    ),
                                    size: 250, // Adjusted size
                                    startAngle: 40,
                                    angleRange: 100,
                                  ),
                                  min: 0,
                                  max: 1,
                                  initialValue: saturation,
                                  onChange: (double value) {
                                    setState(() {
                                      saturation = value;
                                      _leds[_selectedLedIndex].color =
                                          selectedColor;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !isWhite,
                            child: const Positioned(
                              bottom: -20,
                              child: Text('Saturation',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const Positioned(
                            top: -20,
                            child: Text('Brightness',
                                style: TextStyle(color: Colors.white)),
                          ),
                          DeferPointer(
                            child: CircleColorPicker(
                              isWhiteLight: isWhite,
                              controller: colorPickerController,
                              colors: !isWhite
                                  ? const [
                                      Color.fromARGB(255, 255, 0, 0),
                                      Color.fromARGB(255, 255, 255, 0),
                                      Color.fromARGB(255, 0, 255, 0),
                                      Color.fromARGB(255, 0, 255, 255),
                                      Color.fromARGB(255, 0, 0, 255),
                                      Color.fromARGB(255, 255, 0, 255),
                                      Color.fromARGB(255, 255, 0, 0),
                                    ]
                                  : const [
                                      Color(0xFFFFC58F),
                                      Color(0xFFFFFFFF),
                                      Color(0xFFC9E2FF),
                                      Color(0xFFFFC58F),
                                    ],
                              onChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                  colorPickerController.color = color;
                                  _leds[_selectedLedIndex].color = isWhite
                                      ? colorPickerController.selectedColor
                                          .withOpacity(brightness)
                                      : selectedColor;
                                });
                              },
                              size: const Size(250, 250), // Reduced size
                              strokeWidth: 10,
                              thumbSize: 30,
                            ),
                          ),
                          Positioned(
                            top: (220 - 200 + 90) /
                                2, // Centered based on color picker size
                            left: (220 - 200 + 90) /
                                2, // Centered based on color picker size
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isWhite
                                        ? colorPickerController.selectedColor
                                            .withOpacity(0.4)
                                        : selectedColor.withOpacity(0.4),
                                    spreadRadius: 7,
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: isWhite
                                      ? colorPickerController.selectedColor
                                      : selectedColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String onEffectSelected(String effect) {
    setState(() {
      _selectedEffect = effect;
    });
    scene!.setPatternID(Provider.of<HomeState>(context, listen: false)
        .convertEventToPatternId(effect));
    print(scene!.patternID);
    return effect;
  }

  void showColorPicker(BuildContext context) {}
  void _saveScene(BuildContext context) async {
    if (_selectedArea != null || widget.admin) {
      final homeState = Provider.of<HomeState>(context, listen: false);
      if (_saveButtonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a name for the scene'),
          ),
        );
        return;
      } else {
        // Set the scene name and colors
        scene!.setName(_saveButtonController.text);
        scene!.setColors(_leds.map((led) => led.color.value).toList());

        // Save scene to the user's current area (if not admin)
        if (!widget.admin) {
          homeState.addSceneToCurrentArea(scene!);
        }

        // If admin, save the scene in the `sharedEvents` folder using arrayUnion
        if (widget.admin) {
          try {
            final firestore = FirebaseFirestore.instance;

            // Reference to the selected event document
            final eventDocRef =
                firestore.collection('sharedEvents').doc(widget.selectedEvent);

            // Check if the event (folder) exists
            final eventSnapshot = await eventDocRef.get();

            // Create the document if it doesn't exist
            if (!eventSnapshot.exists) {
              await eventDocRef.set({
                'name': widget.selectedEvent,
                'createdAt': FieldValue
                    .serverTimestamp(), // Optional timestamp for creation
                'scenes': [], // Initialize the scenes array
              });
            }

            // Add the scene to the `scenes` array using FieldValue.arrayUnion
            await eventDocRef.update({
              'scenes': FieldValue.arrayUnion(
                  [scene!.toMap()]), // Convert scene to a map for storage
            });

            print(
                'Scene added to Firestore in shared event: ${widget.selectedEvent}');

            // Notify the user of successful save
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Scene saved successfully in shared events'),
              ),
            );
          } catch (e) {
            // Handle Firestore errors
            print('Error saving scene to shared events: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save scene to shared events'),
              ),
            );
          }
        }
      }
    }
  }

  void _showBottomSheetMenu(BuildContext context) {
    final homeState = Provider.of<HomeState>(context, listen: false);
    final Areas = homeState.areas;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 54, 51, 51),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...Areas.map((Areesf) {
                      return ListTile(
                        title: Center(
                          child: Text(
                            Areesf.title,
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedArea = Areesf;
                          });

                          homeState.setCurrentArea(Areesf);
                          print(homeState.currentArea!.id);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                    const Divider(color: Colors.white),
                    CancelButton(onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSaveSceneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Blur effect for the entire screen
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.0),
                  ),
                ),
              ),
              Center(
                child: Material(
                  color: Colors
                      .transparent, // Make Material background transparent
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Save this scene',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _saveButtonController,
                            decoration: InputDecoration(
                              hintText: 'Scene  Name',
                              hintStyle: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 18,
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white, size: 18),
                                  onPressed: () {
                                    _saveButtonController.clear();
                                  },
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _saveScene(context);
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            'Save Scene',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
