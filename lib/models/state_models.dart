import 'dart:ui';

import 'package:ambient/utils/assets.dart';
import 'package:ambient/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:ambient/wirelessProtocol/mqtt.dart';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';

class Segments {
  final int startindex;
  final int endindex;
  Segments({required this.startindex, required this.endindex});

  Map<String, dynamic> toMap() {
    return {
      'startindex': startindex,
      'endindex': endindex,
    };
  }

  //From map

  factory Segments.fromMap(Map<String, dynamic> map) {
    return Segments(startindex: map['startindex'], endindex: map['endindex']);
  }
}

class Scene {
  String name;
  int patternID;
  int speed;
  int brightness;
  int density;
  List<int> colors;
  Scene copy() {
    return Scene(
      name: name,
      patternID: patternID,
      colors: List.from(colors),
    );
  }

  Scene({
    this.name = 'Scene 1',
    this.patternID = 12,
    this.speed = 95,
    this.brightness = 255,
    this.density = 255,
    this.colors = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'patternID': patternID,
      'speed': speed,
      'brightness': brightness,
      'density': density,
      'colors': colors,
    };
  }

  void setPatternID(int patternID) {
    this.patternID = patternID;
  }

  void setSpeed(int speed) {
    this.speed = speed;
  }

  void setBrightness(int brightness) {
    this.brightness = brightness;
  }

  void setDensity(int density) {
    this.density = density;
  }

  void setColors(List<int> colors) {
    this.colors = colors;
  }

  void setName(String name) {
    this.name = name;
  }
  //maakee a copy thing

  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
      name: map['name'],
      patternID: map['patternID'],
      speed: map['speed'],
      brightness: map['brightness'],
      density: map['density'],
      colors: List<int>.from(map['colors']),
    );
  }
}

class LED {
  Color color;
  int index;

  LED({
    this.index = 0,
    this.color = const Color(0xFF3EFF20),
  });
}
// Converts LED instance to a Map

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

// class Scene {
//   final String name;
//   Effect activatedEffects;
//   final List<LED> ledSettings;
//   final bool isActive;

//   Scene({
//     this.activatedEffects = const Effect(),
//     this.isActive = false,
//     required this.name,
//     required this.ledSettings,
//   });

//   void setEffect(Effect effect) {
//     activatedEffects = effect;
//   }

//   // Converts Scene instance to a Map
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'activatedEffects': activatedEffects.toMap(),
//       'ledSettings': ledSettings.map((led) => led.toMap()).toList(),
//       'isActive': isActive,
//     };
//   }

//   // Creates Scene instance from a Map
//   factory Scene.fromMap(Map<String, dynamic> map) {
//     return Scene(
//       name: map['name'],
//       activatedEffects: Effect.fromMap(map['activatedEffects']),
//       ledSettings: List<LED>.from(
//           map['ledSettings']?.map((led) => LED.fromMap(led)) ?? []),
//       isActive: map['isActive'],
//     );
//   }
// }

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

// class Zone {
//   static int _idCounter = 0; // Static counter for auto-incrementing IDs
//   final int id;
//   final String title;
//   final List<Port> ports;
//   final List<Scene> scenes;
//   List<LED> leds;

//   Zone({
//     required this.title,
//     List<Port>? ports,
//     List<Scene>? scenes,
//     List<LED>? leds,
//     int ledCount = 15, // Default to 15 LEDs
//   })  : id = _idCounter++,
//         ports = ports ??
//             List.generate(
//                 4,
//                 (index) => Port(
//                     portNumber:
//                         index + 1)), // Initialize ports with portNumbers 1-4
//         scenes = scenes ?? [],
//         leds = leds ??
//             List.generate(
//               ledCount,
//               (index) => LED(
//                 ledNumber: index + 1,
//                 color: Colors.white,
//                 brightness: 1.0,
//                 saturation: 1.0,
//               ),
//             );

//   // Convert a map to a Zone object
//   factory Zone.fromMap(Map<String, dynamic> map) {
//     return Zone(
//       title: map['title'],
//       ports: List<Port>.from(
//           map['ports']?.map((port) => Port.fromMap(port)) ?? []),
//       scenes: List<Scene>.from(
//           map['scenes']?.map((scene) => Scene.fromMap(scene)) ?? []),
//       leds: List<LED>.from(map['leds']?.map((led) => LED.fromMap(led)) ?? []),
//     );
//   }

//   // Convert Zone object to map
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'ports': ports.map((p) => p.toMap()).toList(),
//       'scenes': scenes.map((s) => s.toMap()).toList(),
//       'leds': leds.map((l) => l.toMap()).toList(),
//     };
//   }

//   // Method to update port state
//   void updatePortState(int portNumber, bool isEnable) {
//     Port? port = ports.firstWhere((p) => p.portNumber == portNumber,
//         orElse: () => Port(portNumber: portNumber));
//     if (port != null) {
//       port.isEnable = isEnable;
//     }
//   }

