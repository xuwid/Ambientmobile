import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:ambient/widgets/background_widget.dart'; // Import your BackgroundWidget
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AmbientLightsAccount extends StatelessWidget {
  const AmbientLightsAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  margin: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Transparent background
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey, // Color of the bottom border
                        width: 0.5, // Width of the bottom border
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
                      const SizedBox(
                          width: 10), // Space between the icon and text
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(
                                width: 10), // Space between the icon and text
                            Text(
                              'AmbientLights Account', // Fixed title text
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Add padding to the entire content
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        width: 370,
                        height: 51,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              0.4), // Match with background gradient
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Text(
                              userEmail ?? 'No email',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        margin: const EdgeInsets.only(bottom: 20),
                        width: 370,
                        height: 51,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              0.4), // Match with background gradient
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              try {
                                if (userEmail != null) {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(email: userEmail);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Password reset email sent')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('No email found')),
                                  );
                                }
                              } catch (e) {
                                print('Error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to send password reset email')),
                                );
                              }
                            },
                            child: Text(
                              'Password Reset',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        margin: const EdgeInsets.only(bottom: 20),
                        width: 370,
                        height: 51,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              0.4), // Match with background gradient
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await user.delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('User Deleted Successfully')),
                                  );
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('No user logged in')),
                                  );
                                }
                              } catch (e) {
                                print('Error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to delete account')),
                                );
                              }
                            },
                            child: Text(
                              'Delete Account',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        margin: const EdgeInsets.only(bottom: 60),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            } catch (e) {
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to log out')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            textStyle: GoogleFonts.montserrat(fontSize: 16),
                          ),
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
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
