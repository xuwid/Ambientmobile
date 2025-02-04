import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/customize_tab.dart';
import 'package:flutter/material.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ChristmasSpectacular extends StatefulWidget {
  final String selectedEvent;

  ChristmasSpectacular({required this.selectedEvent});

  @override
  State<ChristmasSpectacular> createState() => _ChristmasSpectacularState();
}

class _ChristmasSpectacularState extends State<ChristmasSpectacular> {
  bool isAdmin = false;
  List<Map<String, dynamic>> scenes = []; // Store fetched scenes

  @override
  void initState() {
    super.initState();
    _fetchScenesAndUpdateUI();
  }

  Future<bool> _checkIfUserIsAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final firestore = FirebaseFirestore.instance;
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      isAdmin = userDoc.data()?['isAdmin'] ?? false;
      return userDoc.data()?['isAdmin'] ?? false;
    }
    return false;
  }

  Future<void> _fetchScenesAndUpdateUI() async {
    scenes = await _fetchSharedScenes();
    setState(() {}); // Update UI after fetching scenes
  }

  Future<List<Map<String, dynamic>>> _fetchSharedScenes() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('sharedEvents')
        .doc(widget.selectedEvent)
        .get();

    if (snapshot.exists && snapshot.data()?['scenes'] != null) {
      List<dynamic> scenes = snapshot.data()?['scenes'];
      return scenes.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _deleteScene(String sceneName) async {
    final firestore = FirebaseFirestore.instance;

    final snapshot = await firestore
        .collection('sharedEvents')
        .doc(widget.selectedEvent)
        .get();

    if (snapshot.exists) {
      List<dynamic> scenes = snapshot.data()?['scenes'] ?? [];
      scenes.removeWhere((scene) => scene['name'] == sceneName);

      await firestore
          .collection('sharedEvents')
          .doc(widget.selectedEvent)
          .update({'scenes': scenes});

      _fetchScenesAndUpdateUI(); // Refresh the UI after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: FutureBuilder<bool>(
                    future: _checkIfUserIsAdmin(),
                    builder: (context, snapshot) {
                      return Row(
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
                            widget.selectedEvent,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data == true)
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.grey),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomizeTab(
                                      admin: true,
                                      selectedEvent: widget.selectedEvent,
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh scenes after returning
                                  _fetchScenesAndUpdateUI(); // Refresh the UI
                                });
                                ;
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: scenes.isEmpty
                    ? const Center(
                        child: Text(
                          'No scenes available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Consumer<HomeState>(
                        builder: (context, homeState, child) {
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
                              final scene = scenes[index];
                              bool isActive =
                                  scene['name'] == homeState.activeScene;

                              return GestureDetector(
                                onTap: () {
                                  if (isActive) {
                                    homeState.setActiveScene(null);
                                  } else {
                                    homeState.setActiveSceneAdmin(
                                        Scene.fromMap(scene));
                                  }
                                },
                                onLongPress: () async {
                                  if (isAdmin) {
                                    final confirmDelete =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Scene'),
                                        content: const Text(
                                            'Are you sure you want to delete this scene?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmDelete == true) {
                                      await _deleteScene(scene['name']);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Scene "${scene['name']}" deleted'),
                                        ),
                                      );
                                    }
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
                                        scene['name'] ?? 'Unnamed Scene',
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
