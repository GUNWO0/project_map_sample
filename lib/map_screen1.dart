import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // 더미 위치 (강남역)
  final LatLng _dummyPosition = const LatLng(37.4979, 127.0276);
  bool _mapReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map - 더미 위치 테스트")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _dummyPosition, zoom: 14),
        onMapCreated: (controller) {
          _mapController = controller;
          setState(() {
            _mapReady = true;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId("dummy"),
            position: _dummyPosition,
            infoWindow: const InfoWindow(title: "더미 위치 (강남역)"),
          ),
        },
      ),
    );
  }
}
