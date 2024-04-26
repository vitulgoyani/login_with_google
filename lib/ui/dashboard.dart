import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _auth.signOut();
            _googleSignIn.signOut();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }), (route) => false);
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
