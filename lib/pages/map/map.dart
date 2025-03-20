import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _center = LatLng(10.877494264335212, 106.80155606351516);

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('_shop1'),
      position: LatLng(10.86780418952679, 106.78374588319642),
      infoWindow: InfoWindow(
        title: 'THÚ CƯNG MÉO_MÉO PETSHOP',
        snippet: '17/19 Đường T2, Đông Hoà, Thủ Đức, Hồ Chí Minh, Việt Nam',
      ),
    ),
    Marker(
      markerId: MarkerId('shop2'),
      position: LatLng(10.872271594854226, 106.80022537463749),
      infoWindow: InfoWindow(
        title: 'Méo Cửa Hàng Thú Cưng',
        snippet: 'Đông Hòa, Dĩ An, Bình Dương, Việt Nam',
      ),
    ),
    Marker(
      markerId: MarkerId('shop3'),
      position: LatLng(10.859206353362234, 106.77447616926081),
      infoWindow: InfoWindow(
        title: 'Thế giới thú cưng',
        snippet: '113/4 Đ. Số 8, Phường Linh Trung, Thủ Đức, Hồ Chí Minh, Việt Nam',
      ),
    ),
  };
  Location _locationController = Location();
  LatLng? _currentP = null;
  List<Polyline> _polyline = [];

  @override
  void initState() {
    super.initState();
    getLocation().then((_) {
      getPolyline().then((polylineCoordinates) {
        generatePolyline(polylineCoordinates);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 12)));
    bool _serviceEnabled;
    PermissionStatus _permission;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permission = await _locationController.hasPermission();
    if (_permission == PermissionStatus.denied) {
      _permission = await _locationController.requestPermission();
      if (_permission != PermissionStatus.granted) {
        return;
      }
    }
    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  Future<List<LatLng>> getPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];
    LatLng _shop1 = _markers.elementAt(0).position;
    LatLng _shop2 = _markers.elementAt(1).position;
    LatLng _shop3 = _markers.elementAt(2).position;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyB3VY3jzjHLjNO4VUN-1mLiSwGxWJlBEmc',
      request: PolylineRequest(
        origin: _currentP as PointLatLng,
        destination: _shop2 as PointLatLng,
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("error");
    }
    return polylineCoordinates;
  }

  void generatePolyline(List<LatLng> polylineCoordinates) async {
    List<LatLng> polylineCoordinates = await getPolyline();
    if (polylineCoordinates.isNotEmpty) {
      setState(() {
        _polyline.add(
          Polyline(
            polylineId: PolylineId('poly'),
            color: Colors.red,
            points: polylineCoordinates,
            width: 10,
          ),
        );
      });
    }
  }
}