import 'package:flutter/material.dart';
import 'SavedLocationScreen.dart';
import 'location_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Trigger the fade-in animation after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Assistant'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
              ),
              child: const Text(
                'Personal Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Saved Locations'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSavedLocations(context);
              },
            ),
            ListTile(
              title: const Text('Location Picker'),
              onTap: () {
                Navigator.pop(context);
                _navigateToLocationPicker(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: opacity,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Personal Assistant!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your ultimate location-based personal assistant',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSavedLocations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedLocationScreen(savedLocations: []),
      ),
    );
  }

  void _navigateToLocationPicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(),
      ),
    );
  }
}