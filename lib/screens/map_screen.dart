import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Markers'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Initial map center
          zoom: 12.0, // Initial zoom level
        ),
        markers: markers,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      // Add multiple markers
      _addMarkers([
        LatLng(37.7749, -122.4194),
        LatLng(37.7752, -122.4187),
        LatLng(37.7745, -122.4168),
        LatLng(37.7739, -122.4150),
      ]);
    });
  }

  void _addMarkers(List<LatLng> positions) {
    for (LatLng position in positions) {
      Marker marker = Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
          title: 'Marker Title',
          snippet: 'Marker Snippet',
        ),
      );

      markers.add(marker);
    }
  }


}
