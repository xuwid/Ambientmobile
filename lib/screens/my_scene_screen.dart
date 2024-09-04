import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/widgets/background_widget.dart';

class MyScenesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch scenes when the screen is first built
    Future.microtask(() {
      final homeState = Provider.of<HomeState>(context, listen: false);
      // Optionally set active areas before fetching scenes
      homeState.fetchScenes();
    });

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
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
                      Expanded(
                        child: Center(
                          child: Text(
                            'My Scenes',
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
              ),
              Expanded(
                child: Consumer<HomeState>(
                  builder: (context, homeState, child) {
                    final scenes = homeState.allScenes;
                    if (scenes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      itemCount: scenes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        Scene scene = scenes[index];
                        bool isActive = scene.name == homeState.activeScene;

                        return GestureDetector(
                          onTap: () {
                            if (isActive) {
                              // Deactivate the scene if it's already active
                              homeState.setActiveScene(null);
                            } else {
                              // Activate the selected scene
                              homeState.setActiveScene(scene);
                              // Display LED settings of a scene when it is selected
                              scene.ledSettings.forEach((led) {
                                debugPrint('LED ${led.ledNumber}: ${led.color} '
                                    '${led.brightness} ${led.saturation}');
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: isActive
                                    ? Border.all(
                                        color: Colors.purpleAccent,
                                        width: 3,
                                      )
                                    : Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                              ),
                              child: Center(
                                child: Text(
                                  scene.name,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
