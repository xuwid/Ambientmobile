import 'package:ambient/screens/scene.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/my_scene_screen.dart';

class Roofline extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RooflineState();
  }
}

class _RooflineState extends State<Roofline> {
  String selectedOption = 'Type of IC Setting';
  bool isOpen = true;

  final List<String> events = [
    'Accent Lighting',
    'New Years',
    'Valentines Day',
    'St. Patrick’s Day',
    'Easter',
    'America',
    'Halloween',
    'Thanksgiving',
    'Christmas Spectacular',
    'Sports Teams',
    'My Scenes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Keeps the bottom navigation bar unaffected
      body: BackgroundWidget(
        konsa: true,
        child: SafeArea(
          child: Column(
            children: [
              // Add padding around the AppBar content
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Add padding to the AppBar
                child: Consumer<HomeState>(
                  builder: (context, homeState, child) {
                    final activeAreas =
                        homeState.areas.where((area) => area.isActive).toList();

                    String titleText;
                    if (activeAreas.isEmpty) {
                      titleText = 'Scenes';
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

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            titleText,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Expanded content with padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Horizontal padding for list content
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (events[index] == 'My Scenes') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyScenesScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChristmasSpectacular(
                                  selectedEvent: events[index],
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: 370,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0x40000000),
                            borderRadius: BorderRadius.circular(15),
                            border: const Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  events[index],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
    );
  }
}
