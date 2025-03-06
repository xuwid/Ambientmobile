import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';
import 'package:ambient/screens/homescreen.dart';
import 'package:ambient/screens/Signup.dart';
import 'admin_screen.dart'; // Import your AdminScreen
import 'forgot_password_screen.dart'; // <-- Import the ForgotPasswordScreen

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  var isAuthenticating = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _submitLogin() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();
    setState(() {
      isAuthenticating = true;
    });

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final isAdmin = userDoc.data()?['isAdmin'] ?? false;

      // If user is not an admin, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred, please check your credentials!';
      if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email TextField
                      Container(
                        width: 360,
                        height: 51,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            fillColor: const Color(0xff606060),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: Color(0xff606060),
                                width: 2,
                              ),
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

                      // Password TextField
                      Container(
                        width: 360,
                        height: 51,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            fillColor: const Color(0xff606060),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: Color(0xff606060),
                                width: 2,
                              ),
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

                      // "Forgot Password?" link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.montserrat(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Button
                      if (isAuthenticating)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: 350,
                          height: 51,
                          child: ElevatedButton(
                            onPressed: _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: GoogleFonts.montserrat(fontSize: 20),
                            ),
                            child: const Text('Login'),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Create an Account
                      SizedBox(
                        width: 350,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.blue,
                            textStyle: GoogleFonts.montserrat(fontSize: 20),
                            side:
                                const BorderSide(color: Colors.blue, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text('Create an Account'),
                        ),
                      ),

                      const SizedBox(height: 20),
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
