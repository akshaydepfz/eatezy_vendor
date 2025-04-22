import 'dart:io';

import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/product/screens/add_product_screen.dart';
import 'package:eatezy_vendor/view/profile/screens/location_picker_screen.dart';
import 'package:eatezy_vendor/view/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Edit')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Restaurant Banner',
                style: TextStyle(fontSize: 16),
              ),
              AppSpacing.h10,
              // Background Image with Edit Icon
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: provider.image2 == null
                          ? Image.network(
                              provider.vendor!.banner,
                              fit: BoxFit.cover,
                            )
                          : Image.file(File(provider.image2!.path)),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        provider.pickImage2();
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h10,
              Text(
                'Your Restaurant Logo',
                style: TextStyle(fontSize: 16),
              ),
              AppSpacing.h10,
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 4),
                      image: DecorationImage(
                        image: provider.image == null
                            ? NetworkImage(provider.vendor!.shopImage)
                            : FileImage(
                                File(provider.image!.path)), // 512x512 px
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Edit icon on avatar
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => provider.pickImage(),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black87,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h10,
              PrimaryTextField(
                  title: 'Restaurant Name',
                  controller: provider.nameController),
              AppSpacing.h20,
              Text(
                'Your Restaurant Location',
                style: TextStyle(fontSize: 16),
              ),
              AppSpacing.h10,
              Container(
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: provider.latLng != null
                      ? FlutterMap(
                          options: MapOptions(
                            center: provider.latLng,
                            zoom: 13.0,
                            interactiveFlags:
                                InteractiveFlag.none, // non-interactive preview
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
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(child: Text("No location selected")),
                ),
              ),
              AppSpacing.h5,
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OSMMapPicker()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColor.primary),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Edit Location',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
              AppSpacing.h20,
              PrimaryButton(
                  title: 'Save',
                  isLoading: provider.isLoading,
                  onTap: () {
                    provider.updateVendor(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
