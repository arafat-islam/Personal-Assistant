import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'SavedLocationScreen.dart';
List<Map<String, String>> globalSavedLocation = [];

class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  List<Map<String, String>> savedLocations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a location'),
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
                _navigateToSavedLocations();
              },
            ),
            ListTile(
              title: const Text('Choose a Location'),
              onTap: () {
                Navigator.pop(context);
                _navigateToChooseLocation();
              },
            ),
          ],
        ),
      ),
      body: MapLocationPicker(
        apiKey: 'AIzaSyCUeKu2PaWdS-Ar30A0crrU5yv-3bMDA9E',
        onNext: (geocodingResult) async {
          bool locationExists = savedLocations.any((location) =>
          location['latitude'] ==
              geocodingResult?.geometry?.location.lat.toString() &&
              location['longitude'] ==
                  geocodingResult?.geometry?.location.lng.toString());

          if (locationExists) {
            _showLocationExistsPopup(context);
          } else {
            bool addLocationConfirmed =
            await _showAddLocationConfirmation(context, geocodingResult);
            if (addLocationConfirmed) {
              await saveLocationToLocal(geocodingResult!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedLocationScreen(
                    savedLocations: savedLocations,
                  ),
                ),
              );
            }
          }
        },
        onDecodeAddress: (geocodingResult) {},
        hideMapTypeButton: true,
        hideBackButton: true,
        currentLatLng: const LatLng(22.657351, 90.3609364),
      ),
    );
  }

  Future<void> saveLocationToLocal(GeocodingResult geocodingResult) async {
    String latitude =
        geocodingResult?.geometry?.location.lat.toString() ?? '';
    String longitude =
        geocodingResult?.geometry?.location.lng.toString() ?? '';
    String placeName = geocodingResult?.formattedAddress ?? '';

    savedLocations.add({
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
    });
  }

  void _navigateToSavedLocations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedLocationScreen(
          savedLocations: savedLocations,
        ),
      ),
    );
  }

  void _navigateToChooseLocation() {
    // Add your logic to navigate to the page for choosing a location
  }

  void _showLocationExistsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Already Exists!'),
          content: const Text('The location already exists in your saved locations.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showAddLocationConfirmation(
      BuildContext context, GeocodingResult? geocodingResult) async {
    String locationName = geocodingResult?.formattedAddress ?? 'this location';
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Use this Place?'),
          content: Text('Are you sure you want to add $locationName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, don't add location
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, add location
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if the dialog is dismissed
  }


}
