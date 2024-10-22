import 'package:ambient/screens/scene.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';

class Effects extends StatefulWidget {
  final Function(String) onEffectSelected; // Callback function

  Effects({required this.onEffectSelected}); // Constructor with callback

  @override
  State<StatefulWidget> createState() {
    return _EffectsState();
  }
}

class _EffectsState extends State<Effects> {
  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<HomeState>(context);
    final List<String> events = homeState.events;

    return Scaffold(
      body: BackgroundWidget(
        konsa: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Consumer<HomeState>(
                  builder: (context, homeState, child) {
                    final activeAreas =
                        homeState.areas.where((area) => area.isActive).toList();

                    String titleText;
                    if (activeAreas.isEmpty) {
                      titleText = 'No Area is Selected';
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
                      flexibleSpace: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        margin: const EdgeInsets.all(16),
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
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.grey),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const Spacer(),
                            Text(
                              'Effects',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Spacer(),
                          ],
                        ),
                      ),
                      centerTitle: true,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _handleEffectSelection(events[index]);
                          Navigator.of(context).pop();
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleEffectSelection(String effectName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This scene has applied the "$effectName" effect.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Invoke the callback and navigate to the CustomizedScreen
    widget.onEffectSelected(effectName);
  }
}
