import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("About"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "This application is designed to facilitate communication for individuals with speech impairments. It provides tools for gesture recognition, text-to-speech conversion, and more.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
