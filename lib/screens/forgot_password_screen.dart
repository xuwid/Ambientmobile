import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/background_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _isSendingReset = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitResetRequest() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();

    setState(() {
      _isSendingReset = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Check your email.'),
        ),
      );
      Navigator.of(context).pop(); // Return to Login page
    } on FirebaseAuthException catch (e) {
      var message = 'Error occurred. Please try again!';
      if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isSendingReset = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend behind the app bar for the same style
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
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
              children: [
                const SizedBox(height: 150),
                Text(
                  'Reset Password',
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
                            hintText: 'Enter your email',
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!.trim();
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Send Reset Link button
                      if (_isSendingReset)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: 350,
                          height: 51,
                          child: ElevatedButton(
                            onPressed: _submitResetRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: GoogleFonts.montserrat(fontSize: 20),
                            ),
                            child: const Text('Send Reset Link'),
                          ),
                        ),
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
