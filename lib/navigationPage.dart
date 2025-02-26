import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vest1/components/repo.dart';
import 'components/place_model.dart';

Color color = const Color(0xfffe8903);

/// Model representing an individual route step.
class RouteStep {
  final String instruction;
  final double distance; // in meters
  final double duration; // in seconds
  final LatLng startLocation;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
  });

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'distance': distance,
    'duration': duration,
    'startLocation': {'lat': startLocation.latitude, 'lng': startLocation.longitude},
  };

  factory RouteStep.fromJson(Map<String, dynamic> json) => RouteStep(
    instruction: json['instruction'],
    distance: json['distance'],
    duration: json['duration'],
    startLocation: LatLng(json['startLocation']['lat'], json['startLocation']['lng']),
  );
}

/// Model representing the OSRM route.
class OSRMRoute {
  final List<LatLng> polyline;
  final double distance; // in meters
  final double duration; // in seconds
  final List<RouteStep> steps;

  OSRMRoute({
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'polyline': polyline.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    'distance': distance,
    'duration': duration,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory OSRMRoute.fromJson(Map<String, dynamic> json) => OSRMRoute(
    polyline: (json['polyline'] as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList(),
    distance: json['distance'],
    duration: json['duration'],
    steps: (json['steps'] as List).map((s) => RouteStep.fromJson(s)).toList(),
  );
}

/// Helper function to generate a human-readable instruction from a step.
String generateInstruction(Map<String, dynamic> step) {
  final maneuver = step['maneuver'] as Map<String, dynamic>;
  final String type = maneuver['type'];
  final String modifier = maneuver['modifier'] ?? "";
  final String roadName = (step['name'] as String?)?.trim() ?? "";
  switch (type) {
    case "depart":
      return "Start walking from your location";
    case "arrive":
      return "Arrive at your destination";
    case "turn":
      return "Turn $modifier onto ${roadName.isNotEmpty ? roadName : 'the path'}";
    case "roundabout":
      return "Enter roundabout and take the exit";
    case "continue":
      return "Continue walking straight";
    default:
      return "${type.toUpperCase()} ${modifier.isNotEmpty ? modifier : ''} ${roadName.isNotEmpty ? 'on $roadName' : ''}".trim();
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController placeController = TextEditingController();

  late GoogleMapController _controller;
  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(37.4220, -122.0841); // Google Building 43
  String _currentAddress = "Fetching location...";

  // Collections for markers and polylines.
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // State variables for the trip.
  bool _tripStarted = false;
  bool _isLoadingRoute = false;
  OSRMRoute? _currentRoute;
  List<RouteStep> _remainingSteps = [];
  final double _stepThreshold = 50; // Distance to pop a step (meters)
  final double _vibrationThreshold = 20; // Distance to trigger vibration (meters)

  // Average walking speed: 1.4 m/s (5 km/h)
  static const double _walkingSpeed = 1.4;

  @override
  void initState() {
    super.initState();
    _loadTripState(); // Load saved state on init
    getLocation();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        timeLimit: Duration(seconds: 2),
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: const MarkerId("current"),
          position: _currentLatLng,
        ));
      });
      if (_tripStarted) {
        _updateRemainingSteps();
        _updateCamera();
        _saveTripState(); // Save state on location update
      }
    });
  }

  // Load trip state from SharedPreferences.
  Future<void> _loadTripState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tripStarted = prefs.getBool('tripStarted') ?? false;
      placeController.text = prefs.getString('destination') ?? '';
      final routeJson = prefs.getString('currentRoute');
      final stepsJson = prefs.getString('remainingSteps');
      if (routeJson != null) {
        _currentRoute = OSRMRoute.fromJson(json.decode(routeJson));
        _polylines.add(Polyline(
          polylineId: const PolylineId('osrm_route'),
          points: _currentRoute!.polyline,
          color: Colors.blue,
          width: 5,
        ));
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: _currentRoute!.polyline.last,
        ));
      }
      if (stepsJson != null) {
        _remainingSteps = (json.decode(stepsJson) as List)
            .map((s) => RouteStep.fromJson(s))
            .toList();
      }
    });
  }

  // Save trip state to SharedPreferences.
  Future<void> _saveTripState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tripStarted', _tripStarted);
    await prefs.setString('destination', placeController.text);
    if (_currentRoute != null) {
      await prefs.setString('currentRoute', json.encode(_currentRoute!.toJson()));
    }
    if (_remainingSteps.isNotEmpty) {
      await prefs.setString(
          'remainingSteps', json.encode(_remainingSteps.map((s) => s.toJson()).toList()));
    }
  }

  // Clear saved trip state.
  Future<void> _clearTripState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get current location and reverse geocode its address.
  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Permission Denied";
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Permission Denied Forever";
      });
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      Placemark place = placemarks[0];
      _currentAddress =
      "${place.street}, ${place.locality}, ${place.administrativeArea}";
    } catch (e) {
      _currentAddress = "Unable to fetch address";
    }

    _markers.add(Marker(
      markerId: const MarkerId("current"),
      position: _currentLatLng,
    ));

    setState(() {});
  }

  // Fetch OSRM walking route and enforce walking-specific logic.
  Future<OSRMRoute> fetchOSRMRoute(LatLng origin, LatLng destination) async {
    const String baseUrl = 'http://router.project-osrm.org/route/v1/foot/';
    final String coordinates =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final String url =
        '$baseUrl$coordinates?overview=full&geometries=geojson&steps=true';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("OSRM Raw Response: $data");
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final geometry = route['geometry'];
        final List<dynamic> coords = geometry['coordinates'];
        List<LatLng> polyline = coords.map<LatLng>((point) {
          return LatLng(point[1], point[0]);
        }).toList();
        double distance = route['distance'];
        double serverDuration = route['duration'];
        double walkingDuration = distance / _walkingSpeed;

        print("Server Distance: $distance m, Server Duration: $serverDuration s");
        print("Walking Duration (calculated): $walkingDuration s (~${(walkingDuration / 3600).toStringAsFixed(1)} hours)");

        if (serverDuration < walkingDuration * 0.5) {
          print("Server duration too short, forcing walking duration: $walkingDuration s");
          serverDuration = walkingDuration;
        }

        List<RouteStep> routeSteps = [];
        final legs = route['legs'] as List;
        if (legs.isNotEmpty) {
          final stepsData = legs[0]['steps'] as List;
          for (var step in stepsData) {
            final String instruction = generateInstruction(step);
            final double stepDistance = (step['distance'] as num).toDouble();
            final double stepWalkingDuration = stepDistance / _walkingSpeed;
            final List<dynamic> loc = step['maneuver']['location'];
            final LatLng startLocation = LatLng(loc[1], loc[0]);
            routeSteps.add(RouteStep(
              instruction: instruction,
              distance: stepDistance,
              duration: stepWalkingDuration,
              startLocation: startLocation,
            ));
          }
        }

        double totalDuration = routeSteps.fold(0, (sum, step) => sum + step.duration);

        return OSRMRoute(
          polyline: polyline,
          distance: distance,
          duration: totalDuration,
          steps: routeSteps,
        );
      } else {
        throw Exception('No route found');
      }
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }

  // Trigger route display when the user starts the trip.
  Future<void> _startTrip() async {
    if (placeController.text.isEmpty) return;
    setState(() => _isLoadingRoute = true);
    try {
      List<Location> locations = await locationFromAddress(placeController.text);
      if (locations.isNotEmpty) {
        LatLng destinationLatLng =
        LatLng(locations.first.latitude, locations.first.longitude);
        OSRMRoute route = await fetchOSRMRoute(_currentLatLng, destinationLatLng);
        setState(() {
          _currentRoute = route;
          _tripStarted = true;
          _remainingSteps = List<RouteStep>.from(route.steps);
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('osrm_route'),
            points: route.polyline,
            color: Colors.blue,
            width: 5,
          ));
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: destinationLatLng,
          ));
        });
        _updateCamera();
        _saveTripState(); // Save initial state
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching route: $e")),
      );
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  // Update remaining steps and trigger vibration based on proximity.
  void _updateRemainingSteps() {
    if (_remainingSteps.isEmpty || _currentPosition == null) return;
    final userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final currentStep = _remainingSteps.first;
    final distanceToStep = Geolocator.distanceBetween(
      userLatLng.latitude,
      userLatLng.longitude,
      currentStep.startLocation.latitude,
      currentStep.startLocation.longitude,
    );
    print("Distance to next step: $distanceToStep meters");

    if (distanceToStep < _stepThreshold) {
      setState(() {
        _remainingSteps.removeAt(0);
        print("Step completed: ${currentStep.instruction}");
      });
    }

    if (_remainingSteps.isNotEmpty) {
      final nextStep = _remainingSteps.first;
      final distanceToNext = Geolocator.distanceBetween(
        userLatLng.latitude,
        userLatLng.longitude,
        nextStep.startLocation.latitude,
        nextStep.startLocation.longitude,
      );
      if (distanceToNext < _vibrationThreshold) {
        _triggerVibration(nextStep.instruction);
      }
    }
  }

  // Simulate vibration on ESP (left or right shoulder) based on instruction.
  void _triggerVibration(String instruction) async {
      if (instruction.toLowerCase().contains("left")) {
        //Vibration.vibrate(pattern: [0, 200, 100, 200]);
        print("Vibrate LEFT shoulder");
      } else if (instruction.toLowerCase().contains("right")) {
       // Vibration.vibrate(pattern: [0, 500, 100, 500]);
        print("Vibrate RIGHT shoulder");
      }
  }

  // Update camera to follow the user.
  void _updateCamera() {
    if (_currentPosition == null) return;
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLatLng,
          zoom: 18,
          tilt: 45,
          bearing: _currentPosition!.heading,
        ),
      ),
    );
  }

  // AutoComplete widget for destination input.
  Widget autoComplete() {
    if (_tripStarted) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                blurRadius: 8.0,
                spreadRadius: 1,
                offset: const Offset(0, 4))
          ],
          borderRadius: BorderRadius.circular(12)),
      child: TypeAheadField<Description?>(
          onSelected: (suggestion) async {
            setState(() {
              placeController.text = suggestion?.structured_formatting?.main_text ?? "";
            });
          },
          itemBuilder: (context, Description? itemData) {
            if (itemData == null || itemData.structured_formatting == null) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: const Text("No data available"),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${itemData.structured_formatting?.main_text}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text("${itemData.structured_formatting?.secondary_text}"),
                      const Divider(),
                    ],
                  ),
                ],
              ),
            );
          },
          emptyBuilder: (context) => Container(),
          suggestionsCallback: (String pattern) async {
            try {
              var predictionModel = await Repo.placeAutoComplete(placeInput: pattern);
              if (predictionModel != null) {
                return predictionModel.predictions!.where((element) {
                  return element.description!.toLowerCase().contains(pattern.toLowerCase());
                }).toList();
              } else {
                return [];
              }
            } catch (e) {
              print("Error fetching predictions: $e");
              return [];
            }
          }),
    );
  }

  // Widget displaying current location and destination information.
  Widget locationsWidget() {
    if (_tripStarted) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10.0,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    const Text(
                      "Current Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currentAddress,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Divider(
                height: 8,
                color: color.withOpacity(0.6),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    const Text(
                      "Destination",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 300,
                      child: Text(
                        placeController.text.isEmpty ? "Select Destination" : placeController.text,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // "Start Trip" button.
  Widget startTripButton() {
    if (_tripStarted) return const SizedBox.shrink();
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color, minimumSize: const Size(double.infinity, 40)),
        onPressed: _startTrip,
        child: Text(
          "Start Walking",
          style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
        ));
  }

  // "End Trip" button with state clearing.
  Widget endTripButton() {
    if (!_tripStarted) return const SizedBox.shrink();
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 40),
        ),
        onPressed: () {
          setState(() {
            _tripStarted = false;
            _currentRoute = null;
            _remainingSteps.clear();
            _polylines.clear();
            _markers.removeWhere((m) => m.markerId.value == 'destination');
            placeController.clear();
          });
          _clearTripState(); // Clear saved state
        },
        child: const Text("End Trip", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Format duration as "X hours Y minutes".
  String _formatDuration(double durationInSeconds) {
    int hours = (durationInSeconds / 3600).floor();
    int minutes = ((durationInSeconds % 3600) / 60).round();
    if (hours > 0) {
      return "$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}";
    } else {
      return "$minutes minute${minutes != 1 ? 's' : ''}";
    }
  }

  // Overlay widget showing the current instruction with hours and minutes.
  Widget routeDirectionsOverlay() {
    if (_currentRoute == null) return const SizedBox.shrink();
    if (_remainingSteps.isEmpty) {
      return Positioned(
        top: 40,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "You have arrived at your destination.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentStep = _remainingSteps.first;
    final distanceKm = (_currentRoute!.distance / 1000).toStringAsFixed(1);
    final durationFormatted = _formatDuration(_currentRoute!.duration);

    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Walking: $distanceKm km, ~$durationFormatted",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions_walk, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Next: ${currentStep.instruction}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                zoom: 16,
                target: _currentLatLng,
              ),
              onMapCreated: (controller) async {
                setState(() {
                  _controller = controller;
                });
                String val = "json/google_map_dark_light.json";
                var c = await rootBundle.loadString(val);
                _controller.setMapStyle(c);
              },
              markers: _markers,
              polylines: _polylines,
            ),
            if (!_tripStarted)
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      autoComplete(),
                      const SizedBox(height: 12),
                      locationsWidget(),
                    ],
                  ),
                ),
              ),
            if (!_tripStarted)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: startTripButton(),
              ),
            if (_tripStarted) routeDirectionsOverlay(),
            if (_tripStarted) endTripButton(),
            if (_isLoadingRoute)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}