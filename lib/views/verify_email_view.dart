import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title:const Text("Verify email") ,backgroundColor: Colors.blue,),
      body: Column(
          children: [
            const Text('We have sent you an email verication'),
            const Text('If You have not recived an email click this button'),
            TextButton(onPressed:(){
              final user = FirebaseAuth.instance.currentUser;
              user?.sendEmailVerification();
            }, 
            child: const Text("Send email Verification:")
            )
          ],
        ),
    );
  }
}