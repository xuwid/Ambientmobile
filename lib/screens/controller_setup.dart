import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:ambient/models/state_models.dart';
import 'package:provider/provider.dart';
import 'package:ambient/wirelessProtocol/mqtt.dart';

class ControllerSetup extends StatefulWidget {
  @override
  _ControllerSetupState createState() => _ControllerSetupState();
}

class _ControllerSetupState extends State<ControllerSetup> {
  String? selectedController;
  Controller? _selectedController;
  final ExpansionTileController etc = ExpansionTileController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildControllerSelectionExpansionTile() {
    final homeState = Provider.of<HomeState>(context);
    final controllers = homeState.controllers;

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
              controller: etc,
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                selectedController ?? 'Select a Controller',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black.withOpacity(0.2),
              collapsedBackgroundColor: Colors.black.withOpacity(0.3),
              children: controllers.map((contr) {
                return ListTile(
                  title: Text(
                    contr.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedController = contr;
                      selectedController = contr.name;
                      _nameController.text =
                          contr.name; // Initialize with current name
                    });

                    Provider.of<HomeState>(context, listen: false)
                        .setCurrentController(contr);
                    etc.collapse();
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const Spacer(),
                        const Image(
                            image: AssetImage('assets/controller_setup.png'),
                            width: 28),
                        const SizedBox(width: 3),
                        Text(
                          'Controller Setup',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Spacer()
                      ],
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              _buildControllerSelectionExpansionTile(),
              if (_selectedController != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Rename Controller',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              selectedController = _nameController.text;
                            });

                            // Update the controller name in the database
                            final homeState =
                                Provider.of<HomeState>(context, listen: false);
                            homeState.renameController(_nameController.text);

                            await homeState
                                .sendRenameDataMQTT(_nameController.text);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Controller name updated successfully!',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );

                            // Update the controller name in the MQTT server
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Update Name',
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
