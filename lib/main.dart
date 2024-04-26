import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_with_google/ui/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyA6ubSmkCpSxIuMS6LpfyRJd_dFYQDoZik",
        authDomain: "loginwithtest-ef740.firebaseapp.com",
        projectId: "loginwithtest-ef740",
        storageBucket: "loginwithtest-ef740.appspot.com",
        messagingSenderId: "776590751581",
        appId: "1:776590751581:web:45ac470059b022db279ab4",
        measurementId: "G-SF0TX1CM4D"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
