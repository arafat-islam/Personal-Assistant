import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:personal_assistant/screens/initial_screen.dart';
import 'screens/location_picker.dart';
import 'package:cron/cron.dart';
import 'dart:math';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'notification.dart';


//dynamic globalLatLng;
double userCurrentLat = 0.0;
double userCurrentLong = 0.0;

void main() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "basic_channel_group",
      channelKey: "basic_channel",
      channelName: "Basic Notification",
      channelDescription: "Basic notifications channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: "basic_channel_group",
      channelGroupName: "Basic Group",
    )
  ]);
  bool isAllowedToSendNotification =
  await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  cron();
  runApp(MyApp());

  requestDNDPermission();
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute: 'home_screen',
      routes: {
        'home_screen': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'My Personal Assistant',
    );
  }
}

//find user's current location
Future<void> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    // Handle the case where the user denies permission
    return;
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
    forceAndroidLocationManager: true,
  );

  userCurrentLat = position.latitude;
  userCurrentLong = position.longitude;

}


double _degreesToRadians(double degrees) {
  return degrees * (pi / 180.0);
}

double calculateDistance(double lat1, double lon1) {

  const double earthRadius = 6371; // Radius of the Earth in kilometers

  // Convert latitude and longitude from degrees to radians
  double lat1Rad = _degreesToRadians(lat1);
  double lon1Rad = _degreesToRadians(lon1);
  double lat2Rad = _degreesToRadians(userCurrentLat); // Example latitude for distance calculation
  double lon2Rad = _degreesToRadians(userCurrentLong); // Example longitude for distance calculation
  // Calculate differences
  double deltaLat = lat2Rad - lat1Rad;
  double deltaLon = lon2Rad - lon1Rad;

  // Haversine formula
  double a = pow(sin(deltaLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Calculate distance in meters
  double distance = earthRadius * c;

  return distance * 1000;
}



// Cron job
Future<void> cron() async {
  final cron = Cron();

  bool isSilentModeNotificationSent = false;
  bool isNormalModeNotificationSent = false;

  cron.schedule(Schedule.parse('*/5 * * * * *'), () async {

    bool isNearSavedLocation = false;

    for (Map<String, String> location in globalSavedLocation) {
      String latitudeString = location['latitude'] ?? '';
      String longitudeString = location['longitude'] ?? '';

      // Parse string values to doubles
      double latitude = double.tryParse(latitudeString) ?? 0.0;
      double longitude = double.tryParse(longitudeString) ?? 0.0;

      // Calculate distance to the saved location
      double distance = calculateDistance(latitude, longitude);

      // Check if the distance is less than 50 meters
      if (distance < 50) {
        isNearSavedLocation = true;
        break;
      }
    }

    // Check if the user is near a saved location and less than 50 meters away
    if (isNearSavedLocation) {
      setDNDMode();
      // Send silent mode notification if not already sent or reset flag if already sent
      if (!isSilentModeNotificationSent) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "basic_channel",
            title: "Silent Mode Activated!",
            body: "Touch to Launch the Application!",
          ),
        );
        isSilentModeNotificationSent = true;
      }
      isNormalModeNotificationSent = false; // Reset normal mode notification flag
    } else {
      setNormalMode();
      // Send normal mode notification if not already sent or reset flag if already sent
      if (!isNormalModeNotificationSent) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 2,
            channelKey: "basic_channel",
            title: "Normal Mode Activated!",
            body: "Touch to Launch the Application!",
          ),
        );
        isNormalModeNotificationSent = true;
      }
      isSilentModeNotificationSent = false; // Reset silent mode notification flag
    }

    // Refresh current location
    getCurrentLocation();
  });
}




//Check the DND permission of the user's phone
Future<void> requestDNDPermission() async {
  final bool? isNotificationPolicyAccessGranted =
  await FlutterDnd.isNotificationPolicyAccessGranted;
  print('Do Not Disturb permission: $isNotificationPolicyAccessGranted');

  if(isNotificationPolicyAccessGranted == false) {
    FlutterDnd.gotoPolicySettings();
  }
}


Future<void> setDNDMode() async {
  await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
}

Future<void> setNormalMode() async {
  await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
}