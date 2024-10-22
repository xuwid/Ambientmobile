import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart'; // Import material for ChangeNotifier
import 'package:flutter/foundation.dart'; // Import foundation for kIsWeb"

// Model class for a Controller
class Scene {
  final String name;
  final int patternID;
  final int speed;
  final int brightness;
  final int density;
  final List<int> colors;
  //modify that id of a scene is auto genearted
  Scene(
      {required this.name,
      this.patternID = 12,
      this.speed = 95,
      this.brightness = 255,
      this.density = 255,
      required this.colors});

  // Method to update the controller's information
  //To map

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'patternID': patternID,
      'speed': speed,
      'brightness': brightness,
      'density': density,
      'colors': colors
    };
  }

  //From map

  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
        name: map['name'],
        patternID: map['patternID'],
        speed: map['speed'],
        brightness: map['brightness'],
        density: map['density'],
        colors: map['colors']);
  }
}

class Segments {
  final int startindex;
  final int endindex;
  Segments({required this.startindex, required this.endindex});

  // Method to update the controller's information

  //To map

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

class Area {
  String? id;
  final String name;
  final Controller controller;
  List<Scene>? scenes;
  List<Segments>? segments;
  List<bool>? ports = [false, false, false, false];
  Area(
      {this.ports,
      this.id,
      required this.name,
      required this.controller,
      this.scenes,
      this.segments});

  // Method to update the controller's information
  //To map

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ports': ports,
      'name': name,
      'controller': controller,
      'scenes': scenes,
      'segments': segments
    };
  }

  //From map

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
        id: map['id'],
        name: map['name'],
        controller: map['controller'],
        ports: map['ports'],
        scenes: map['scenes'],
        segments: map['segments']);
  }

  void addScene(Scene scene) {
    scenes!.add(scene);
  }

  void removeScene(Scene scene) {
    scenes!.remove(scene);
  }

  void addSegment(Segments segment) {
    segments!.add(segment);
  }

  void removeSegment(Segments segment) {
    segments!.remove(segment);
  }

  void updateScene(Scene scene) {
    int index = scenes!.indexWhere((scene) => scene.name == scene.name);
    if (index != -1) {
      scenes![index] = scene;
    }
  }
}

class Controller {
  int? type;
  String? id;
  final String name;
  BluetoothDevice? device;
  List<int>? portlength;
  bool? isconnected = true;

  Controller(
      {this.id,
      required this.name,
      this.device,
      this.portlength,
      this.type,
      this.isconnected});

  // Method to update the controller's information
  //To map

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'device': device,
      'portlength': portlength,
      'type': type,
      'isconnected': isconnected
    };
  }
  //From map

  factory Controller.fromMap(Map<String, dynamic> map) {
    return Controller(
        id: map['id'],
        name: map['name'],
        device: map['device'],
        portlength: map['portlength'],
        isconnected: map['isconnected'],
        type: map['type']);
  }
}

// ControllerProvider class to manage the list of controllers
class ControllerProvider with ChangeNotifier {
  List<Controller> _controllers = [
    Controller(name: "Dummy Controller", device: null)
  ]; // Private list of controllers
  Controller? _currentController;
  // Getter to retrieve the list of controllers
  List<Controller> get controllers => _controllers;

  //Get a current controller

  Controller get currentController => _currentController!;
  // Method to add a controller and notify listeners of the change

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

  void addSegmentToCurrentController(Segments segment) {
    _currentController!.portlength!.add(segment.startindex);
    _currentController!.portlength!.add(segment.endindex);
    notifyListeners(); // Notify listeners about the change
  }

  void removeSegmentFromCurrentController(Segments segment) {
    _currentController!.portlength!.remove(segment.startindex);
    _currentController!.portlength!.remove(segment.endindex);
    notifyListeners(); // Notify listeners about the change
  }

  // Method to remove a controller and notify listeners of the change
  void removeController(Controller controller) {
    _controllers.remove(controller);
    notifyListeners(); // Notify listeners about the change
  }

  void setCurrentControllerID(String id) {
    _currentController =
        _controllers.firstWhere((controller) => controller.id == id);
    notifyListeners(); // Notify listeners about the change
  }

  // Method to set the current controller
  void setCurrentController(Controller controller) {
    _currentController = controller;
    notifyListeners(); // Notify listeners about the change
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
}