//   // Method to get port state
//   bool getPortState(int portNumber) {
//     Port? port = ports.firstWhere((p) => p.portNumber == portNumber,
//         orElse: () => Port(portNumber: portNumber));
//     return port.isEnable;
//   }

//   void addScene(Scene scene) {
//     scenes.add(scene);
//   }

//   // Method to set the number of LEDs
//   void setLedCount(int newCount) {
//     final currentCount = leds.length;
//     if (newCount > currentCount) {
//       // Add new LEDs
//       leds.addAll(
//         List.generate(
//           newCount - currentCount,
//           (index) => LED(
//             ledNumber: currentCount + index + 1,
//             color: Colors.white,
//             brightness: 1.0,
//             saturation: 1.0,
//           ),
//         ),
//       );
//     } else if (newCount < currentCount) {
//       // Remove excess LEDs
//       leds.removeRange(newCount, currentCount);
//     }
//   }
// }

class Controller {
  int? type;
  String? id;
  String name;
  BluetoothDevice? device; // Assuming device needs special handling
  List<int>? portlength;
  bool isActive = true;

  Controller(
      {this.id,
      required this.name,
      this.device,
      this.portlength,
      this.type,
      this.isActive = true});

  // Method to update the controller's information
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'portlength': portlength,
      'type': type,
      'isActive': isActive,
    };
  }

  factory Controller.fromMap(Map<String, dynamic> map) {
    return Controller(
      id: map['id'],
      name: map['name'],
      portlength: List<int>.from(map['portlength'] ?? []),
      isActive: map['isActive'],
      type: map['type'],
    );
  }

  factory Controller.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Controller.fromMap(data);
  }
}

class Area {
  String? id;
  final String title;
  Controller? controller;
  List<Scene>? scenes;
  List<Segments>? segments;
  bool isActive = false;
  List<bool>? ports = [false, false, false, false];

  Area({
    this.id,
    required this.title,
    this.controller,
    this.scenes,
    this.segments,
    this.isActive = false,
    this.ports,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'controller': controller?.toMap(),
      'scenes': scenes?.map((scene) => scene.toMap()).toList(),
      'segments': segments?.map((segment) => segment.toMap()).toList(),
      'isActive': isActive,
      'ports': ports,
    };
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'],
      title: map['title'],
      controller: map['controller'] != null
          ? Controller.fromMap(map['controller'])
          : null,
      scenes: List<Scene>.from(
          map['scenes']?.map((scene) => Scene.fromMap(scene)) ?? []),
      segments: List<Segments>.from(
          map['segments']?.map((segment) => Segments.fromMap(segment)) ?? []),
      ports: List<bool>.from(map['ports']?.map((port) => port as bool) ?? []),
      isActive: map['isActive'] ?? false,
    );
  }
  void setController(Controller controller) {
    this.controller = controller;
  }
}

class HomeState with ChangeNotifier {
  final MQTTService mqttService = MQTTService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late bool admin;
  Future<void> _checkAdminStatus(HomeState homeState) async {
    admin = await homeState.checkIfUserIsAdmin();
    // You can use setState if you need to trigger a rebuild after this check
  }

  Future<bool> checkIfUserIsAdmin() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return false; // No user is logged in
      }

      final firestore = FirebaseFirestore.instance;
      final userDoc =
          await firestore.collection('users').doc(currentUserId).get();

      // Check if the 'isAdmin' field exists and return its value
      return userDoc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false; // Return false if there's an error
    }
  }

