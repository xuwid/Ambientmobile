import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../models/state_models.dart';

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({Key? key}) : super(key: key);

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  late HomeState homeState;
  String? selectedTimezone;
  String? selectedLocation;
  List<String> timezones = [];
  Map<String, List<String>> locationsMap = {};
  List<String> locations = [];
  String? currentTime;
  // Removed search query variable since we no longer filter

  // Controller for LED ExpansionTile is already used.
  // We'll add another controller for the Location ExpansionTile.
  final ExpansionTileController locationETC = ExpansionTileController();

  final ExpansionTileController TimeZoneETC = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    homeState = Provider.of<HomeState>(context, listen: false);
    selectedTimezone = homeState.selectedTimezone;
    selectedLocation = homeState.selectedLocation;
    _loadTimezonesFromAsset();
    _loadUserPreferences();
  }

  /// Load the time zones from a local JSON file (or a remote JSON if needed)
  Future<void> _loadTimezonesFromAsset() async {
    // The JSON should be an array of strings like:
    // ["America/New_York", "Europe/London", "Asia/Tokyo", ...]
    String jsonString = await rootBundle.loadString('assets/timezones.json');
    final List<dynamic> data = json.decode(jsonString);
    setState(() {
      // Create a list of unique regions for our first dropdown.
      timezones = data
          .map((tzString) => tzString.toString().split('/').first)
          .toSet()
          .toList();
      // Build a map: region -> list of locations.
      locationsMap = {};
      for (var tzEntry in data) {
        var parts = tzEntry.toString().split('/');
        if (parts.length > 1) {
          var region = parts.first;
          var location = parts.last;
          if (!locationsMap.containsKey(region)) {
            locationsMap[region] = [];
          }
          locationsMap[region]!.add(location);
        }
      }
      if (selectedTimezone != null) {
        _updateLocations(selectedTimezone!);
      }
      if (selectedTimezone != null && selectedLocation != null) {
        _updateCurrentTime('$selectedTimezone/$selectedLocation');
      }
    });
  }

  /// Update the locations list when a region is selected.
  Future<void> _updateLocations(String timezone) async {
    setState(() {
      locations = locationsMap[timezone] ?? [];
    });
  }

  /// Compute the current time for a given timezone (using the timezone package).
  Future<void> _updateCurrentTime(String fullTimezone) async {
    try {
      var location = tz.getLocation(fullTimezone);
      var now = tz.TZDateTime.now(location);
      setState(() {
        currentTime = now.toString();
      });
    } catch (e) {
      print("Error getting time: $e");
    }
  }

  /// Load user preferences from shared_preferences.
  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTimezone = prefs.getString('selectedTimezone');
      selectedLocation = prefs.getString('selectedLocation');
    });
    if (selectedTimezone != null) {
      _updateLocations(selectedTimezone!);
    }
    if (selectedTimezone != null && selectedLocation != null) {
      _updateCurrentTime('$selectedTimezone/$selectedLocation');
    }
  }

  /// Save user preferences to shared_preferences.
  Future<void> _saveUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimezone', selectedTimezone ?? '');
    await prefs.setString('selectedLocation', selectedLocation ?? '');
  }

  /// Custom expansion tile for selecting the time zone (region).
  Widget _buildTimezoneExpansionTile() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFF545458),
              width: 1.2,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: ExpansionTile(
              controller: TimeZoneETC,
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                selectedTimezone ?? 'Select a Time Zone',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black.withOpacity(0.2),
              collapsedBackgroundColor: Colors.black.withOpacity(0.3),
              children: timezones.map((tzItem) {
                return ListTile(
                  title: Text(
                    tzItem,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedTimezone = tzItem;
                      selectedLocation = null;
                      locations = [];
                      currentTime = null;
                      TimeZoneETC.collapse();
                    });
                    homeState.setSelectedTimezone(tzItem);
                    _updateLocations(tzItem);
                    _saveUserPreferences();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Custom expansion tile for selecting the location within the selected time zone.
  /// Removed the search bar. Now, the children list is built directly from the 'locations' list.
  Widget _buildLocationExpansionTile() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFF545458),
              width: 1.2,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: ExpansionTile(
              controller: locationETC,
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                selectedLocation ?? 'Select a Location',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black.withOpacity(0.2),
              collapsedBackgroundColor: Colors.black.withOpacity(0.3),
              children: locations.map((loc) {
                return ListTile(
                  title: Text(
                    loc,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedLocation = loc;
                    });
                    homeState.setSelectedLocation(loc);
                    _updateCurrentTime('$selectedTimezone/$loc');
                    _saveUserPreferences();
                    // Collapse the expansion tile after selection.
                    locationETC.collapse();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar with back button and title
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        const Spacer(),
                        Image.asset('assets/clock.png', width: 28),
                        const SizedBox(width: 3),
                        Text(
                          'Time Zone and Location',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Spacer(),
                        const Spacer(),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimezoneExpansionTile(),
                          if (selectedTimezone != null)
                            _buildLocationExpansionTile(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
