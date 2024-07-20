import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/firebase_options.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/notes_view.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_email_view.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginView(),
      routes: {
        loginRoute:(context)=>const LoginView(),
        registerRoute:(context)=>const RegisterView(),
        notesRoute:(context)=>const NotesView(),
        verifyEmailRoute:(context)=>const VerifyEmailView(),
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
              final user = (FirebaseAuth.instance.currentUser);
              if (user != null){
                if(user.emailVerified){
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }
              }
              else{
                return const LoginView();
              }
          default:
          return const CircularProgressIndicator();
          }
        },
      );
  }
}