// Pattern ID Definitions
  static const int M_BLINK = 0;
  static const int M_BLINK_MULTIPLE = 1;
  static const int M_PULSE = 2;
  static const int M_PULSE_MULTIPLE = 3;
  static const int M_STATIC = 4;
  static const int M_STATIC_MULTIPLE = 5;
  static const int M_TWINKLE = 6;
  static const int M_FIRE = 7;
  static const int M_BPM = 8;
  static const int M_CHASE = 9;
  static const int M_GRADIENT_STATIC = 10;
  static const int M_GRADIENT = 11;
  static const int M_FAIRY_TWINKLE = 12;
  static const int M_CHASE_FILL = 13;
  static const int M_LIGHTNING = 14;
  static const int M_METEOR = 15;
  static const int M_METEOR_MULTIPLE = 16;
  static const int M_RAINBOW = 17;
  static const int M_WIPE = 18;
  static const int M_WIPE_RANDOM = 19;
  static const int M_SOLID_GLITTER = 20;
  static const int M_PIXELS = 21;

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
  int convertEventToPatternId(String eventName) {
    switch (eventName) {
      case 'Static':
        return M_STATIC;
      case 'Gradient':
        return M_GRADIENT;
      case 'Twinklecat':
        return M_TWINKLE;
      case 'Fairytwinkle':
        return M_FAIRY_TWINKLE;
      case 'Colorwaves':
        return M_GRADIENT; // Assuming it maps to M_GRADIENT
      case 'Chase':
        return M_CHASE;
      case 'Breathe':
        return M_PULSE; // Assuming it maps to M_PULSE
      case 'Lightning':
        return M_LIGHTNING;
      case 'Meteor':
        return M_METEOR;
      case 'Multi Comet':
        return M_METEOR_MULTIPLE; // Assuming it maps to M_METEOR_MULTIPLE
      case 'Pixels':
        return M_PIXELS;
      case 'Rainbow':
        return M_RAINBOW;
      case 'Solid Glitter':
        return M_SOLID_GLITTER;
      case 'Wipe':
        return M_WIPE;
      default:
        return -1; // Return -1 if event name is not found
    }
  }

  String convertPatternIdToEvent(int patternId) {
    switch (patternId) {
      case M_STATIC:
        return 'Static';
      case M_GRADIENT:
        return 'Gradient';
      case M_TWINKLE:
        return 'Twinklecat';
      case M_FAIRY_TWINKLE:
        return 'Fairytwinkle';
      case M_CHASE:
        return 'Chase';
      case M_PULSE:
        return 'Breathe';
      case M_LIGHTNING:
        return 'Lightning';
      case M_METEOR:
        return 'Meteor';
      case M_METEOR_MULTIPLE:
        return 'Multi Comet';
      case M_PIXELS:
        return 'Pixels';
      case M_RAINBOW:
        return 'Rainbow';
      case M_SOLID_GLITTER:
        return 'Solid Glitter';
      case M_WIPE:
        return 'Wipe';
      default:
        return 'Unknown';
    }
  }

  String? selectedTimezone;
  String? selectedLocation;

  void setSelectedTimezone(String tzValue) {
    selectedTimezone = tzValue;
    notifyListeners();
  }

  void setSelectedLocation(String location) {
    selectedLocation = location;
    notifyListeners();
  }

  List<Controller> _controllers = [];

  final Map<String, Timer> _pingTimers = {};

  List<Controller> get controllers => _controllers;
  // Zone? _currentZone;

  // Zone? get currentZone => _currentZone;

  Area? _currentArea;

  List<Scene> get allScenes => _scenes;
  Controller? _currentController;

  String? currentNameYourArea;
  String get currentAreaName => currentNameYourArea ?? 'Area';

  List<Segments>? currentSegments;

  List<Segments>? get currentSegmentsList => currentSegments;

  Controller get currentController => _currentController!;
  // Getter for active areas

  Area? get currentArea => _currentArea;

  void _resetPingTimer(String deviceId) {
    _pingTimers[deviceId]?.cancel();

    // Set a new timer to check connection status after 20 seconds
    _pingTimers[deviceId] = Timer(const Duration(seconds: 10), () {
      final device = _controllers.firstWhere((d) => d.id == deviceId);
      if (device != null && device.isActive) {
        print("Device is no longer active");
        device.isActive = false;
        notifyListeners();

        print(
            'Device $deviceId is no longer connecting. WiFi might be disconnected.');
        notifyListeners(); // Notify listeners of the change
        ;
      }
    });
  }

  void _subscribeToTopics() async {
    await mqttService.connect();
    for (var device in _controllers) {
      if (device.id != null) {
        // Subscribe to /mac_address/ping
        print('Subscribing to topics for device: ${device.id}');
        mqttService.subscribeToTopic('/${device.id}/ping');
        mqttService.subscribeToTopic('/${device.id}/data');

        // Subscribe to /mac_address/alert
      }
    }

    // Listen for incoming messages
    mqttService.onMessage = (topic, payload) {
      final message = String.fromCharCodes(payload);
      print('Received message: $message from topic: $topic');
      _handleIncomingMessage(topic, message);
    };
  }

  void _handleIncomingMessage(String topic, String message) {
    final deviceId = topic.split('/')[1];

    // Find the device matching the received deviceId
    final device = _controllers.firstWhere(
      (d) => d.id == deviceId,
      //  orElse: () => null, // Avoids an error if no device matches
    );
    print("Resetting the timer");
    device.isActive = true;
    notifyListeners();
    _resetPingTimer(deviceId);

    if (device == null) return; // Exit if no device matches the deviceId

    // Reset the ping timer or handle the controller reset for the device
    _resetPingTimer(deviceId); // Or perform any other reset action here

    final parsedMessage = _parseMessage(message);

    // Additionally, handle specific actions if needed
    if (parsedMessage['action'] == 'ping') {
      print('Ping received for device: $deviceId');
      _resetPingTimer(
          deviceId); // Optionally reset again if "ping" specifically requires it
    }
  }

  Map<String, dynamic> _parseMessage(String message) {
    return Map<String, dynamic>.from(jsonDecode(message));
  }

  void setCurrentArea(Area area) {
    _currentArea = area;
    notifyListeners();
  }

  void addScenetoCurrentArea(Scene scene) async {
    if (_currentArea != null) {
      // Add the scene to the current area in local state
      _currentArea!.scenes ??= []; // Ensure the scenes list is initialized
      _currentArea!.scenes!.add(scene);
      notifyListeners();

      // Get the current user's ID and the Firestore instance
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final firestore = FirebaseFirestore.instance;

      // Reference the document for the current area in Firestore
      final areaDocRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('areas')
          .doc(_currentArea!.id);

      // Update Firestore with the new scene added
      try {
        await areaDocRef.update({
          'scenes': FieldValue.arrayUnion([scene.toMap()]),
        });
        print('Scene added to Firestore for area: ${_currentArea!.id}');
      } catch (e) {
        print('Failed to add scene to Firestore: $e');
      }
    }
  }

  void removeControllerFromCurrentArea() {
    if (_currentArea != null) {
      _currentArea!.controller = null;
      notifyListeners();
    }
  }

  void setCurrentControllerPort(List<int> por) {
    _currentController!.portlength = por;
    notifyListeners();
    print("Pors :");
    print(por);
  }

  void addController(Controller controller) {
    _controllers.add(controller);
    notifyListeners(); // Notify listeners about the change
  }

  void setCurrentControllerType(int type) {
    _currentController!.type = type;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to remove a controller and notify listeners of the change
  void removeController(Controller controller) {
    _controllers.remove(controller);
    notifyListeners(); // Notify listeners about the change
  }

  void setCurrentControllerID(String id) {
    _currentController!.id = id;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to set the current controller
  void setCurrentController(Controller controller) {
    _currentController = controller;
    notifyListeners(); // Notify listeners about the change
  }

  void setCurrentNameYourArea(String name) {
    currentNameYourArea = name;
    notifyListeners();
  }

  // Method to update a controller's information (optional)
  void updateController(Controller updatedController) {
    int index = _controllers
        .indexWhere((controller) => controller.id == updatedController.id);
    if (index != -1) {
      _controllers[index] = updatedController;
      notifyListeners(); // Notify listeners about the change
    }
  }

  // List<Scene> get allScenesFromActivatedAreas {
  //   List<Scene> scenes = [];

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

    _subscribeToTopics();
  }

  Future<void> addControllertoUser(Controller con) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      print('No user is logged in');
      return;
    }

    final userDoc = _firestore.collection('users').doc(currentUserId);
    final controllersCollection = userDoc.collection('controllers');

    // Add the controller to the Firestore collection
    await controllersCollection.add(con.toMap());

    // Update the local state with the new controller
    _controllers.add(con);
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  Future<void> getControllersForUser() async {
    List<Controller> fetchedControllers = [];

    for (var area in _areas) {
      if (area.controller != null) {
        fetchedControllers.add(area.controller!);
      }
    }

    print('Fetched controllers: ${fetchedControllers}.');

    // Use WidgetsBinding to delay the notification to listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Remove duplicates based on controller id or other attributes if id is null
      final uniqueControllers = <Controller>[];

      bool isDuplicate(Controller controller) {
        return uniqueControllers.any((uniqueController) {
          if (controller.id != null && uniqueController.id != null) {
            return controller.id == uniqueController.id;
          }
          // Check all other attributes if id is null
          return controller.id == null &&
              uniqueController.id == null &&
              controller.name == uniqueController.name &&
              controller.type == uniqueController.type &&
              controller.isActive == uniqueController.isActive &&
              controller.portlength == uniqueController.portlength &&
              controller.device == uniqueController.device;
          // Add other relevant attributes
        });
      }

      for (var controller in fetchedControllers) {
        if (!isDuplicate(controller)) {
          uniqueControllers.add(controller);
        }
      }

      // Update the local state with the unique controllers
      _controllers = uniqueControllers;
      notifyListeners(); // Notify listeners to rebuild the UI

      print('Controllers updated in local state: $_controllers');
    });
  }

  void renameController(String newName) async {
    if (_currentController == null) {
      print('No controller is selected.');
      return;
    }

    // Get Firestore instance and current user ID
    final firestore = FirebaseFirestore.instance;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      print('No user is currently logged in.');
      return;
    }

    // Reference to the user's areas collection
    final areasCollection =
        firestore.collection('users').doc(currentUserId).collection('areas');

    // Fetch all areas
    final areasSnapshot = await areasCollection.get();

    // Loop through all areas and update the controller name where it matches the current controller
    for (var areaDoc in areasSnapshot.docs) {
      final area = Area.fromMap(areaDoc.data());

      // Check if the current controller matches the one in the area
      if (area.controller?.id == _currentController!.id) {
        // Update the controller name locally
        _currentController!.name = newName;

        // Update Firestore for the area document with the new controller name
        await areasCollection.doc(area.id).update({
          'controller': _currentController!.toMap(),
        });
      }
    }

    // Notify listeners about the updated controller name in the app's local state
    notifyListeners();

    print('Controller name updated across relevant areas in Firestore.');
  }

  HomeState() {
    getControllersForUser();
    _subscribeToTopics();
  }
  List<Area> _areas = [];

  String? _selectedTimezone;
  String? _selectedLocation;

  List<Area> get areas => _areas;
  //zone Active by toggle
  List<Scene> _scenes = [];

