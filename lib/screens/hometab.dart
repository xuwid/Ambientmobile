import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:ambient/screens/add_controller_screen.dart';
import 'package:ambient/screens/SelectCotroller.dart';
import 'package:ambient/widgets/menu_buttons.dart';
import 'package:ambient/widgets/area_widget.dart';
import 'package:ambient/widgets/controller_widget.dart';
import 'package:ambient/models/state_models.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final User? currentUser; // Use late initialization
  late bool admin = false;

  @override
  void initState() {
    super.initState();

    currentUser = FirebaseAuth.instance.currentUser;

    // Check if user is authenticated
    if (currentUser != null) {
      // Fetch areas for the current user when the widget is initialized
      final homeState = Provider.of<HomeState>(context, listen: false);
      homeState.getAreasForUser(currentUser!.uid);
      homeState.getControllersForUser();
      _checkAdminStatus(homeState);

      // _checkAdminStatus(homeState);
    } else {
      // Handle the case where there is no current user
      // For example, you might want to show a login screen or an error message
    }
  }

  Future<void> _checkAdminStatus(HomeState homeState) async {
    admin = await homeState.checkIfUserIsAdmin();
    // You can use setState if you need to trigger a rebuild after this check
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<HomeState>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(child: ColoredBox(color: Color(0xFF161616))),
          // Content overlay
          Column(
            children: [
              Container(
                color: Colors.transparent,
                child: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(
                    admin ? 'Admin' : 'Home',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _showBottomSheetMenu(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Areas section
                    Text(
                      'Areas',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAreaList(homeState),
                    const SizedBox(height: 32),
                    // Controllers section
                    Text(
                      'Controllers',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildControllerList(homeState),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Blur effect for the entire screen
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // Menu content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(
                      255, 54, 51, 51), // Set background color to grey
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddNewAreaButton(onPressed: () {
                      // Navigate to Select Controller Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SelectControllerScreen();
                          },
                        ),
                      );
                    }),
                    AddNewControllerButton(onPressed: () {
                      // Navigate to Add Controller Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddControllerScreen(),
                        ),
                      );
                    }),
                    const Divider(
                        color: Colors.white), // Divider between options
                    CancelButton(onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAreaList(HomeState homeState) {
    return Column(
      children: homeState.areas.asMap().entries.map((entry) {
        int index = entry.key;
        Area area = entry.value;

        return RoofLineWidget(
          title: area.title,
          isActive: area.isActive, // Check if the area is active
          onToggle: (value) {
            homeState.toggleArea(index, value); // Toggle the active state
          },
          index: index, // Pass index if needed for other purposes
        );
      }).toList(),
    );
  }

  Widget _buildControllerList(HomeState homeState) {
    return Column(
      children: homeState.controllers.asMap().entries.map((entry) {
        int index = entry.key;
        Controller controller = entry.value;
        return ControllerWidget(
          title: controller.name,
          isActive: controller.isActive, // Display the active state
          onToggle: (value) {
            homeState.showControllerStatusByIndex(context, index);
          },

          index: index, // Pass index to determine background image
        );
      }).toList(),
    );
  }
}
