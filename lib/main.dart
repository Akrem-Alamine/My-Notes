import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/firebase_options.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/register_view.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/':(context)=>const LoginView(),
        '/register/':(context)=>const RegisterView(),
      },
    ),);
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              // final user = (FirebaseAuth.instance.currentUser);
              // if(user?.emailVerified??false){
              //   print('You are verified user');
              // }
              // else {
              //   return const VerifyEmailView();
              // }
              // return const Text("Done"); 
              return const LoginView();
          default:
          return const CircularProgressIndicator();
          }
        },
      );
  }
}