// Function to add a scene to a specific zone within the current area

  void addControllertoCurrentArea(Controller controller) {
    if (_currentArea != null) {
      _currentArea!.controller = controller;
      notifyListeners();
    }
  }

  Future<void> fetchScenesForActivatedAreas() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        print('No user is logged in');
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(currentUserId);

      // Fetch all areas where the area is activated
      final areasSnapshot = await userDoc
          .collection('areas')
          .where('isActive',
              isEqualTo:
                  true) // Assuming there's an 'isActivated' field in the area documents
          .get();

      if (areasSnapshot.docs.isEmpty) {
        print('No activated areas found.');
        return;
      }

      List<Scene> fetchedScenes = [];

      // Loop through each activated area and fetch the scenes
      for (var areaDoc in areasSnapshot.docs) {
        final data = areaDoc.data();
        List<dynamic>? scenesData = data['scenes'] as List<dynamic>?;

        if (scenesData != null && scenesData.isNotEmpty) {
          List<Scene> scenes = scenesData.map((sceneData) {
            return Scene.fromMap(
                sceneData); // Assuming you have a fromMap method in your Scene class
          }).toList();

          fetchedScenes.addAll(scenes);
        }
      }

      // Update the local state with fetched scenes
      _scenes = fetchedScenes;
      notifyListeners(); // Notify any listeners about the state update

      print('Fetched ${_scenes.length} scenes from activated areas.');
    } catch (e) {
      print('Error fetching scenes from activated areas: $e');
    }
  }

  void addSceneToZone(String zoneTitle, Scene scene) async {
    try {
      // Get the Firestore instance and current user ID
      final firestore = FirebaseFirestore.instance;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        print('No user is currently logged in.');
        return;
      }

      // Find the area that contains the specified zone
      final areasCollection =
          firestore.collection('users').doc(currentUserId).collection('areas');

      // Fetch all areas
      final areasSnapshot = await areasCollection.get();

      // Find the area containing the zone
      //final areaDoc = areasSnapshot.docs.firstWhere(
      // (doc) {
      // final area = Area.fromFirestore(doc);
      //   return area.zones.any((zone) => zone.title == zoneTitle);
      // },
      //  orElse: () => throw Exception('Area not found'),
      // );

      //final area = Area.fromFirestore(areaDoc);

      // Find the specific zone in the area
      //final zone = area.zones.firstWhere(
      // (zone) => zone.title == zoneTitle,
      // orElse: () => throw Exception('Zone not found'),
      //);

      // Add the scene to the zone locally
      // zone.scenes.add(scene);
      // notifyListeners(); // Notify listeners if applicable

      // Reference to the area document
      // final areaRef = areasCollection.doc(area.id);

      // // Update the zone in the list of zones within the area document
      // final updatedZones = area.zones.map((z) {
      //   if (z.title == zoneTitle) {
      //     // Update the specific zone with the new scene
      //     return Zone(
      //       // id: z.id, // Ensure you maintain the zone's ID
      //       title: z.title,
      //       ports: z.ports,
      //       scenes: [...z.scenes, scene], // Add the new scene
      //     );
      //   }
      //   return z;
      // }).toList();

      //   await areaRef.update({
      //    'zones': updatedZones.map((z) => z.toMap()).toList(),
      //     });

      print('Scene added to zone and updated in Firestore.');
    } catch (error) {
      print('Failed to update zone scenes in Firestore: $error');
    }
  }

  // Add a scene to the list
  // void addScenetoZone(Zone zone, Scene scene) {
  //   zone.scenes.add(scene);
  //   notifyListeners();
  // }

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

  List<String> savedScenes = [
    'Scene 1',
    'Scene 2',
    'Scene 3'
  ]; // Add saved scenes
  String? activeScene; // Store the active scene

  Future<void> sendRenameDataMQTT(String newName) async {
    if (_currentController == null) {
      print('Error: Current controller or its ID is null.');
      return;
    }

    // Create the JSON message to send
    Map<String, dynamic> jsonMessage = {
      "a": "rn",
      "n": newName,
    };

    try {
      // Ensure MQTT is connected before publishing
      await mqttService.connect();
      String hin = _currentController!.id ?? 'malaiks';

      // Construct the topic using the current controller's ID
      String topic = "/${hin}/data";

      // Publish the message to the MQTT topic
      mqttService.publishJsonToTopic(topic, jsonMessage);
      print('MQTT message sent: $jsonMessage to topic: $topic');
    } catch (e) {
      print('Error sending MQTT message: $e');
    }
  }

  // Method to set the active scene
  Future<void> setActiveScene(Scene? scene, String ack) async {
    if (scene == null) {
      activeScene = null;
      notifyListeners();
      print('Error: Scene is null.');
      return;
    }
    if (activeScene == scene.name) {
      activeScene = null;
      notifyListeners();
      print("Scene is al");
    } else if (activeScene != scene.name) {
      activeScene = scene.name;
      notifyListeners();
    }
    // Ensure MQTT connection is established
    await mqttService.connect();

    try {
      // Find the active area containing the scene
      final area = _areas.firstWhere(
        (area) => area.scenes!.any((s) => s.name == scene.name),
        // orElse: () => null,
      );

      // Check if the area and its controller exist
      if (area != null && area.controller != null) {
        final controller = area.controller!;
        final controllerId = controller.id ?? 'malaiks';
        print('Controller ID: $controllerId');
        final typefda = controller.type;
        // Prepare the JSON payload
        Map<String, dynamic> jsonMessage = {
          "a": ack,
          "type": typefda,
          "portlength":
              controller.portlength ?? [], // Controller's port lengths
          "seg":
              area.segments?.map((s) => [s.startindex, s.endindex]).toList() ??
                  [], // Area's segments
          "scene": {
            "ports": area.ports, // Scene's port booleans
            "patternId": scene.patternID,
            "colors": scene.colors ?? [],
            "speed": scene.speed ?? 0,
            "brightness": scene.brightness ?? 0,
            "density": scene.density ?? 0,
          },
        };

        // Publish the JSON message to the controller's topic (controller ID)
        String top = "/" + controllerId + "/data";
        mqttService.publishJsonToTopic(top, jsonMessage);

        // Update the active scene in the local state

        print(
            'Scene "${scene.name}" activated and message sent to topic "$top".');
      } else {
        print(
            'Error: No active area found with the given scene, or area has no controller.');
      }
    } catch (e) {
      print('Error while activating scene: $e');
    }
  }

  Future<void> setActiveSceneAdmin(Scene? scene, String act) async {
    if (scene!.name == activeScene) {
      activeScene = null;
      notifyListeners();
    } else if (scene.name != activeScene) {
      activeScene = scene.name;
      notifyListeners();
    }

    // Ensure MQTT connection is established
    await mqttService.connect();

    try {
      // Filter active areas (areas where isActive is true)
      final activeAreas =
          _areas.where((area) => area.isActive == true).toList();

      if (activeAreas.isEmpty) {
        print('Error: No active area found.');
        return;
      }

      for (var area in activeAreas) {
        // Ensure the area has a controller
        if (area.controller != null) {
          final controller = area.controller!;
          final controllerId = controller.id ?? 'malaiks';

          // Prepare the JSON payload
          Map<String, dynamic> jsonMessage = {
            "a": act,
            "type": controller.type,
            "portlength":
                controller.portlength ?? [], // Controller's port lengths
            "seg": area.segments
                    ?.map((s) => [s.startindex, s.endindex])
                    .toList() ??
                [], // Area's segments
            "scene": {
              "ports": area.ports, // Scene's port booleans
              "patternId": scene.patternID,
              "colors": scene.colors ?? [],
              "speed": scene.speed ?? 0,
              "brightness": scene.brightness ?? 0,
              "density": scene.density ?? 0,
            },
          };
          print(jsonMessage);
          String top = "/" + controllerId + "/data";

          // Publish the JSON message to the controller's topic (controller ID)
          mqttService.publishJsonToTopic(top, jsonMessage);

          print(
              'Scene "${scene.name}" activated for area "${area.title}" and message sent to topic "$top".');
        } else {
          print('Error: Area "${area.title}" has no controller.');
        }
      }
    } catch (e) {
      print('Error while activating scene: $e');
    }
  }

  void removeZoneFromCurrentArea(String title) {
    if (_currentArea != null) {
      //    _currentArea!.zones.removeWhere((zone) => zone.title == title);
      notifyListeners();
    }
  }

  Future<void> removeZoneFromCurrentAreaByIndex(int index) async {
    // if (_currentArea != null &&
    //     index >= 0 &&
    //     index < _currentArea!.zones.length) {
    //   final zoneToRemove = _currentArea!.zones[index];
    //   print('Removing Zone: ${zoneToRemove.title}');

    //   // Remove the zone from the current area
    //   _currentArea!.zones.removeAt(index);

    //   // Update the current area in Firestore
    //   try {
    //     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    //     if (currentUserId == null) throw Exception('No user logged in');

    //     await _firestore
    //         .collection('users')
    //         .doc(currentUserId)
    //         .collection('areas')
    //         .doc(_currentArea!.id) // Use the current area's ID
    //         .update({
    //       'zones': _currentArea!.zones.map((z) => z.toMap()).toList(),
    //     }).then((_) {
    //       print('Zone removed from area in Firestore');
    //     }).catchError((error) {
    //       print('Failed to update area with removed zone in Firestore: $error');
    //     });

    //     // Notify listeners to update UI
    //     notifyListeners();
    //   } catch (e) {
    //     print('Error removing zone: $e');
    //   }
    // } else {
    //   print('Error: No current area selected or index out of range.');
    // }
  }

  void updateCurrentAreaBasedOnZoneTitle(String zoneTitle) {
    // for (var area in _areas) {
    //   if (area.zones.any((zone) => zone.title == zoneTitle)) {
    //     _currentArea = area;
    //     print('Current Area: ${_currentArea!.title}');
    //     notifyListeners();
    //     return;
    //   }
    // }
  }

  void updateCurrentZoneBasedOnZoneTitle(String zoneTitle) {
    // for (var area in _areas) {
    //   for (var zone in area.zones) {
    //     if (zone.title == zoneTitle) {
    //       _currentZone = zone;
    //       print('Current Zone: ${_currentZone!.title}');
    //       notifyListeners();
    //       return;
    //     }
    //   }
    // }
  }

  ////// void updateZone(Zone updatedZone) {
  // if (_currentArea != null) {
  //   final zoneIndex = _currentArea!.zones.indexWhere(
  //     (zone) => zone.id == updatedZone.id,
  //   );

  //   if (zoneIndex != -1) {
  //     _currentArea!.zones[zoneIndex] = updatedZone;
  //   } else {
  //     _currentArea!.zones.add(updatedZone);
  //   }
  //   notifyListeners();
  // }
