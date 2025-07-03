import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RunDetailMap extends StatefulWidget {
  const RunDetailMap({super.key});

  @override
  State<RunDetailMap> createState() => _RunDetailMapState();
}

class _RunDetailMapState extends State<RunDetailMap> {
  GoogleMapController? _mapController;
  final String orsApiKey = '5b3ce3597851110001cf624848765d69431544e6ad3c08cbf475dacd'; // 🔐 ORS API 키 입력

  final List<LatLng> _allCoordinates = [
    // LatLng(37.569230, 126.991195), // 광화문 앞
    // LatLng(37.569327, 126.991250),
    // LatLng(37.569500, 126.991400),
    // LatLng(37.569700, 126.991600),
    // LatLng(37.569900, 126.991800),
    // LatLng(37.570100, 126.992000),
    // LatLng(37.570300, 126.992200),
    // LatLng(37.570500, 126.992400),
    // LatLng(37.570700, 126.992600),
    // LatLng(37.570900, 126.992800),
    // LatLng(37.571100, 126.993000),
    // LatLng(37.571300, 126.993200),
    // LatLng(37.571500, 126.993400),
    // LatLng(37.571700, 126.993600),
    // LatLng(37.571900, 126.993800),
    // LatLng(37.572100, 126.994000),
    // LatLng(37.572300, 126.994200),
    // LatLng(37.572500, 126.994400),
    // LatLng(37.572700, 126.994600),
    // LatLng(37.572900, 126.994800),
    LatLng(35.159574, 129.060372),
    LatLng(35.155958, 129.061460),
  ];

  final List<LatLng> _polylineCoordinates = [];
  int _currentIndex = 0;
  Timer? _drawTimer;

  @override
  void initState() {
    super.initState();
    _fetchORSRoute();
  }

  Future<void> _fetchORSRoute() async {
    final body = jsonEncode({
      "coordinates": _allCoordinates.map((e) => [e.longitude, e.latitude]).toList(),
      "instructions": false,
    });

    final response = await http.post(
      Uri.parse('https://api.openrouteservice.org/v2/directions/foot-walking/geojson'),
      headers: {'Authorization': orsApiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      final snapped = coords.map((e) => LatLng(e[1], e[0])).toList();

      setState(() {
        _polylineCoordinates.clear();
        _polylineCoordinates.addAll(snapped);
      });

      _startDrawing();
    } else {
      print('❌ ORS 요청 실패: ${response.statusCode}');
      print(response.body);
    }
  }

  void _startDrawing() {
    _drawTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentIndex < _polylineCoordinates.length) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(_polylineCoordinates[_currentIndex]));
        setState(() {
          _currentIndex++;
        });
      } else {
        timer.cancel();
        print('🎉 경로 그리기 완료');
      }
    });
  }

  @override
  void dispose() {
    _drawTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ORS 보행자 경로 보기")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _allCoordinates[0], zoom: 18),
        onMapCreated: (controller) => _mapController = controller,
        polylines: {
          Polyline(
            polylineId: const PolylineId("orsPath"),
            color: Colors.blue,
            width: 5,
            points: _polylineCoordinates.sublist(0, _currentIndex),
          ),
        },
        markers: {
          if (_currentIndex > 0)
            Marker(markerId: const MarkerId("current"), position: _polylineCoordinates[_currentIndex - 1]),
        },
      ),
    );
  }
}
