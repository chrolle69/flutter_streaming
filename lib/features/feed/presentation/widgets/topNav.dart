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
            print("profile");
          }
        )
      ],
    );
  }
}