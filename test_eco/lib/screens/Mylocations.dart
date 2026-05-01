import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'NewLocation.dart';

class MyLocationsScreen extends StatefulWidget {
  const MyLocationsScreen({super.key});

  @override
  State<MyLocationsScreen> createState() => _MyLocationsScreenState();
}

// Global state to simulate persistence across screens
List<Map<String, String>> globalSavedLocations = [];
String? globalSelectedLocation;

class _MyLocationsScreenState extends State<MyLocationsScreen> {
  final Color accentOrange = const Color(0xFFFF6B4A);
  
  final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080",
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY_HERE',
    },
  ));
  
  bool isEditing = false;
  Set<String> selectedForDeletion = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "My Locations",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (globalSavedLocations.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  if (!isEditing) {
                    selectedForDeletion.clear();
                  }
                });
              },
              child: Text(
                isEditing ? "Cancel" : "Edit",
                style: TextStyle(color: accentOrange, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (globalSavedLocations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No locations added yet. Please add a new location.", style: TextStyle(color: Colors.grey)),
              ),
            ...globalSavedLocations.map((location) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildLocationCard(location["title"]!, location["address"]!),
              );
            }).toList(),
            const SizedBox(height: 8),

            // ADD NEW LOCATION BUTTON
            if (!isEditing)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddLocationScreen(),
                    ),
                  );
                  
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      globalSavedLocations.add(result);
                      globalSelectedLocation = result["title"];
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: accentOrange),
                      const SizedBox(width: 8),
                      Text(
                        "Add New Location",
                        style: TextStyle(
                          color: accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    if (selectedForDeletion.isNotEmpty) {
                      setState(() {
                        globalSavedLocations.removeWhere((loc) => selectedForDeletion.contains(loc["title"]));
                        selectedForDeletion.clear();
                        isEditing = false;
                        
                        // Pick next available if selected location was deleted
                        if (!globalSavedLocations.any((loc) => loc["title"] == globalSelectedLocation)) {
                          globalSelectedLocation = globalSavedLocations.isNotEmpty 
                              ? globalSavedLocations.first["title"] 
                              : null;
                        }
                      });
                    }
                  } else {
                    Navigator.pop(context, globalSelectedLocation);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing 
                      ? (selectedForDeletion.isEmpty ? Colors.grey : Colors.red) 
                      : accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isEditing ? "Delete Selected" : "Apply",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String title, String address) {
    bool isSelected = globalSelectedLocation == title; 
    bool isMarkedForDeletion = selectedForDeletion.contains(title);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEditing 
              ? (isMarkedForDeletion ? Colors.red : Colors.grey.shade200)
              : (isSelected ? accentOrange : Colors.grey.shade200),
          width: (isEditing ? isMarkedForDeletion : isSelected) ? 2 : 1,
        ),
      ),
      child: isEditing 
          ? CheckboxListTile(
              value: isMarkedForDeletion,
              activeColor: Colors.red,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedForDeletion.add(title);
                  } else {
                    selectedForDeletion.remove(title);
                  }
                });
              },
            )
          : RadioListTile<String>(
              value: title,
              groupValue: globalSelectedLocation,
              activeColor: accentOrange,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
              secondary: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    globalSavedLocations.removeWhere((loc) => loc["title"] == title);
                    if (globalSelectedLocation == title) {
                      globalSelectedLocation = globalSavedLocations.isNotEmpty 
                          ? globalSavedLocations.first["title"] 
                          : null;
                    }
                  });
                },
              ),
              onChanged: (val) {
                setState(() {
                  globalSelectedLocation = val;
                });
              },
            ),
    );
  }
}
