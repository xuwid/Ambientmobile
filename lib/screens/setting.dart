import 'package:ambient/screens/ambients_lights_account.dart';
import 'package:ambient/screens/area_screen.dart';
import 'package:ambient/screens/controller_setup.dart';
import 'package:ambient/screens/timeZone.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Center(
            // Center the content horizontally and vertically
            child: SingleChildScrollView(
              // Allow scrolling if content overflows
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Size the column to fit its content
                children: [
                  _buildSettingsOption(
                    context,
                    title: 'AmbientLights Account',
                    icon: Icons.account_circle_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AmbientLightsAccount(),
                      ),
                    ),
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Controllers Setup',
                    icon: Icons.settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ControllerSetup(),
                      ),
                    ),
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Area Setup',
                    icon: Icons.layers_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AreaScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Time Zone and Location',
                    icon: Icons.access_time,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimezoneScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0x40000000),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 25, color: Colors.white),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
