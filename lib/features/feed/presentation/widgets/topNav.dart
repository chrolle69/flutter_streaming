import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopNav extends StatelessWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Streams"),
      actions: [
        IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/sign-in');
            })
      ],
    );
  }
}
