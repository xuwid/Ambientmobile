import 'dart:math';

import 'package:ambient/screens/name_your_area.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ambient/widgets/background_widget.dart'; // Your background widget
import 'package:ambient/models/state_models.dart'; // Import your model

// LED Type Map
final Map<String, int> ledTypes = {
  // ... your LED types map here
  "RGB": 6,
  "RBG": 9,
  "GRB": 82,
  "GBR": 161,
  "BRG": 88,
  "BGR": 164,
  "WRGB": 27,
  "WRBG": 30,
  "WGRB": 39,
  "WGBR": 54,
  "WBRG": 45,
  "WBGR": 57,
  "RWGB": 75,
  "RWBG": 78,
  "RGWB": 135,
  "RGBW": 198,
  "RBWG": 141,
  "RBGW": 201,
  "GWRB": 99,
  "GWBR": 114,
  "GRWB": 147,
  "GRBW": 210,
  "GBWR": 177,
  "GBRW": 225,
  "BWRG": 108,
  "BWGR": 120,
  "BRWG": 156,
  "BRGW": 216,
  "BGWR": 180,
  "BGRW": 228
};

class ConfigureControllerScreen extends StatefulWidget {
  final Controller controller;
  const ConfigureControllerScreen({super.key, required this.controller});

  @override
  _ConfigureControllerScreenState createState() =>
      _ConfigureControllerScreenState();
}

class _ConfigureControllerScreenState extends State<ConfigureControllerScreen> {
  String? selectedLEDTypeString;
  int? selectedLEDTypeValue;
  List<TextEditingController> portControllers = [];
  final ExpansionTileController etc = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    if (Provider.of<HomeState>(context, listen: false).currentController.type !=
        null) {
      selectedLEDTypeValue =
          Provider.of<HomeState>(context, listen: false).currentController.type;
      selectedLEDTypeString = ledTypes.keys
          .firstWhere((key) => ledTypes[key] == selectedLEDTypeValue);
      portControllers = List.generate(4, (_) => TextEditingController());
      for (int i = 0; i < 4; i++) {
        portControllers[i].text = Provider.of<HomeState>(context, listen: false)
            .currentController
            .portlength![i]
            .toString();
      }
    } else {
      portControllers = List.generate(4, (_) => TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in portControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image covering the whole screen
          Positioned.fill(
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
            ),
          ),
          // Main content wrapped in a SingleChildScrollView to avoid overflow
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 66, 64, 64)
                            .withOpacity(0.9),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 18),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    title: Text(
                      'Configure Port',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select IC Setting Type',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 21),
                  _buildLEDTypeExpansionTile(),
                  const SizedBox(height: 20),
                  _buildPortLengthForm(
                      Provider.of<HomeState>(context, listen: false)
                          .currentController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: _submitConfiguration,
                    child: Text(
                      'Save Configuration',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modified Expansion Tile for LED Type
  Widget _buildLEDTypeExpansionTile() {
    return Container(
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
            dividerColor: Colors.transparent, // Removes internal divider
            splashColor: Colors.transparent, // Removes tap splash effect
          ),
          child: ExpansionTile(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            controller: etc,
            dense: false,
            title: Text(
              selectedLEDTypeString ?? 'Type of IC Setting',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black.withOpacity(0.2),
            collapsedBackgroundColor: Colors.black.withOpacity(0.3),
            children: ledTypes.keys.map((String ledType) {
              return ListTile(
                title: Text(
                  ledType,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedLEDTypeString = ledType;
                    selectedLEDTypeValue = ledTypes[ledType];
                    Provider.of<HomeState>(context, listen: false)
                        .setCurrentControllerType(selectedLEDTypeValue!);
                  });
                  etc.collapse();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Updated Port Length Form with small TextFields on the left
  Widget _buildPortLengthForm(Controller controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the length for each port:',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Text field for port length (small box on the left)
                  Text(
                    'Port ${index + 1}:',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 60, // Fixed small width
                    child: TextField(
                      controller: portControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  // Label on the right
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _submitConfiguration() {
    List<int> s =
        List.filled(portControllers.length, 0); // Initialize with zeroes

    for (int i = 0; i < portControllers.length; i++) {
      s[i] = int.tryParse(portControllers[i].text) ?? 0;
    }
    Provider.of<HomeState>(context, listen: false).setCurrentControllerPort(s);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Configuration saved successfully! s12  ' + s.toString())),
    );

    //Go to the screen , Name your Area
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NameYourAreaScreen(),
      ),
    );
  }
}
