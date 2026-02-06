import 'dart:convert';

import 'package:eatezy_vendor/view/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class OSMMapPicker extends StatefulWidget {
  @override
  State<OSMMapPicker> createState() => _OSMMapPickerState();
}

class _OSMMapPickerState extends State<OSMMapPicker> {
  static const _defaultCenter = LatLng(20.5937, 78.9629); // India center

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String? _searchError;

  static const _nominatimBase =
      'https://nominatim.openstreetmap.org/search';

  Future<void> _searchLocation(ProfileService provider) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final uri = Uri.parse(_nominatimBase).replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '1',
        },
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'EatezyVendor/1.0 (contact@eatezy.app)'},
      );

      if (response.statusCode != 200) {
        setState(() {
          _searchError = 'Search failed. Try again.';
          _isSearching = false;
        });
        return;
      }

      final list = jsonDecode(response.body) as List;
      if (list.isEmpty) {
        setState(() {
          _searchError = 'No results found';
          _isSearching = false;
        });
        return;
      }

      final first = list.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat']?.toString() ?? '') ?? 0.0;
      final lon = double.tryParse(first['lon']?.toString() ?? '') ?? 0.0;
      final point = LatLng(lat, lon);

      provider.onLatlongChanged(point);
      _mapController.move(point, 15.0);

      setState(() {
        _isSearching = false;
        _searchError = null;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Search failed. Check connection.';
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    final center = provider.latLng ?? _defaultCenter;
    return Scaffold(
      appBar: AppBar(title: Text('Pick Restaurant Location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                provider.onLatlongChanged(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eatezy_vendor.app',
              ),
              MarkerLayer(
                markers: provider.latLng != null
                    ? [
                        Marker(
                          point: provider.latLng!,
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ]
                    : [],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            _searchError = null;
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _searchError,
                ),
                onSubmitted: (_) => _searchLocation(provider),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                provider.onLatLongUpdated(context);
              },
              child: Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
