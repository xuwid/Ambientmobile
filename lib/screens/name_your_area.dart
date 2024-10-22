import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/segmentScreen.dart';

class NameYourAreaScreen extends StatefulWidget {
  const NameYourAreaScreen({super.key});

  @override
  State<NameYourAreaScreen> createState() => _NameYourAreaScreenState();
}

class _NameYourAreaScreenState extends State<NameYourAreaScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<HomeState>(context);

    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              title: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Name Your Area',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Spacer()
                ],
              ),
              centerTitle: true,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter area name',
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.clear,
                          color: Colors.white, size: 18),
                      onPressed: () {
                        _textController.clear();
                      },
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        homeState.setCurrentNameYourArea(_textController.text);
                        print(homeState.currentNameYourArea);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SegmentsScreen()),
                        );
                      }
                    },
                    child: Text(
                      'Next',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
