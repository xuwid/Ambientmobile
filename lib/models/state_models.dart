import 'dart:ui';

import 'package:ambient/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LED {
  final int ledNumber;
  final Color color;
  final double brightness;
  final double saturation;

  LED({
    required this.ledNumber,
    required this.color,
    required this.brightness,
    required this.saturation,
  });

  LED copyWith({
    Color? color,
    double? brightness,
    double? saturation,
  }) {
    return LED(
      ledNumber: ledNumber,
      color: color ?? this.color,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
    );
  }

  // Converts LED instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'ledNumber': ledNumber,
      'color': color.value, // Converting Color to its integer value
      'brightness': brightness,
      'saturation': saturation,
    };
  }

  // Creates LED instance from a Map
  factory LED.fromMap(Map<String, dynamic> map) {
    return LED(
      ledNumber: map['ledNumber'],
      color: Color(map['color']), // Converting integer value back to Color
      brightness: map['brightness'],
      saturation: map['saturation'],
    );
  }
}

class Effect {
  final String name;

  const Effect({
    this.name = 'Static',
  });

  // Converts Effect instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // Creates Effect instance from a Map
  factory Effect.fromMap(Map<String, dynamic> map) {
    return Effect(
      name: map['name'] ?? 'Static',
    );
  }
}

class Scene {
  final String name;
  Effect activatedEffects;
  final List<LED> ledSettings;
  final bool isActive;

  Scene({
    this.activatedEffects = const Effect(),
    this.isActive = false,
    required this.name,
    required this.ledSettings,
  });

  void setEffect(Effect effect) {
    activatedEffects = effect;
  }

  // Converts Scene instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'activatedEffects': activatedEffects.toMap(),
      'ledSettings': ledSettings.map((led) => led.toMap()).toList(),
      'isActive': isActive,
    };
  }

  // Creates Scene instance from a Map
  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
      name: map['name'],
      activatedEffects: Effect.fromMap(map['activatedEffects']),
      ledSettings: List<LED>.from(
          map['ledSettings']?.map((led) => LED.fromMap(led)) ?? []),
      isActive: map['isActive'],
    );
  }
}

class Port {
  int startingValue;
  int endingValue;
  int portNumber;
  bool isEnable;

  Port({
    this.startingValue = 1,
    this.endingValue = 12,
    this.portNumber = 1,
    this.isEnable = false,
  });

  // Converts Port instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'startingValue': startingValue,
      'endingValue': endingValue,
      'portNumber': portNumber,
      'isEnable': isEnable,
    };
  }

  // Creates Port instance from a Map
  factory Port.fromMap(Map<String, dynamic> map) {
    return Port(
      startingValue: map['startingValue'],
      endingValue: map['endingValue'],
      portNumber: map['portNumber'],
      isEnable: map['isEnable'],
    );
  }
}

class Zone {
  static int _idCounter = 0; // Static counter for auto-incrementing IDs
  final int id;
  final String title;
  final List<Port> ports;
  final List<Scene> scenes;
  List<LED> leds;

  Zone({
    required this.title,
    List<Port>? ports,
    List<Scene>? scenes,
    List<LED>? leds,
    int ledCount = 15, // Default to 15 LEDs
  })  : id = _idCounter++,
        ports = ports ??
            List.generate(
                4,
                (index) => Port(
                    portNumber:
                        index + 1)), // Initialize ports with portNumbers 1-4
        scenes = scenes ?? [],
        leds = leds ??
            List.generate(
              ledCount,
              (index) => LED(
                ledNumber: index + 1,
                color: Colors.white,
                brightness: 1.0,
                saturation: 1.0,
              ),
            );

