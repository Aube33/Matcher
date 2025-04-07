import 'package:flutter/material.dart';
import 'package:subtil_app/services/notifs_service.dart';


final notifications = Notifications();

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton(
            child: const Text('Se connecter 2'),
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
    );
  }
}

