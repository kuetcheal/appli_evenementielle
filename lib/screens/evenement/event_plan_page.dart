import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/event_surroundings_service.dart';

class EventPlanPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventPlanPage({
    super.key,
    required this.event,
  });

  @override
  State<EventPlanPage> createState() => _EventPlanPageState();
}

class _EventPlanPageState extends State<EventPlanPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _eventPosition;

  String _selectedCategory = "all";
  bool _isLoading = true;
  String? _errorMessage;

  List<SurroundingPlace> _places = [];
  SurroundingPlace? _selectedPlace;

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  final List<Map<String, dynamic>> _categories = const [
    {
      "key": "all",
      "label": "Tous",
      "icon": Icons.apps_rounded,
    },
    {
      "key": "parking",
      "label": "Parkings",
      "icon": Icons.local_parking_rounded,
    },
    {
      "key": "food",
      "label": "Restaurants",
      "icon": Icons.restaurant_rounded,
    },
    {
      "key": "transport",
      "label": "Transports",
      "icon": Icons.directions_bus_rounded,
    },
    {
      "key": "hotel",
      "label": "Hôtels",
      "icon": Icons.hotel_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    final s = value.toString().trim();

    if (s.isEmpty || s.toLowerCase() == "null") return null;

    return double.tryParse(s);
  }

  String _eventTitle() {
    return (widget.event["title"] ?? widget.event["titre"] ?? "Évènement")
        .toString();
  }

  String _eventAddress() {
    final location = (widget.event["location"] ?? widget.event["lieu"] ?? "")
        .toString()
        .trim();

    final city =
    (widget.event["city"] ?? widget.event["ville"] ?? "").toString().trim();

    if (location.isNotEmpty && city.isNotEmpty) {
      return "$location, $city";
    }

    if (location.isNotEmpty) return location;
    if (city.isNotEmpty) return city;

    return "Adresse non renseignée";
  }

  Future<void> _initMap() async {
    final lat = _asDouble(widget.event["latitude"] ?? widget.event["lat"]);
    final lng = _asDouble(widget.event["longitude"] ?? widget.event["lng"]);

    if (lat == null || lng == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
        "Coordonnées manquantes : impossible d’afficher le plan.";
      });
      return;
    }

    _eventPosition = LatLng(lat, lng);

    _rebuildMapElements();

    setState(() {});

    await _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    if (_eventPosition == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedPlace = null;
    });

    try {
      final places = await EventSurroundingsService.fetchPlaces(
        lat: _eventPosition!.latitude,
        lng: _eventPosition!.longitude,
        category: _selectedCategory,
        radius: 900,
      );

      setState(() {
        _places = places;
        _isLoading = false;
        _errorMessage = null;
        _rebuildMapElements();
      });

      await _fitCameraToAllMarkers();
    } catch (e) {
      setState(() {
        _places = [];
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _rebuildMapElements();
      });

      await _moveCameraToEvent();
    }
  }

  void _rebuildMapElements() {
    if (_eventPosition == null) return;

    final markers = <Marker>{};

    // Marker principal de l’évènement
    markers.add(
      Marker(
        markerId: const MarkerId("event_marker"),
        position: _eventPosition!,
        infoWindow: InfoWindow(
          title: _eventTitle(),
          snippet: _eventAddress(),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );

    // Markers des parkings / restaurants / hôtels / transports
    for (final place in _places) {
      markers.add(
        Marker(
          markerId: MarkerId("place_${place.id}"),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHueByCategory(place.category),
          ),
          onTap: () {
            setState(() {
              _selectedPlace = place;
            });
          },
        ),
      );
    }

    final circles = <Circle>{
      Circle(
        circleId: const CircleId("event_area"),
        center: _eventPosition!,
        radius: 900,
        fillColor: const Color(0xFF6C63FF).withOpacity(0.08),
        strokeColor: const Color(0xFF6C63FF).withOpacity(0.35),
        strokeWidth: 2,
      ),
    };

    _markers = markers;
    _circles = circles;
  }

  double _markerHueByCategory(String category) {
    switch (category) {
      case "parking":
        return BitmapDescriptor.hueAzure;
      case "food":
        return BitmapDescriptor.hueOrange;
      case "transport":
        return BitmapDescriptor.hueGreen;
      case "hotel":
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  IconData _iconByCategory(String category) {
    switch (category) {
      case "parking":
        return Icons.local_parking_rounded;
      case "food":
        return Icons.restaurant_rounded;
      case "transport":
        return Icons.directions_bus_rounded;
      case "hotel":
        return Icons.hotel_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Future<void> _moveCameraToEvent() async {
    if (!_mapController.isCompleted || _eventPosition == null) return;

    final controller = await _mapController.future;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(_eventPosition!, 15.5),
    );
  }

  Future<void> _fitCameraToAllMarkers() async {
    if (!_mapController.isCompleted || _eventPosition == null) return;

    final controller = await _mapController.future;

    final positions = <LatLng>[
      _eventPosition!,
      ..._places.map((p) => LatLng(p.latitude, p.longitude)),
    ];

    if (positions.length == 1) {
      await _moveCameraToEvent();
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 90),
      );
    } catch (_) {
      await _moveCameraToEvent();
    }
  }

  Future<void> _focusPlace(SurroundingPlace place) async {
    setState(() {
      _selectedPlace = place;
    });

    if (!_mapController.isCompleted) return;

    final controller = await _mapController.future;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(place.latitude, place.longitude),
        17,
      ),
    );
  }

  Future<void> _openSelectedPlaceInGoogleMaps(SurroundingPlace place) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEventInGoogleMaps() async {
    if (_eventPosition == null) return;

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${_eventPosition!.latitude},${_eventPosition!.longitude}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _categoryChip(Map<String, dynamic> item) {
    final key = item["key"] as String;
    final selected = _selectedCategory == key;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        avatar: Icon(
          item["icon"] as IconData,
          size: 16,
          color: selected ? Colors.white : const Color(0xFF6C63FF),
        ),
        label: Text(item["label"].toString()),
        selectedColor: const Color(0xFF6C63FF),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
          ),
        ),
        onSelected: (_) async {
          if (_selectedCategory == key) return;

          setState(() {
            _selectedCategory = key;
          });

          await _loadPlaces();
        },
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 42,
      left: 14,
      right: 14,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black.withOpacity(0.45),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Autour de l’évènement",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black.withOpacity(0.45),
            child: IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
              onPressed: _openEventInGoogleMaps,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 320,
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _eventTitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _eventAddress(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map(_categoryChip).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Recherche des points utiles...",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              )
            else if (_places.isEmpty)
                const Text(
                  "Aucun point utile trouvé autour de cet évènement.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _places.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 12,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      final selected = _selectedPlace?.id == place.id;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _focusPlace(place),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF6C63FF).withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFF6C63FF).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconByCategory(place.category),
                                  color: const Color(0xFF6C63FF),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      place.address.isEmpty
                                          ? "Adresse non disponible"
                                          : place.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Color(0xFF6C63FF),
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _openSelectedPlaceInGoogleMaps(place),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _eventPosition ?? const LatLng(43.6108, 3.8767);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 15,
            ),
            markers: _markers,
            circles: _circles,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) async {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }

              await _fitCameraToAllMarkers();
            },
          ),
          _topBar(),
          _bottomPanel(),
        ],
      ),
    );
  }
}