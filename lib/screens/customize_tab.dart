import 'dart:ui';
import 'package:ambient/screens/effects.dart';
import 'package:ambient/widgets/menu_buttons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/widgets/starting_light_widget.dart';
import 'package:ambient/widgets/color_picker.dart';

class CustomizeTab extends StatefulWidget {
  const CustomizeTab({super.key});

  @override
  _CustomizeTabState createState() => _CustomizeTabState();
}

class _CustomizeTabState extends State<CustomizeTab> {
  final TextEditingController _saveButtonController = TextEditingController();
  int _selectedLedIndex = 0; // Track selected LED
  List<LED> _leds = []; // List of LEDs
  bool isWhite = false;
  Effect _selectedEffect = Effect(name: 'Static');
  Zone? _selectedZone;
  bool _showInputField = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default number of LEDs
    _leds = List.generate(
      12,
      (index) => LED(
        ledNumber: index,
        color: Colors.green,
        brightness: 1.0,
        saturation: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLED =
        _selectedLedIndex >= 0 && _selectedLedIndex < _leds.length
            ? _leds[_selectedLedIndex]
            : null;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
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
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.grey),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Center(
                                child: Text(
                                  titleText,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
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
                      OutlinedButton(
                        onPressed: () {
                          _showBottomSheetMenu(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          side: BorderSide(
                            color: const Color(0xFF8A2BE2)
                                .withOpacity(0.5)
                                .withBlue(200),
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          _selectedZone?.title ?? 'Select Zone',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
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
                ),
                const SizedBox(height: 20),
                // Conditionally show LED selection if a zone is selected
                if (_selectedZone != null) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(_selectedZone!.leds.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLedIndex = index;

                              debugPrint('Selected LED: $_selectedLedIndex');
                            });
                            showColorPicker(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _leds.length > index
                                  ? _leds[index].color
                                  : Colors.green,
                              shape: BoxShape.circle,
                              border: _selectedLedIndex == index
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StartingLightWidget(
                    title: '',
                    initialValue: _selectedLedIndex,
                    maxValue: _selectedZone!.leds.length - 1,
                    onValueChanged: (newValue) {
                      setState(() {
                        // Ensure the new value does not exceed the number of LEDs
                        _selectedLedIndex = newValue;
                      });
                    },
                    onEndingLightValueChanged: (value) {
                      setState(() {
                        _selectedLedIndex = value;
                      });
                    },
                  ),
                  if (selectedLED != null) ...[
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isWhite = !isWhite;
                              if (isWhite) {
                                _leds[_selectedLedIndex] = selectedLED.copyWith(
                                  color: Colors.white,
                                  brightness: 1.0,
                                  saturation: 0.0,
                                );
                              } else {
                                _leds[_selectedLedIndex] = selectedLED.copyWith(
                                  color: Colors.green,
                                  brightness: 1.0,
                                  saturation: 1.0,
                                );
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
                    Expanded(
                      child: Center(
                        child: ColorPicker(
                          size: 230,
                          initialColor: selectedLED.color,
                          initialBrightness: selectedLED.brightness,
                          initialSaturation: selectedLED.saturation,
                          whiteLight: isWhite,
                          onBrightnessChanged: (brightness) {
                            setState(() {
                              if (_leds.length > _selectedLedIndex) {
                                _leds[_selectedLedIndex] = selectedLED.copyWith(
                                  brightness: brightness,
                                );
                              }
                            });
                          },
                          onSaturationChanged: (saturation) {
                            setState(() {
                              if (_leds.length > _selectedLedIndex) {
                                _leds[_selectedLedIndex] = selectedLED.copyWith(
                                  saturation: saturation,
                                );
                              }
                            });
                          },
                          onColorChanged: (color) {
                            setState(() {
                              if (_leds.length > _selectedLedIndex) {
                                final newBrightness = color
                                    .computeLuminance(); // Compute new brightness
                                final newSaturation = HSVColor.fromColor(color)
                                    .saturation; // Compute new saturation

                                _leds[_selectedLedIndex] = selectedLED.copyWith(
                                  color: color,
                                  brightness: newBrightness,
                                  saturation: newSaturation,
                                );

                                // Also call the brightness and saturation callbacks
                                if (selectedLED.brightness != newBrightness) {
                                  _leds[_selectedLedIndex] =
                                      selectedLED.copyWith(
                                    brightness: newBrightness,
                                  );
                                }
                                if (selectedLED.saturation != newSaturation) {
                                  _leds[_selectedLedIndex] =
                                      selectedLED.copyWith(
                                    saturation: newSaturation,
                                  );
                                }
                              }
                            });
                          },
                        ),
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

  Effect onEffectSelected(Effect effect) {
    setState(() {
      _selectedEffect = effect;
    });
    return effect;
  }

  void showColorPicker(BuildContext context) {}
  void _saveScene(BuildContext context) {
    if (_selectedZone != null) {
      final scene = Scene(
        name: _saveButtonController.text.trim(),
        ledSettings: _leds.map((led) => led.copyWith()).toList(),
      );
      //display ledSetting
      scene.ledSettings.forEach((led) {
        debugPrint('LED ${led.ledNumber}: ${led.color}' +
            ' ${led.brightness}' +
            ' ${led.saturation}');
      });

      scene.activatedEffects = _selectedEffect;
      final homeState = Provider.of<HomeState>(context, listen: false);
      homeState.addSceneToZone(_selectedZone!.title, scene);

      debugPrint('Scene saved: ${scene.name} in zone: ${_selectedZone!.title}');
      debugPrint('Scene saved: ${scene.activatedEffects.name}');
    } else {
      debugPrint('No zone selected to save scene.');
    }
  }

  void _activateScene(Scene scene) {
    setState(() {
      for (int i = 0; i < _leds.length; i++) {
        _leds[i] = _leds[i].copyWith(
          color: scene.ledSettings[i].color,
          brightness: scene.ledSettings[i].brightness,
          saturation: scene.ledSettings[i].saturation,
        );
      }
    });
  }

  void _showBottomSheetMenu(BuildContext context) {
    final homeState = Provider.of<HomeState>(context, listen: false);
    final activeAreas = homeState.areas.where((area) => area.isActive).toList();
    final List<Zone> zones =
        activeAreas.isNotEmpty ? activeAreas.first.zones : [];

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
                    ...zones.map((zone) {
                      return ListTile(
                        title: Center(
                          child: Text(
                            zone.title,
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedZone = zone;
                            _leds = List.generate(
                              _selectedZone!.leds.length,
                              (index) => LED(
                                ledNumber: index,
                                color: Colors.green,
                                brightness: 1.0,
                                saturation: 1.0,
                              ),
                            );
                          });
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
              // Centered Dialog content
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
