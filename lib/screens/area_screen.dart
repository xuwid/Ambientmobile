import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/widgets/edit_zone_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';

class AreaScreen extends StatefulWidget {
  const AreaScreen({super.key});

  @override
  _AreaScreenState createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  Map<int, ZoneMenuData> zoneMenus = {};

  @override
  void initState() {
    super.initState();
    _initializeZoneMenus();
  }

  void _initializeZoneMenus() {
    final homeState = Provider.of<HomeState>(context, listen: false);
    final areas = homeState.areas;

    setState(() {
      zoneMenus.clear();
      for (var area in areas) {
        if (area.isActive) {
          for (int i = 0; i < area.zones.length; i++) {
            zoneMenus[zoneMenus.length] = ZoneMenuData.fromZone(area.zones[i]);
          }
        }
      }
    });
  }

  void addNewZoneMenu() {
    setState(() {
      final newIndex = zoneMenus.keys.isNotEmpty
          ? zoneMenus.keys.reduce((a, b) => a > b ? a : b) + 1
          : 0;
      zoneMenus[newIndex] = ZoneMenuData();
    });
  }

  void toggleZoneMenu(int index) {
    final homeState = Provider.of<HomeState>(context, listen: false);
    final zoneMenu = zoneMenus[index];

    setState(() {
      if (zoneMenu != null) {
        zoneMenu.isZoneMenuVisible = !zoneMenu.isZoneMenuVisible;

        if (zoneMenu.isZoneMenuVisible) {
          // Update the current area based on the zone title
          homeState.updateCurrentAreaBasedOnZoneTitle(zoneMenu.zoneName);

          // Make sure portSelections reflects the saved state
          final currentZone = homeState.currentArea?.zones.firstWhere(
            (zone) => zone.title == zoneMenu.zoneName,
            //  orElse: () => null,
          );
          if (currentZone != null) {
            zoneMenu.portSelections = List.generate(
              4,
              (i) =>
                  currentZone.ports.length > i && currentZone.ports[i] != null,
            );
            if (currentZone != null) {
              // Initialize portSelections to match the number of ports in the currentZone
              zoneMenu.portSelections = List.generate(
                currentZone.ports.length,
                (i) => currentZone.ports[i].isEnable,
              );
              // Initialize startingLightValues and endingLightValues to match the number of ports in the currentZone
              zoneMenu.startingLightValues = List.generate(
                currentZone.ports.length,
                (i) => currentZone.ports[i].startingValue,
              );
              zoneMenu.endingLightValues = List.generate(
                currentZone.ports.length,
                (i) => currentZone.ports[i].endingValue,
              );
            }

            // Debug print to show the port selection status
            List<Port> ports = currentZone.ports;
            ports.forEach((port) {
              print('While toggling Port ${port.portNumber}: ${port.isEnable}');
            });
          }
        }
      }
    });
  }

  void changeZoneName(int index, String newName) {
    setState(() {
      zoneMenus[index]?.zoneName = newName;
    });
  }

  void onStartingLightValueChanged(int menuIndex, int portIndex, int newValue) {
    setState(() {
      final zoneMenu = zoneMenus[menuIndex];
      if (zoneMenu != null) {
        if (portIndex < zoneMenu.startingLightValues.length) {
          zoneMenu.startingLightValues[portIndex] = newValue;
        } else {
          zoneMenu.startingLightValues.addAll(
            List.generate(portIndex + 1 - zoneMenu.startingLightValues.length,
                (_) => newValue),
          );
        }
      }
    });
  }

  void onEndingLightValueChanged(int menuIndex, int portIndex, int newValue) {
    setState(() {
      final zoneMenu = zoneMenus[menuIndex];
      if (zoneMenu != null) {
        if (portIndex < zoneMenu.endingLightValues.length) {
          zoneMenu.endingLightValues[portIndex] = newValue;
        } else {
          zoneMenu.endingLightValues.addAll(
            List.generate(portIndex + 1 - zoneMenu.endingLightValues.length,
                (_) => newValue),
          );
        }
      }
    });
  }

  void onPortSelectionChanged(int menuIndex, int portIndex, bool? value) {
    setState(() {
      final zoneMenu = zoneMenus[menuIndex];
      if (zoneMenu != null) {
        // Ensure portSelections list has enough length
        if (portIndex >= zoneMenu.portSelections.length) {
          zoneMenu.portSelections.addAll(
            List.generate(
                portIndex + 1 - zoneMenu.portSelections.length, (_) => false),
          );
        }

        // Update the specific port selection
        zoneMenu.portSelections[portIndex] = value ?? false;

        // Update portCheckStates
        if (portIndex >= zoneMenu.portCheckStates.length) {
          zoneMenu.portCheckStates.addAll(
            List.generate(
                portIndex + 1 - zoneMenu.portCheckStates.length, (_) => false),
          );
        }
        zoneMenu.portCheckStates[portIndex] = value ?? false;

        // Ensure startingLightValues and endingLightValues have enough length
        if (portIndex >= zoneMenu.startingLightValues.length) {
          zoneMenu.startingLightValues.addAll(
            List.generate(
                portIndex + 1 - zoneMenu.startingLightValues.length, (_) => 1),
          );
        }
        if (portIndex >= zoneMenu.endingLightValues.length) {
          zoneMenu.endingLightValues.addAll(
            List.generate(
                portIndex + 1 - zoneMenu.endingLightValues.length, (_) => 12),
          );
        }

        // Optionally, reset light values for ports that are not selected
        if (!(value ?? false)) {
          if (portIndex < zoneMenu.startingLightValues.length) {
            zoneMenu.startingLightValues[portIndex] = 1;
          }
          if (portIndex < zoneMenu.endingLightValues.length) {
            zoneMenu.endingLightValues[portIndex] = 12;
          }
        }
      }
    });
  }

