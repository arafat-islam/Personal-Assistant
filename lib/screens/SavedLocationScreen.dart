import 'package:flutter/material.dart';
import 'package:personal_assistant/screens/location_picker.dart';

class SavedLocationScreen extends StatefulWidget {
  final List<Map<String, String>> savedLocations;

  SavedLocationScreen({required this.savedLocations});

  @override
  _SavedLocationScreenState createState() => _SavedLocationScreenState();
}

class _SavedLocationScreenState extends State<SavedLocationScreen> {
  List<Map<String, String>> savedLocations = [];

  @override
  void initState() {
    super.initState();
    savedLocations = widget.savedLocations;
  }

  @override
  Widget build(BuildContext context) {

    globalSavedLocation = savedLocations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: savedLocations.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                title: Text(savedLocations[index]['placeName'] ?? 'N/A', style: const TextStyle(fontSize: 16)),
                // subtitle: Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text('Latitude: ${savedLocations[index]['latitude']}'),
                //     Text('Longitude: ${savedLocations[index]['longitude']}'),
                //   ],
                // ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editLocationName(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _removeLocation(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _editLocationName(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();

        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Enter new name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    savedLocations[index]['placeName'] = newName;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _removeLocation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this location?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedLocations.removeAt(index); // Remove the location
                });
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

}
