import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/customize_tab.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyScenesScreen extends StatefulWidget {
  const MyScenesScreen({Key? key}) : super(key: key);

  @override
  State<MyScenesScreen> createState() => _MyScenesScreenState();
}

class _MyScenesScreenState extends State<MyScenesScreen> {
  // Helper method to refresh scenes and update the UI.
  Future<void> _fetchScenesAndUpdateUI() async {
    final homeState = Provider.of<HomeState>(context, listen: false);
    await homeState.fetchScenesForActivatedAreas();
    setState(() {}); // Rebuild UI with updated scenes.
  }

  // Edit a scene and refresh scenes after returning.
  Future<void> _editScene(BuildContext context, Scene scene) async {
    final homeState = Provider.of<HomeState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CustomizeTab(sceneToEdit: scene, admin: true, user: true),
      ),
    ).then((_) async {
      // Refresh scenes after returning from the edit screen.
      await _fetchScenesAndUpdateUI();
    });
  }

  Future<void> _deleteScene(BuildContext context, String sceneName) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        print('No user is logged in');
        return;
      }
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(currentUserId);

      // Get all activated areas for this user
      final areasSnapshot = await userDoc
          .collection('areas')
          .where('isActive', isEqualTo: true)
          .get();

      if (areasSnapshot.docs.isEmpty) {
        print('No activated areas found.');
        return;
      }

      bool deleted = false;
      // Loop through each activated area and remove the scene from its list
      for (var areaDoc in areasSnapshot.docs) {
        final data = areaDoc.data();
        List<dynamic>? scenesData = data['scenes'] as List<dynamic>?;
        if (scenesData != null && scenesData.isNotEmpty) {
          int initialLength = scenesData.length;
          scenesData.removeWhere((scene) => scene['name'] == sceneName);
          if (scenesData.length < initialLength) {
            await userDoc
                .collection('areas')
                .doc(areaDoc.id)
                .update({'scenes': scenesData});
            deleted = true;
          }
        }
      }

      if (deleted) {
        // Refresh the scenes list
        final homeState = Provider.of<HomeState>(context, listen: false);
        await homeState.fetchScenesForActivatedAreas();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scene "$sceneName" deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scene "$sceneName" not found')));
      }
    } catch (e) {
      print('Error deleting scene: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting scene')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch scenes when the screen is first built
    Future.microtask(() {
      final homeState = Provider.of<HomeState>(context, listen: false);
      homeState.fetchScenesForActivatedAreas();
    });

    return Scaffold(
      body: BackgroundWidget(
        konsa: true,
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
                      const Spacer(),
                      Text(
                        'My Scenes',
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                              homeState.setActiveScene(scene, "deactivate");
                            } else {
                              // Activate the selected scene
                              homeState.setActiveScene(scene, "activate");
                              print('Selected scene: ${scene.colors}');
                            }
                          },
                          onLongPress: () async {
                            final action = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Scene Options'),
                                content: const Text('Choose an action'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'edit'),
                                    child: const Text('Edit'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'delete'),
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );

                            if (action == 'delete') {
                              // Show a confirmation dialog on long press
                              final confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Scene'),
                                  content: const Text(
                                      'Are you sure you want to delete this scene?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                await _deleteScene(context, scene.name);
                              }
                            } else if (action == 'edit') {
                              Area? cArea = await homeState
                                  .fetchAreaForSceneName(scene.name);
                              print('Current Area: ${cArea!.title}');
                              homeState.setCurrentArea(cArea);
                              await _editScene(context, scene);
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
