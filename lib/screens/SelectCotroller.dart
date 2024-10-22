import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/name_your_area.dart';

class SelectControllerScreen extends StatefulWidget {
  const SelectControllerScreen({super.key});

  @override
  State<SelectControllerScreen> createState() => _SelectControllerScreenState();
}

class _SelectControllerScreenState extends State<SelectControllerScreen> {
  late List<Controller> _localControllers;
  Controller? _selectedController;

  @override
  void initState() {
    super.initState();
    final homeState = Provider.of<HomeState>(context, listen: false);

    // Initialize local controllers with the state from HomeState
    _localControllers = homeState.controllers.map((controller) {
      return Controller(
          name: controller.name,
          isActive: false,
          id: controller.id,
          type: controller.type,
          device: controller.device,
          portlength: controller.portlength);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<HomeState>(context, listen: false);
    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 60),
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 66, 64, 64).withOpacity(0.9),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Text(
                'Select Controller',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _localControllers.length,
                itemBuilder: (context, index) {
                  final controller = _localControllers[index];
                  return ListTile(
                    leading: Switch(
                      value: controller.isActive,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            // If there's already a selected controller, deactivate it
                            if (_selectedController != null) {
                              _selectedController!.isActive = false;
                            }

                            // Activate the newly selected controller
                            controller.isActive = true;
                            _selectedController = controller;
                          } else {
                            // If the same controller is deactivated
                            controller.isActive = false;
                            _selectedController = null;
                          }
                        });
                      },
                      inactiveTrackColor: const Color.fromARGB(255, 49, 46, 46),
                      thumbColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.white; // Thumb color when selected
                        }
                        return Colors.white; // Thumb color when not selected
                      }),
                      trackColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.purple
                              .withOpacity(0.5); // Track color when selected
                        }
                        return const Color.fromARGB(
                            255, 49, 46, 46); // Track color when not selected
                      }),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,
                          size: 24, color: Colors.white)), // Larger thumb size
                    ),
                    title: Text(
                      controller.name,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    tileColor: controller.isActive
                        ? Colors.purple.withOpacity(0.2)
                        : Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                height: 50,
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    homeState.setCurrentController(_selectedController!);
                    print(homeState.currentController.name);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NameYourAreaScreen()),
                    );
                  },
                  child: Text(
                    'Next Step',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