  // Convert a map to a Zone object
  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      title: map['title'],
      ports: List<Port>.from(
          map['ports']?.map((port) => Port.fromMap(port)) ?? []),
      scenes: List<Scene>.from(
          map['scenes']?.map((scene) => Scene.fromMap(scene)) ?? []),
      leds: List<LED>.from(map['leds']?.map((led) => LED.fromMap(led)) ?? []),
    );
  }

  // Convert Zone object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ports': ports.map((p) => p.toMap()).toList(),
      'scenes': scenes.map((s) => s.toMap()).toList(),
      'leds': leds.map((l) => l.toMap()).toList(),
    };
  }

  // Method to update port state
  void updatePortState(int portNumber, bool isEnable) {
    Port? port = ports.firstWhere((p) => p.portNumber == portNumber,
        orElse: () => Port(portNumber: portNumber));
    if (port != null) {
      port.isEnable = isEnable;
    }
  }

  // Method to get port state
  bool getPortState(int portNumber) {
    Port? port = ports.firstWhere((p) => p.portNumber == portNumber,
        orElse: () => Port(portNumber: portNumber));
    return port.isEnable;
  }

  void addScene(Scene scene) {
    scenes.add(scene);
  }

  // Method to set the number of LEDs
  void setLedCount(int newCount) {
    final currentCount = leds.length;
    if (newCount > currentCount) {
      // Add new LEDs
      leds.addAll(
        List.generate(
          newCount - currentCount,
          (index) => LED(
            ledNumber: currentCount + index + 1,
            color: Colors.white,
            brightness: 1.0,
            saturation: 1.0,
          ),
        ),
      );
    } else if (newCount < currentCount) {
      // Remove excess LEDs
      leds.removeRange(newCount, currentCount);
    }
  }
}

class Controller {
  static int _idCounter = 0; // Static counter for auto-incrementing IDs
  int id;
  final String name;
  bool isActive;

  Controller(this.name, {this.isActive = false}) : id = _idCounter++;

  // Factory constructor to create a Controller from Firestore document
  factory Controller.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Controller.fromMap(data);
  }

  // Convert a map to a Controller object
  factory Controller.fromMap(Map<String, dynamic> map) {
    return Controller(
      map['name'] as String,
      isActive: map['isActive'] as bool? ?? false,
    )..id = map['id'] as int; // Assign ID from the map
  }

  // Convert Controller object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }
}

class Area {
  String? id; // Nullable ID field
  late String title;
  List<Controller> controller;
  List<Zone> zones;
  bool isActive;

  Area({
    this.id, // ID is optional here
    required this.title,
    List<Controller>? controller,
    List<Zone>? zones,
    this.isActive = false,
  })  : controller = controller ?? [],
        zones = zones ?? [];

  Area copyWith({
    String? id,
    String? title,
    List<Controller>? controller,
    List<Zone>? zones,
  }) {
    return Area(
      id: id ?? this.id,
      title: title ?? this.title,
      controller: controller ?? this.controller,
      zones: zones ?? this.zones,
    );
  }

  factory Area.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Area(
      id: doc.id, // Use Firestore's document ID
      title: data['title'] ?? '',
      isActive: data['isActive'] ?? false,
      controller: List<Controller>.from(data['controllers']
              ?.map((controller) => Controller.fromMap(controller)) ??
          []),
      zones: List<Zone>.from(
          data['zones']?.map((zone) => Zone.fromMap(zone)) ?? []),
    );
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'], // ID may not be present in the map, handle accordingly
      title: map['title'] ?? '',
      isActive: map['isActive'] ?? false,
      controller: List<Controller>.from(map['controllers']
              ?.map((controller) => Controller.fromMap(controller)) ??
          []),
      zones: List<Zone>.from(
          map['zones']?.map((zone) => Zone.fromMap(zone)) ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include the ID in the map, even if it's null initially
      'title': title,
      'isActive': isActive,
      'controllers': controller.map((c) => c.toMap()).toList(),
      'zones': zones.map((z) => z.toMap()).toList(),
    };
  }

  Zone? findZoneByTitle(String title) {
    return zones.firstWhere((zone) => zone.title == title);
  }
}

