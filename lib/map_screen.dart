import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  int _currentIndex = 0;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Timer? _timer;

  final List<LatLng> _route = List.generate(50, (i) => LatLng(35.1596 + i * 0.0003, 129.0602 + i * 0.0004));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _startRoutePlayback);
  }

  void _startRoutePlayback() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentIndex >= _route.length) {
        timer.cancel();
        return;
      }

      final current = _route[_currentIndex];
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId("runner"),
            position: current,
            infoWindow: InfoWindow(title: "Point ${_currentIndex + 1}"),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: const PolylineId("route_line"),
            color: Colors.blue,
            width: 4,
            points: _route.sublist(0, _currentIndex + 1),
          ),
        };
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(current));

      _currentIndex++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("경로 재생 (하드코딩 좌표)")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _route.first, zoom: 17),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
