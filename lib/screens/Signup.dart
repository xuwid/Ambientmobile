import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:ambient/screens/homescreen.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/screens/Login.dart'; // Import the Login page

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredUsername = '';
  var isAuthenticating = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future _createDefaultAreas() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;

    if (currentUserId == null) {
      print('Error: No user logged in.');
      return;
    }

    try {
      final userDoc = firestore.collection('users').doc(currentUserId);

      List<Area> defaultAreas = [
        Area(
          id: '', // Will be set after creation
          title: "Roofline",
          controller: [Controller("Main")],
          zones: [
            Zone(
              title: "Zone 1",
              ports: [
                Port(portNumber: 1, isEnable: true),
                Port(portNumber: 2, isEnable: false),
                Port(portNumber: 3, isEnable: false),
                Port(portNumber: 4, isEnable: false),
              ],
            ),
          ],
        ),
        Area(
          id: '', // Will be set after creation
          title: "Landscape Lights",
          controller: [Controller("Pool House")],
          zones: [],
        ),
      ];

      for (var area in defaultAreas) {
        final newAreaRef = userDoc
            .collection('areas')
            .doc(); // Automatically generates a new ID
        await newAreaRef.set(area.copyWith(id: newAreaRef.id).toMap());
        print('Area added with ID: ${newAreaRef.id}');
      }
    } catch (e) {
      print('Failed to add default areas: $e');
    }
  }

  void _submitSignup() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isAuthenticating = true;
    });

    try {
      await auth.createUserWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // Create default areas for the new user
      await _createDefaultAreas();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred, please check your credentials!';
      if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BackgroundWidget(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150),
                Text(
                  'Create an Account',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 360,
                        height: 51,
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            fillColor: Color(0xff606060),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                  color: Color(0xff606060), width: 2),
                            ),
                          ),
                          onSaved: (value) {
                            enteredUsername = value!;
                          },
                        ),
                      ),
                      Container(
                        width: 360,
                        height: 51,
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            fillColor: Color(0xff606060),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                  color: Color(0xff606060), width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredEmail = value!;
                          },
                        ),
                      ),
                      Container(
                        width: 360,
                        height: 51,
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            fillColor: Color(0xff606060),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                  color: Color(0xff606060), width: 2),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredPassword = value!;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      if (isAuthenticating)
                        CircularProgressIndicator()
                      else
                        Container(
                          width: 350,
                          height: 51,
                          child: ElevatedButton(
                            onPressed: _submitSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: GoogleFonts.montserrat(
                                fontSize: 20,
                              ),
                            ),
                            child: Text('Sign Up'),
                          ),
                        ),
                      SizedBox(height: 20),
                      Container(
                        width: 350,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.blue,
                            textStyle: GoogleFonts.montserrat(
                              fontSize: 20,
                            ),
                            side: BorderSide(color: Colors.blue, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text('Login'),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
