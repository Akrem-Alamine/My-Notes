import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynote/constants/routes.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState(){
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }
  @override
  void dispose(){
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text("Login") ,backgroundColor: Colors.blue,),
      body: Column(
        children: [
          TextField(
                        controller: _email,
                        enableSuggestions: true,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email here'
                        ),
                      ),
          TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'Enter your password here'
                        ),
                      ),
          TextButton(onPressed: () 
            async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email, 
                  password: password,
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute, 
                  (route)=>false,
                );
              } 
              on FirebaseAuthException catch (e) {
                if(e.code == 'invalid-credential'){
                  devtools.log("User Or Password Incorrect");
                }
              }
            }, 
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route)=>false,
              );
            } ,
            child: const Text("Not Registred yet? Register here ..")
          ),
        ],
      ),
    );
  }
}