  void saveZone(BuildContext context, int index) {
    final homeState = Provider.of<HomeState>(context, listen: false);

    final zoneMenu = zoneMenus[index];
    if (zoneMenu != null && zoneMenu.zoneName.isNotEmpty) {
      final ports = List.generate(4, (portIndex) {
        if (zoneMenu.portCheckStates.length > portIndex &&
            zoneMenu.portCheckStates[portIndex]) {
          return Port(
            portNumber: portIndex + 1, // Adjusting to 1-based index
            startingValue: (zoneMenu.startingLightValues.length > portIndex)
                ? zoneMenu.startingLightValues[portIndex]
                : 1,
            endingValue: (zoneMenu.endingLightValues.length > portIndex)
                ? zoneMenu.endingLightValues[portIndex]
                : 12,
            isEnable: zoneMenu.portCheckStates[portIndex],
          );
        }
        return null; // Skip ports that are not selected
      }).whereType<Port>().toList(); // Filter out null values

      final newZone = Zone(
        title: zoneMenu.zoneName,
        ports: ports,
      );

      if (homeState.currentArea != null) {
        // Find the index of the zone in the current area
        final zoneIndex = homeState.currentArea!.zones.indexWhere(
          (zone) => zone.title == zoneMenu.zoneName,
        );

        // Remove the old version of the zone by index
        if (zoneIndex != -1) {
          homeState.removeZoneFromCurrentAreaByIndex(zoneIndex);
        }
        toggleZoneMenu(index);
        homeState.addZoneToCurrentArea(newZone);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<HomeState>(context);
    final areas = homeState.areas;

    if (areas.isEmpty || !areas.any((area) => area.isActive)) {
      return Scaffold(
        body: BackgroundWidget(
          child: Center(
            child: Text(
              'No active areas available.',
              style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final buttonWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
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
                      const Image(
                          image: AssetImage("assets/zone_setup.png"),
                          width: 28,
                          color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zones Setup',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            //   fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ...zoneMenus.entries.map((entry) {
                          final index = entry.key;
                          final zoneMenu = entry.value;
                          return Column(
                            children: [
                              EditZoneMenu(
                                isEditMenuVisible: zoneMenu.isZoneMenuVisible,
                                zoneName: zoneMenu.zoneName,
                                buttonWidth: buttonWidth,
                                portSelections: zoneMenu.portSelections,
                                startingLightValues:
                                    zoneMenu.startingLightValues,
                                endingLightValues: zoneMenu.endingLightValues,
                                changeZoneName: (newName) =>
                                    changeZoneName(index, newName),
                                onStartingLightValueChanged:
                                    (portIndex, newValue) =>
                                        onStartingLightValueChanged(
                                            index, portIndex, newValue),
                                onEndingLightValueChanged:
                                    (portIndex, newValue) =>
                                        onEndingLightValueChanged(
                                            index, portIndex, newValue),
                                onPortSelectionChanged: (portIndex, value) =>
                                    onPortSelectionChanged(
                                        index, portIndex, value),
                                onMenuToggle: () => toggleZoneMenu(index),
                                onSaveZone: () => saveZone(context, index),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ZoneMenuData {
  bool isZoneMenuVisible = false;
  String zoneName = "Add Zone";
  List<bool> portSelections = [false, false, false, false];
  List<int> startingLightValues = [1, 1, 1, 1];
  List<int> endingLightValues = [12, 12, 12, 12];
  List<bool> portCheckStates = [false, false, false, false]; // New array

  ZoneMenuData();

  ZoneMenuData.fromZone(Zone zone)
      : isZoneMenuVisible = false,
        zoneName = zone.title,
        portSelections = List.generate(
          4,
          (i) => zone.ports.length > i && zone.ports[i].isEnable,
        ),
        startingLightValues = List.generate(
          4,
          (i) => zone.ports.length > i && zone.ports[i].isEnable
              ? zone.ports[i].startingValue
              : 1,
        ),
        endingLightValues = List.generate(
          4,
          (i) => zone.ports.length > i && zone.ports[i].isEnable
              ? zone.ports[i].endingValue
              : 12,
        ),
        portCheckStates = List.generate(
          4,
          (i) => zone.ports.length > i && zone.ports[i].isEnable,
        );
}
