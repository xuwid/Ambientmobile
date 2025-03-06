import 'package:ambient/screens/edit_area.dart';
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
  String? selectedArea; // Variable to store the selected area
  Area? _selectedArea;
  final ExpansionTileController etc = ExpansionTileController();

  Widget _buildAreaSelectionExpansionTile() {
    final homeState = Provider.of<HomeState>(context);
    final areas = homeState.areas;

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
                selectedArea ?? 'Select an Area',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black.withOpacity(0.2),
              collapsedBackgroundColor: Colors.black.withOpacity(0.3),
              children: areas.map((area) {
                return ListTile(
                  title: Text(
                    area.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedArea = area.title;
                      _selectedArea = area;
                    });
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
                      const Spacer(),
                      const Image(
                          image: AssetImage("assets/zone_setup.png"),
                          width: 28,
                          color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Area Setup',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          //it shi
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
              _buildAreaSelectionExpansionTile(),
              if (_selectedArea != null)
                Expanded(
                  child: EditArea(
                    key:
                        ValueKey(_selectedArea!.id), // Unique key for each area
                    area: _selectedArea!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
