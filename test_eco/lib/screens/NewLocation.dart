import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080",
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY_HERE',
    },
  ));

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(
    36.7372,
    3.0863,
  ); // Default (e.g., Algiers)
  final Color accentOrange = const Color(0xFFFF6B4A);
  
  final TextEditingController _yourLocationController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  @override
  void dispose() {
    _yourLocationController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition(); // This asks for permission immediately
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable them in device settings.')),
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // This triggers the "Allow" or "Deny" system dialog
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetching location...'), duration: Duration(seconds: 1)),
        );
      }

      // If allowed, get position and move camera
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
      
      await _updateAddress(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _updateAddress(double lat, double lng, {bool updateNameField = false}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.country != null && place.country!.isNotEmpty) addressParts.add(place.country!);
        
        String address = addressParts.join(", ");
        
        if (mounted) {
          setState(() {
            _yourLocationController.text = address;
            if (updateNameField) {
              _locationNameController.text = place.name ?? place.locality ?? address;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _yourLocationController.text = "$lat, $lng";
          if (updateNameField) {
            _locationNameController.text = "$lat, $lng";
          }
        });
      }
    }
  }

  Future<void> _searchLocationByName() async {
    if (_locationNameController.text.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(_locationNameController.text);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(loc.latitude, loc.longitude);
          });
        }
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
        await _updateAddress(loc.latitude, loc.longitude);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find location.')),
        );
      }
    }
  }

  Future<void> _handleLocationNameIconTap() async {
    if (_locationNameController.text.isNotEmpty) {
      await _searchLocationByName();
    } else {
      await _updateAddress(_currentPosition.latitude, _currentPosition.longitude, updateNameField: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Location",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REAL GOOGLE MAP
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      myLocationEnabled: true, // Shows the blue dot
                      myLocationButtonEnabled: false, // We use our own button
                      onCameraIdle: () {
                        _updateAddress(_currentPosition.latitude, _currentPosition.longitude);
                      },
                      onCameraMove: (position) {
                        _currentPosition = position.target;
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(
                            Icons.my_location,
                            color: Colors.black,
                          ),
                          onPressed: _determinePosition,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: SizedBox(width: 40, child: Divider(thickness: 4)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              "Your Location",
              null,
              controller: _yourLocationController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "Location Name",
              Icons.location_on_outlined,
              controller: _locationNameController,
              onIconTap: _handleLocationNameIconTap,
              onSubmitted: (_) => _searchLocationByName(),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_locationNameController.text.isEmpty || _yourLocationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a location name and select a location.')),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    "title": _locationNameController.text,
                    "address": _yourLocationController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
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

  Widget _buildTextField(
    String hint,
    IconData? icon, {
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onIconTap,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        // We wrap the icon in an IconButton so it is clickable
        suffixIcon: icon != null
            ? IconButton(
                icon: Icon(icon, color: Colors.black),
                onPressed: onIconTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
