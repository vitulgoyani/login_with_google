import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_with_google/ui/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? user;

  checkUserIsLoginOrNot() async {
    bool isLogin = await _googleSignIn.isSignedIn();
    if (isLogin) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Dashboard();
      }), (route) => false);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } else {
      print("Google Sign-in cancelled");
      return null;
    }
  }

  createUser({User? user}) async {
    await FirebaseFirestore.instance.collection('User').doc(user?.uid).set({
      'userId': user?.uid,
      'userName': user?.displayName,
      'userImage': user?.photoURL,
      'userEmail': user?.email,
    }).then((_) async {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const Dashboard(),
          ),
          (route) => false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserIsLoginOrNot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Center(
                child: FlutterLogo(
                  size: 100,
                ),
              ),
              Text(
                "Login With Google",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 200,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        UserCredential? user = await signInWithGoogle();
                        debugPrint(user.toString());
                        if(user !=null){
                          createUser(user: user.user);
                        }
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/icons8-google-48.png",
                            height: 30,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Sign In",
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
