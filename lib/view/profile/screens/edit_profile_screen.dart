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
    final hasBanner = provider.image2 != null ||
        (provider.vendor?.banner != null && provider.vendor!.banner.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner card
              _SectionCard(
                title: 'Restaurant Banner',
                subtitle: 'Shown at the top of your profile',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: hasBanner
                            ? Image(
                                image: provider.image2 != null
                                    ? FileImage(provider.image2!)
                                    : NetworkImage(provider.vendor!.banner)
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      AppSpacing.h10,
                                      Text(
                                        'Tap to add banner',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Material(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(24),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => provider.pickImage2(),
                          borderRadius: BorderRadius.circular(24),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h20,

              // Logo & name card
              _SectionCard(
                title: 'Restaurant Logo & Name',
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: provider.image == null
                                  ? NetworkImage(provider.vendor!.shopImage)
                                  : FileImage(File(provider.image!.path))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Material(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(20),
                            elevation: 2,
                            child: InkWell(
                              onTap: () => provider.pickImage(),
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h15,
                    PrimaryTextField(
                      title: 'Restaurant Name',
                      controller: provider.nameController,
                    ),
                  ],
                ),
              ),
              AppSpacing.h20,

              // Packing fee card
              _SectionCard(
                title: 'Packing Fee',
                subtitle: 'Amount charged for packing (in your currency)',
                child: PrimaryTextField(
                  title: 'Packing Fee (e.g. 25)',
                  controller: provider.packingFeeController,
                  keyboardType: TextInputType.number,
                ),
              ),
              AppSpacing.h20,

              // Location card
              _SectionCard(
                title: 'Restaurant Location',
                subtitle: 'Your delivery / pickup address on map',
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: provider.latLng != null
                            ? FlutterMap(
                                options: MapOptions(
                                  center: provider.latLng,
                                  zoom: 14.0,
                                  interactiveFlags: InteractiveFlag.none,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.eatezy_vendor.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: provider.latLng!,
                                        width: 44,
                                        height: 44,
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: AppColor.primary,
                                          size: 44,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_off_rounded,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    AppSpacing.h10,
                                    Text(
                                      'No location selected',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    AppSpacing.h10,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OSMMapPicker(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_location_alt_rounded),
                        label: const Text('Change Location'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.primary,
                          side: const BorderSide(color: AppColor.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h20,

              PrimaryButton(
                title: 'Save Changes',
                isLoading: provider.isLoading,
                onTap: () => provider.updateVendor(context),
              ),
              AppSpacing.h20,
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1F1F),
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.h5,
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          AppSpacing.h15,
          child,
        ],
      ),
    );
  }
}
