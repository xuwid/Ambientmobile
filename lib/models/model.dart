import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart'; // Import material for ChangeNotifier

// Model class for a Controller
class Controller {
  String? id;
  final String name;
  BluetoothDevice? device;
  String? areaId;
  int? ports;

  Controller(
      {this.id, required this.name, this.device, this.areaId, this.ports});
}

// ControllerProvider class to manage the list of controllers
class ControllerProvider with ChangeNotifier {
  List<Controller> _controllers = []; // Private list of controllers
  Controller? _currentController;
  // Getter to retrieve the list of controllers
  List<Controller> get controllers => _controllers;

  //Get a current controller

  Controller get currentController => _currentController!;
  // Method to add a controller and notify listeners of the change
  void addController(Controller controller) {
    _controllers.add(controller);
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
