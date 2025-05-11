import 'package:eatezy_vendor/view/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class OSMMapPicker extends StatefulWidget {
  @override
  State<OSMMapPicker> createState() => _OSMMapPickerState();
}

class _OSMMapPickerState extends State<OSMMapPicker> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Pick Restaurant Location')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: provider.latLng,
              zoom: 13.0,
              onTap: (tapPosition, point) {
                provider.onLatlongChanged(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
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
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                provider.onLatLongUpdated(context);
                // You can pass these values to another screen or save them
              },
              child: Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
