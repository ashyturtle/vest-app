import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final LatLng _defaultCenter = const LatLng(-33.86, 151.20);
  final TextEditingController _searchController = TextEditingController();

  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isNavigating = false;

  // Location
  loc.LocationData? _currentLocation;
  final loc.Location _locationService = loc.Location();

  // Directions API
  final String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your API key

  // Navigation Mode
  String _travelMode = 'walking'; // Default mode

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationService.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _locationService.getLocation();
    _locationService.onLocationChanged.listen((loc.LocationData locationData) {
      setState(() {
        _currentLocation = locationData;
        _updateUserMarker();
      });
    });

    setState(() {});
  }

  void _updateUserMarker() {
    if (_currentLocation == null) return;

    LatLng position =
    LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    _markers.removeWhere((marker) => marker.markerId.value == 'user_location');

    _markers.add(Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      infoWindow: const InfoWindow(title: 'Your Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;

    final GoogleMapController controller = await _controller.future;
    final LatLng position =
    LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 16.0),
    ));
  }

  Future<void> _searchAndNavigate() async {
    String query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final LatLng destination =
        LatLng(locations.first.latitude, locations.first.longitude);

        // Add destination marker
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId('destination'),
            position: destination,
            infoWindow: InfoWindow(title: query),
          ));
        });

        // Draw route
        _createRoute(destination);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: $e')),
      );
    }
  }

  Future<void> _createRoute(LatLng destination) async {
    if (_currentLocation == null) return;

    LatLng origin =
    LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$_travelMode&key=$_googleMapsApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if ((data['routes'] as List).isNotEmpty) {
        Map<String, dynamic> route = data['routes'][0];
        Map<String, dynamic> leg = route['legs'][0];

        // Get distance and duration
        String distance = leg['distance']['text'];
        String duration = leg['duration']['text'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Distance: $distance, Duration: $duration')),
        );

        String encodedPolyline = route['overview_polyline']['points'];
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> points =
        polylinePoints.decodePolyline(encodedPolyline);

        List<LatLng> polylineCoordinates = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
        });

        _fitMapToRoute(origin, destination);
        setState(() {
          _isNavigating = true;
        });
      }
    }
  }

  Future<void> _fitMapToRoute(LatLng origin, LatLng destination) async {
    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds;
    if (origin.latitude > destination.latitude &&
        origin.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: origin);
    } else if (origin.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(origin.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, origin.longitude));
    } else if (origin.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, origin.longitude),
          northeast: LatLng(origin.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: origin, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
    controller.animateCamera(cameraUpdate);
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _updateUserMarker();
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Marker',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
          ? MapType.terrain
          : _currentMapType == MapType.terrain
          ? MapType.hybrid
          : MapType.normal;
    });
  }

  void _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _selectTravelMode(String mode) {
    setState(() {
      _travelMode = mode;
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search destination',
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => _searchAndNavigate(),
        ),

        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _defaultCenter,
              zoom: 10.0,
            ),
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onTap: _onMapTapped,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _toggleMapType,
              child: const Icon(Icons.layers),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
          SlidingUpPanel(
            panel: _buildNavigationModesPanel(),
            minHeight: 100,
            maxHeight: 250,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationModesPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.drag_handle, color: Colors.grey),
        const SizedBox(height: 10),
        ListTile(
          title: const Text('Walking'),
          leading: const Icon(Icons.directions_walk),
          onTap: () => _selectTravelMode('walking'),
        ),
        ListTile(
          title: const Text('Running'),
          leading: const Icon(Icons.directions_run),
          onTap: () => _selectTravelMode('bicycling'),
        ),
        ListTile(
          title: const Text('Driving'),
          leading: const Icon(Icons.directions_car),
          onTap: () => _selectTravelMode('driving'),
        ),
      ],
    );
  }
}
