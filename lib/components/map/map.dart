import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

final String ggApiKey = dotenv.env['MAPS_API_KEY'] ?? '';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _center = LatLng(10.877494264335212, 106.80155606351516);

  Set<Marker> _markers = {};
  final Location _locationController = Location();
  LatLng? _currentP;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    loadMarkersFromJson().then((markers) {
      setState(() {
        _markers = markers;
      });
    });
    getLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<Set<Marker>> loadMarkersFromJson() async {
    final String jsonString = await rootBundle.loadString(
      'lib/database/vets.json',
    );
    final List<dynamic> data = json.decode(jsonString);

    final Set<Marker> markers =
        data.map((item) {
          final String address = item['address'] ?? '';
          final String phone = item['phone'] ?? '';
          final String snippet =
              phone.isNotEmpty
                  ? 'Địa Chỉ: $address\n  Sdt: $phone'
                  : 'Địa chỉ: $address';

          return Marker(
            markerId: MarkerId(item['id']),
            position: LatLng(item['lat'], item['lng']),
            infoWindow: InfoWindow(title: item['title'], snippet: snippet),
          );
        }).toSet();

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body:
          _currentP == null
              ? const Center(child: Text("Loading"))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 12,
                ),
                markers:
                    _markers..add(
                      Marker(
                        markerId: MarkerId('current'),
                        position: _currentP!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                        infoWindow: InfoWindow(title: 'your location'),
                      ),
                    ),
              ),
    );
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    permission = await _locationController.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _locationController.requestPermission();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _currentP = _center;
        });
      }
    }

    _locationSubscription = _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null &&
          mounted) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }
}