class HomeState with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> events = [
    'Static',
    'Gradient',
    'Twinklecat',
    'Fairytwinkle',
    'Colorwaves',
    'Chase',
    'Breathe',
    'Lightning',
    'Meteor',
    'Multi Comet',
    'Pixels',
    'Rainbow',
    'Solid Glitter',
    'Wipe',
  ];

  List<Controller> _controllers = [
    Controller("Main"),
    Controller("Pool House"),
  ];

  List<Controller> get controllers => _controllers;
  Zone? _currentZone;

  Zone? get currentZone => _currentZone;

  Area? _currentArea;

  Area? get currentArea => _currentArea;
  List<Scene> get allScenesFromActivatedAreas {
    List<Scene> scenes = [];

    // Iterate through all areas and check if they are active
    for (var area in areas.where((area) => area.isActive)) {
      // For each active area, iterate through its zones
      for (var zone in area.zones) {
        // Add all scenes in the zone to the scenes list
        scenes.addAll(zone.scenes);
      }
    }

    return scenes; // Return the collected scenes
  }

  // List<Scene> get allScenesFromActivatedAreas {
  //   List<Scene> scenes = [];

  //   Future<void> fetchControllers() async {
  //     final snapshot = await _firestore.collection('controllers').get();
  //     _controllers =
  //         snapshot.docs.map((doc) => Controller.fromFirestore(doc)).toList();
  //     notifyListeners();
  //   }

  //   Future<void> fetchAreas() async {
  //     final snapshot = await _firestore.collection('areas').get();
  //     _areas = snapshot.docs.map((doc) => Area.fromFirestore(doc)).toList();
  //     notifyListeners();
  //   }

  //   Future<void> createArea(Area area) async {
  //     final docRef = _firestore.collection('areas').doc(area.id.toString());
  //     await docRef.set(area.toMap());
  //     _areas.add(area);
  //     notifyListeners();
  //   }

  //   Future<void> updateArea(Area area) async {
  //     final docRef = _firestore.collection('areas').doc(area.id.toString());
  //     await docRef.update(area.toMap());
  //     final index = _areas.indexWhere((a) => a.id == area.id);
  //     if (index != -1) {
  //       _areas[index] = area;
  //       notifyListeners();
  //     }
  //   }

  //   Future<void> removeArea(String areaId) async {
  //     await _firestore.collection('areas').doc(areaId).delete();
  //     _areas.removeWhere((area) => area.id.toString() == areaId);
  //     notifyListeners();
  //   }

  //   Future<void> addControllerToArea(
  //       String areaId, Controller controller) async {
  //     final docRef = _firestore.collection('areas').doc(areaId);
  //     await docRef.update({
  //       'controllers': FieldValue.arrayUnion([controller.toMap()])
  //     });
  //     notifyListeners();
  //   }

  //   Future<void> removeControllerFromArea(
  //       String areaId, Controller controller) async {
  //     final docRef = _firestore.collection('areas').doc(areaId);
  //     await docRef.update({
  //       'controllers': FieldValue.arrayRemove([controller.toMap()])
  //     });
  //     notifyListeners();
  //   }

  //   Future<void> addZoneToArea(String areaId, Zone zone) async {
  //     final docRef = _firestore.collection('areas').doc(areaId);
  //     await docRef.update({
  //       'zones': FieldValue.arrayUnion([zone.toMap()])
  //     });
  //     notifyListeners();
  //   }

  //   Future<void> updateZoneInArea(String areaId, Zone zone) async {
  //     final docRef = _firestore.collection('areas').doc(areaId);
  //     // Fetch the current document and update the zone
  //     final doc = await docRef.get();
  //     final data = doc.data()!;
  //     final zones = List<Map<String, dynamic>>.from(data['zones']);
  //     final zoneIndex = zones.indexWhere((z) => z['id'] == zone.id);
  //     if (zoneIndex != -1) {
  //       zones[zoneIndex] = zone.toMap();
  //       await docRef.update({'zones': zones});
  //     }
  //     notifyListeners();
  //   }

  //   Future<void> removeZoneFromArea(String areaId, Zone zone) async {
  //     final docRef = _firestore.collection('areas').doc(areaId);
  //     await docRef.update({
  //       'zones': FieldValue.arrayRemove([zone.toMap()])
  //     });
  //     notifyListeners();
  //   }

  //   // Iterate through all areas and check if they are active
  //   for (var area in areas.where((area) => area.isActive)) {
  //     // For each active area, iterate through its zones
  //     for (var zone in area.zones) {
  //       // Add all scenes in the zone to the scenes list
  //       scenes.addAll(zone.scenes);
  //     }
  //   }

  //   return scenes; // Return the collected scenes
  // }

  Future<void> getAreasForUser(String userId) async {
    print('Fetching areas for user: $userId');

    // Fetch the areas from Firestore
    final userDoc = _firestore.collection('users').doc(userId);
    final areasSnapshot = await userDoc.collection('areas').get();

    // Convert Firestore documents to Area objects
    List<Area> fetchedAreas = areasSnapshot.docs.map((doc) {
      return Area.fromMap(doc.data());
    }).toList();

    // Print the fetched areas for debugging
    print('Fetched areas:');
    for (var area in fetchedAreas) {
      print('Title: ${area.title}, Active: ${area.isActive}');
    }

    // Update the _areas list and notify listeners
    _areas = fetchedAreas;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Area> _areas = [
    Area(
        title: "Roofline",
        controller: [Controller("Main")],
        isActive: true,
        zones: [
          Zone(title: "Zone 1", ports: [
            Port(portNumber: 1, isEnable: true),
            Port(portNumber: 2, isEnable: false),
            Port(portNumber: 3, isEnable: false),
            Port(portNumber: 4, isEnable: false),
          ]),
        ]),
    Area(title: "Landscape Lights", controller: [Controller("Pool House")]),
  ];

  String? _selectedTimezone;
  String? _selectedLocation;

  String? get selectedTimezone => _selectedTimezone;
  String? get selectedLocation => _selectedLocation;
  List<Area> get areas => _areas;
  //zone Active by toggle
  List<Scene> _scenes = [];

  void addSceneToZone(String zoneTitle, Scene scene) {
    // Find the area that contains the specified zone
    final area = areas.firstWhere(
      (area) => area.zones.any((zone) => zone.title == zoneTitle),
      // orElse: () => null,
    );

    if (area != null) {
      final zone = area.zones.firstWhere(
        (zone) => zone.title == zoneTitle,
        //orElse: () => null,
      );

      if (zone != null) {
        zone.addScene(scene);
        notifyListeners();
      } else {
        debugPrint('Zone not found.');
      }
    } else {
      debugPrint('Area not found.');
    }
  }

  // Add a scene to the list
  void addScenetoZone(Zone zone, Scene scene) {
    zone.scenes.add(scene);
    notifyListeners();
  }

  void addScene(Scene scene) {
    _scenes.add(scene);
    notifyListeners();
  }

  // Update a scene
  void updateScene(Scene updatedScene) {
    final sceneIndex =
        _scenes.indexWhere((scene) => scene.name == updatedScene.name);
    if (sceneIndex != -1) {
      _scenes[sceneIndex] = updatedScene;
    } else {
      _scenes.add(updatedScene);
    }
    notifyListeners();
  }

  // // Get a scene by its name
  // Scene? getScene(String sceneName) {
  //   return _scenes.firstWhere((scene) => scene.name == sceneName,
  //       orElse: () => Scene(name: sceneName));
  // }

  // Remove a scene by its name
  void removeScene(String sceneName) {
    _scenes.removeWhere((scene) => scene.name == sceneName);
    notifyListeners();
  }

  List<Scene> get scenes => _scenes;
  //Scene

  void removeCurrentArea() async {
    if (_currentArea != null) {
      // Delete the area from Firestore
      debugPrint('Removing area: ${_currentArea!.title}');
      final firestore = FirebaseFirestore.instance;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('areas')
          .doc(_currentArea!.id) // Use the current area's ID
          .delete()
          .then((_) {
        print('Area removed from Firestore');
      }).catchError((error) {
        print('Failed to remove area from Firestore: $error');
      });

      // Remove the area from the local list
      _areas.removeWhere((area) => area.id == _currentArea!.id);

      // Clear the current area
      _currentArea = null;

      // Notify listeners to update UI
      notifyListeners();
    }
  }

  Zone? findZoneByTitle(String title) {
    for (var area in _areas) {
      if (area.isActive) {
        for (var zone in area.zones) {
          if (zone.title == title) {
            return zone;
          }
        }
      }
    }
    return null;
  }

  List<String> savedScenes = [
    'Scene 1',
    'Scene 2',
    'Scene 3'
  ]; // Add saved scenes
  String? activeScene; // Store the active scene

  // Method to set the active scene
  void setActiveScene(Scene? scene) {
    activeScene = scene?.name; // Set the active scene to the scene's name
    notifyListeners(); // Notify listeners of the change
  }

  void removeZoneFromCurrentArea(String title) {
    if (_currentArea != null) {
      _currentArea!.zones.removeWhere((zone) => zone.title == title);
      notifyListeners();
    }
  }

  Future<void> removeZoneFromCurrentAreaByIndex(int index) async {
    if (_currentArea != null &&
        index >= 0 &&
        index < _currentArea!.zones.length) {
      final zoneToRemove = _currentArea!.zones[index];
      print('Removing Zone: ${zoneToRemove.title}');

      // Remove the zone from the current area
      _currentArea!.zones.removeAt(index);

      // Update the current area in Firestore
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'zones': _currentArea!.zones.map((z) => z.toMap()).toList(),
        }).then((_) {
          print('Zone removed from area in Firestore');
        }).catchError((error) {
          print('Failed to update area with removed zone in Firestore: $error');
        });

        // Notify listeners to update UI
        notifyListeners();
      } catch (e) {
        print('Error removing zone: $e');
      }
    } else {
      print('Error: No current area selected or index out of range.');
    }
  }

  void updateCurrentAreaBasedOnZoneTitle(String zoneTitle) {
    for (var area in _areas) {
      if (area.zones.any((zone) => zone.title == zoneTitle)) {
        _currentArea = area;
        print('Current Area: ${_currentArea!.title}');
        notifyListeners();
        return;
      }
    }
  }

  void updateCurrentZoneBasedOnZoneTitle(String zoneTitle) {
    for (var area in _areas) {
      for (var zone in area.zones) {
        if (zone.title == zoneTitle) {
          _currentZone = zone;
          print('Current Zone: ${_currentZone!.title}');
          notifyListeners();
          return;
        }
      }
    }
  }

  void updateZone(Zone updatedZone) {
    if (_currentArea != null) {
      final zoneIndex = _currentArea!.zones.indexWhere(
        (zone) => zone.id == updatedZone.id,
      );

      if (zoneIndex != -1) {
        _currentArea!.zones[zoneIndex] = updatedZone;
      } else {
        _currentArea!.zones.add(updatedZone);
      }
      notifyListeners();
    }
  }

  void setSelectedTimezone(String? timezone) async {
    _selectedTimezone = timezone;
    notifyListeners();
    await _updateUserPreferences();
  }

  void setSelectedLocation(String? location) async {
    _selectedLocation = location;
    notifyListeners();
    await _updateUserPreferences();
  }

  Future<void> _updateUserPreferences() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      print('Error: No user logged in.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('TimeZone')
          .doc(
              'preferences') // Document ID for storing timezone and location preferences
          .set({
        'timezone': _selectedTimezone,
        'location': _selectedLocation,
      }).then((_) {
        print('User preferences updated in Firestore');
      }).catchError((error) {
        print('Failed to update user preferences in Firestore: $error');
      });
    } catch (e) {
      print('Error updating user preferences: $e');
    }
  }

  Future<void> addControllerToArea(Controller controller) async {
    if (_currentArea != null) {
      try {
        // Add controller to the local list
        _currentArea!.controller.add(controller);

        // Update Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'controllers': _currentArea!.controller.map((c) => c.toMap()).toList()
        }).then((_) {
          print('Controller added to Firestore');
        }).catchError((error) {
          print('Failed to add controller to Firestore: $error');
        });

        // Notify listeners to update UI
        notifyListeners();
      } catch (e) {
        print('Error adding controller to area: $e');
      }
    } else {
      print('No current area selected');
    }
  }

  // Method to remove a controller from the current area
  Future<void> removeControllerFromArea(Controller controller) async {
    if (_currentArea != null) {
      try {
        // Remove controller from the local list
        _currentArea!.controller.removeWhere((c) => c.id == controller.id);

        // Update Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'controllers': _currentArea!.controller.map((c) => c.toMap()).toList()
        }).then((_) {
          print('Controller removed from Firestore');
        }).catchError((error) {
          print('Failed to remove controller from Firestore: $error');
        });

        // Notify listeners to update UI
        notifyListeners();
      } catch (e) {
        print('Error removing controller from area: $e');
      }
    } else {
      print('No current area selected');
    }
  }

  void createArea(String title,
      {List<Controller>? controllers, List<Zone>? zones}) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(currentUserId);

    // Generate a new document reference with an auto-generated ID
    final newAreaRef =
        userDoc.collection('areas').doc(); // Automatically generates a new ID

    // Create an Area instance with the generated ID
    final newArea = Area(
      id: newAreaRef.id, // Set the ID
      title: title,
      controller: controllers ?? [],
      zones: zones ?? [],
    );

    try {
      // Add the new Area to Firestore
      await newAreaRef.set(newArea.toMap());
      print('Area added with ID: ${newArea.id}');

      // Update local state
      _areas.add(newArea);
      _currentArea = newArea;
      notifyListeners();
    } catch (e) {
      print('Failed to add area: $e');
    }
  }

  Future<void> addTitleToArea(String newTitle) async {
    if (_currentArea != null) {
      try {
        // Update the title of the current area in Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        // Update Firestore document
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({'title': newTitle}).then((_) {
          print('Area title updated in Firestore');
        }).catchError((error) {
          print('Failed to update area title in Firestore: $error');
        });

        // Update the title in the local area object
        _currentArea!.title = newTitle;

        // Update the local list of areas
        int index = _areas.indexWhere((area) => area.id == _currentArea!.id);
        if (index != -1) {
          _areas[index] = _currentArea!;
        }

        // Notify listeners to update UI
        notifyListeners();
      } catch (e) {
        print('Error updating area title: $e');
      }
    } else {
      print('No current area selected');
    }
  }

  Future<void> addZoneToCurrentArea(Zone zone) async {
    if (_currentArea != null) {
      print('Adding Zone: ${zone.title}');

      // Initialize a list with 4 empty Port objects representing the ports
      final List<Port> ports = List<Port>.generate(
          4,
          (index) => Port(
              portNumber:
                  index + 1)); // Correctly initialize with portNumbers 1-4

      // Set only the port at the correct index if it matches portNumber
      for (var port in zone.ports) {
        if (port.portNumber > 0 && port.portNumber <= 4) {
          // Adjust for 0-based index in the list
          int index = port.portNumber - 1; // Convert to 0-based index
          ports[index] = Port(
            startingValue: port.startingValue,
            endingValue: port.endingValue,
            portNumber: port.portNumber,
            isEnable: port.isEnable, // Reflect the current enabled state
          );
        }
      }

      // Replace the ports in the zone with the updated ports
      zone.ports.clear();
      zone.ports.addAll(ports);

      // Add the new zone to the current area with the updated ports
      _currentArea!.zones.add(zone);

      // Update the current area in Firestore
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'zones': _currentArea!.zones.map((z) => z.toMap()).toList(),
        }).then((_) {
          print('Zone added to area in Firestore');
        }).catchError((error) {
          print('Failed to update area with new zone in Firestore: $error');
        });

        // Notify listeners to update UI
        notifyListeners();

        // Print the states of the ports for debugging purposes
        ports.forEach((port) {
          print('Port ${port.portNumber}: ${port.isEnable}');
        });
      } catch (e) {
        print('Error adding zone: $e');
      }
    } else {
      print('Error: No current area selected.');
    }
  }

  void toggleController(String name) {
    final controller = _controllers.firstWhere((c) => c.name == name);
    controller.isActive = !controller.isActive;
    notifyListeners();
  }

  void toggleControllerByIndex(int index, bool isActive) {
    if (index >= 0 && index < _controllers.length) {
      _controllers[index].isActive = isActive;
      notifyListeners();
    }
  }

  Future<void> toggleArea(int index, bool isActive) async {
    if (index >= 0 && index < _areas.length) {
      final area = _areas[index];
      try {
        // Update local state
        area.isActive = isActive;

        // Update Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(area.id) // Use the area's ID
            .update({'isActive': isActive}).then((_) {
          print('Area state updated in Firestore');
        }).catchError((error) {
          print('Failed to update area state in Firestore: $error');
        });

        // Notify listeners to update UI
        notifyListeners();
      } catch (e) {
        print('Error toggling area: $e');
      }
    }
  }

  void addArea(String title,
      {List<Controller>? controller, List<Zone>? zones}) {
    _currentArea = Area(title: title, controller: controller, zones: zones);
    _areas.add(_currentArea!);
    notifyListeners();
  }

  void addControllersToCurrentArea(List<Controller> controllers) {
    if (_currentArea != null) {
      _currentArea!.controller.addAll(controllers);
      print('Adding controllers to ${_currentArea!.title}');
      print('Controllers: ${controllers.map((c) => c.name).toList()}');
      notifyListeners();
    }
    print('Current Area is null');
  }
}
