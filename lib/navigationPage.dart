import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

/// A simple model representing a place.
class PlaceModel {
  final String name;
  final double latitude;
  final double longitude;

  PlaceModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// A simple repository for fetching place suggestions.
/// Replace this dummy implementation with your actual data source.
class Repo {
  static Future<List<PlaceModel>> getSuggestions(String query) async {
    // Dummy data for demonstration.
    List<PlaceModel> places = [
      PlaceModel(name: 'San Francisco', latitude: 37.7749, longitude: -122.4194),
      PlaceModel(name: 'Los Angeles', latitude: 34.0522, longitude: -118.2437),
      PlaceModel(name: 'New York', latitude: 40.7128, longitude: -74.0060),
    ];
    return places
        .where((place) =>
        place.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

Color color = const Color(0xfffe8903);

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapBoxNavigationViewController? _controller;
  String? _instruction;
  bool _isMultipleStop = false;
  double? _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _arrived = false;
  late MapBoxOptions _navigationOption;

  Future<void> initialize() async {
    if (!mounted) return;
    _navigationOption = MapBoxNavigation.instance.getDefaultOptions();
    _navigationOption.initialLatitude = 37.7749;
    _navigationOption.initialLongitude = -122.4194;
    _navigationOption.mode = MapBoxNavigationMode.driving;
    MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Called when a route event happens.
  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        }
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    setState(() {});
  }

  /// When a search suggestion is selected, build a route to the selected destination.
  Future<void> _onSearchSelected(PlaceModel suggestion) async {
    // Create waypoints using the initial location and the selected destination.
    WayPoint origin = WayPoint(
      name: "Start",
      latitude: _navigationOption.initialLatitude,
      longitude: _navigationOption.initialLongitude,
    );
    WayPoint destination = WayPoint(
      name: suggestion.name,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
    );
    await _controller?.buildRoute(wayPoints: [origin, destination]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Mapbox Navigation View as the background.
          MapBoxNavigationView(
            options: _navigationOption,
            onRouteEvent: _onRouteEvent,
            onCreated: (MapBoxNavigationViewController controller) async {
              _controller = controller;
              controller.initialize();
            },
          ),
          // Positioned search bar on top of the map.
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: TypeAheadField<PlaceModel>(
                builder: (context, textEditingController, focusNode) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  return await Repo.getSuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.name),
                  );
                },
                onSelected: (suggestion) async {
                  await _onSearchSelected(suggestion);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