//  }

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
        addControllertoCurrentArea(controller);

        // Update Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');
        if (_currentArea!.controller == null) {
          _currentArea!.controller = controller;
        }
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'controllers': controllers.map((c) => c.toMap()).toList()
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
        _currentArea!.controller = null;

        // Update Firestore
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) throw Exception('No user logged in');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('areas')
            .doc(_currentArea!.id) // Use the current area's ID
            .update({
          'controllers': controllers.map((c) => c.toMap()).toList()
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

  Future<Area?> fetchAreaForSceneName(String sceneName) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      print('No user is logged in');
      return null;
    }
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(currentUserId);

    // Fetch all activated areas
    final areasSnapshot = await userDoc
        .collection('areas')
        .where('isActive', isEqualTo: true)
        .get();

    // Loop through each area to see if it contains the scene with the given name.
    for (var areaDoc in areasSnapshot.docs) {
      final data = areaDoc.data();
      List<dynamic>? scenesData = data['scenes'] as List<dynamic>?;
      if (scenesData != null && scenesData.isNotEmpty) {
        bool found = scenesData.any((scene) => scene['name'] == sceneName);
        if (found) {
          // Convert the area document to an Area model
          return Area.fromMap(data);
        }
      }
    }
    return null;
  }

  Future<void> addOrUpdateSceneToCurrentArea(Scene scene,
      {Scene? originalScene}) async {
    if (_currentArea == null) return;

    // Initialize the local scenes list if needed.
    _currentArea!.scenes ??= [];

    if (originalScene == null) {
      // Creation scenario.
      bool exists = _currentArea!.scenes!
          .any((existingScene) => existingScene.name == scene.name);
      if (exists) {
        print('Scene with this name already exists in the current area.');
        // You can show an error message via Snackbar or other means.

        return;
      }
      // Add the new scene locally.
      _currentArea!.scenes!.add(scene);

      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(currentUserId);
        final areaRef = userDoc.collection('areas').doc(_currentArea!.id);

        // Add the new scene to Firestore.
        await areaRef.update({
          'scenes': FieldValue.arrayUnion([scene.toMap()]),
        });
        print('Scene added to area in Firestore');
        notifyListeners();
      } catch (e) {
        print('Failed to add scene to area in Firestore: $e');
      }
    } else {
      // Update scenario.
      // If the scene name was changed, check for duplicates.
      if (scene.name != originalScene.name) {
        bool exists = _currentArea!.scenes!
            .any((existingScene) => existingScene.name == scene.name);
        if (exists) {
          print('Scene with this name already exists in the current area.');
          // You can show an error message via Snackbar or other means.
          return;
        }
      }

      // Remove the old scene locally.
      _currentArea!.scenes!.removeWhere(
          (existingScene) => existingScene.name == originalScene.name);
      // Add the updated scene locally.
      _currentArea!.scenes!.add(scene);

      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(currentUserId);
        final areaRef = userDoc.collection('areas').doc(_currentArea!.id);

        // Remove the old scene from Firestore.
        await areaRef.update({
          'scenes': FieldValue.arrayRemove([originalScene.toMap()]),
        });

        // Add the updated scene to Firestore.
        await areaRef.update({
          'scenes': FieldValue.arrayUnion([scene.toMap()]),
        });
        print('Scene updated in area in Firestore');
        notifyListeners();
      } catch (e) {
        print('Failed to update scene in area in Firestore: $e');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  void createArea(String title,
      {Controller? controller,
      List<bool>? ports,
      List<Segments>? segments,
      List<Scene>? scenes}) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(currentUserId);

    // Print statements to debug the incoming parameters
    print('Title: $title');
    print('Ports: $ports');
    print('Controller: ${controller?.name}');
    print('Segments: ${segments?.map((s) => s.startindex).toList()}');
    print('Scenes: ${scenes?.length}');

    // Generate a new document reference with an auto-generated ID
    final newAreaRef = userDoc.collection('areas').doc();

    // Create an Area instance with the generated ID
    final newArea = Area(
      id: newAreaRef.id, // Set the ID
      title: title,
      ports: ports,
      controller: controller,
      segments: segments,
      scenes: scenes,
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

  void updateArea(String id, List<Segments> seg, List<bool> ports) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(currentUserId);
    final areaRef = userDoc.collection('areas').doc(id);
    areaRef.update({
      'segments': seg.map((s) => s.toMap()).toList(),
      'ports': ports,
    }).then((_) {
      print('Area updated in Firestore');
    }).catchError((error) {
      print('Failed to update area in Firestore: $error');
    });
  }

  // Future<void> addTitleToArea(String newTitle) async {
  //   if (_currentArea != null) {
  //     try {
  //       // Update the title of the current area in Firestore
  //       final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //       if (currentUserId == null) throw Exception('No user logged in');

  //       // Update Firestore document
  //       await _firestore
  //           .collection('users')
  //           .doc(currentUserId)
  //           .collection('areas')
  //           .doc(_currentArea!.id) // Use the current area's ID
  //           .update({'title': newTitle}).then((_) {
  //         print('Area title updated in Firestore');
  //       }).catchError((error) {
  //         print('Failed to update area title in Firestore: $error');
  //       });

  //       // Update the title in the local area object

  //       _currentArea = _currentArea!.copyWith(title: newTitle);
  //       // Update the local list of areas
  //       int index = _areas.indexWhere((area) => area.id == _currentArea!.id);
  //       if (index != -1) {
  //         _areas[index] = _currentArea!;
  //       }

  //       // Notify listeners to update UI
  //       notifyListeners();
  //     } catch (e) {
  //       print('Error updating area title: $e');
  //     }
  //   } else {
  //     print('No current area selected');
  //   }
  // }

  // Future<void> addZoneToCurrentArea(Zone zone) async {
  //   if (_currentArea != null) {
  //     print('Adding Zone: ${zone.title}');

  //     // Initialize a list with 4 empty Port objects representing the ports
  //     final List<Port> ports = List<Port>.generate(
  //         4,
  //         (index) => Port(
  //             portNumber:
  //                 index + 1)); // Correctly initialize with portNumbers 1-4

  //     // Set only the port at the correct index if it matches portNumber
  //     for (var port in zone.ports) {
  //       if (port.portNumber > 0 && port.portNumber <= 4) {
  //         // Adjust for 0-based index in the list
  //         int index = port.portNumber - 1; // Convert to 0-based index
  //         ports[index] = Port(
  //           startingValue: port.startingValue,
  //           endingValue: port.endingValue,
  //           portNumber: port.portNumber,
  //           isEnable: port.isEnable, // Reflect the current enabled state
  //         );
  //       }
  //     }

  //     // Replace the ports in the zone with the updated ports
  //     zone.ports.clear();
  //     zone.ports.addAll(ports);

  //     // Add the new zone to the current area with the updated ports
  //     //   _currentArea!.zones.add(zone);

  //     // Update the current area in Firestore
  //     try {
  //       final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //       if (currentUserId == null) throw Exception('No user logged in');

  //       await _firestore
  //           .collection('users')
  //           .doc(currentUserId)
  //           .collection('areas')
  //           .doc(_currentArea!.id) // Use the current area's ID
  //           .update({}).then((_) {
  //         print('Zone added to area in Firestore');
  //       }).catchError((error) {
  //         print('Failed to update area with new zone in Firestore: $error');
  //       });

  //       // Notify listeners to update UI
  //       notifyListeners();

  //       // Print the states of the ports for debugging purposes
  //       ports.forEach((port) {
  //         print('Port ${port.portNumber}: ${port.isEnable}');
  //       });
  //     } catch (e) {
  //       print('Error adding zone: $e');
  //     }
  //   } else {
  //     print('Error: No current area selected.');
  //   }
  // }

  void showControllerStatus(BuildContext context, String name) {
    final controller = _controllers.firstWhere(
      (c) => c.name == name,
    );

    if (controller != null) {
      // Check the isConnecting (or isActive) status and display a message
      final message = controller.isActive
          ? 'Controller "$name" is connected.'
          : 'Controller "$name" is not connected.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Controller "$name" not found.')),
      );
    }
  }

  void showControllerStatusByIndex(BuildContext context, int index) {
    if (index >= 0 && index < _controllers.length) {
      final controller = _controllers[index];
      final message = controller.isActive
          ? 'Controller at index $index is active.'
          : 'Controller at index $index is not active.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Controller at index $index not found.')),
      );
    }
  }

  Future<void> toggleArea(int index, bool isActive) async {
    if (index >= 0 && index < _areas.length) {
      final area = _areas[index];
      try {
        // Update local state
        area.isActive = isActive;
        notifyListeners();
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
      } catch (e) {
        print('Error toggling area: $e');
      }
    }
  }

  void addArea(String title, {Controller? controller}) {
    _currentArea = Area(title: title, controller: controller);
    _areas.add(_currentArea!);
    notifyListeners();
  }

//   void addControllersToCurrentArea(List<Controller> controllers) {
//     if (_currentArea != null) {
//       _currentArea!.controller.addAll(controllers);
//       print('Adding controllers to ${_currentArea!.title}');
//       print('Controllers: ${controllers.map((c) => c.name).toList()}');
//       notifyListeners();
//     }
//     print('Current Area is null');
//   }
// }
}
