import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/vendor_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController packingFeeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _picker2 = ImagePicker();
  VendorModel? vendor;
  LatLng? latLng;
  File? image;
  File? image2;
  bool isLoading = false;

  /// Multiple opening hours slots. Same format as product availability_slots.
  List<Map<String, String>> openingHoursSlots = [
    {'from': '09:00', 'to': '22:00'}
  ];

  static TimeOfDay? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        return TimeOfDay(hour: h, minute: m);
      }
    }
    return null;
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay openingTimeOfDayAt(int index) {
    if (index < 0 || index >= openingHoursSlots.length) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    return _parseTime(openingHoursSlots[index]['from'] ?? '') ??
        const TimeOfDay(hour: 9, minute: 0);
  }

  TimeOfDay closingTimeOfDayAt(int index) {
    if (index < 0 || index >= openingHoursSlots.length) {
      return const TimeOfDay(hour: 22, minute: 0);
    }
    return _parseTime(openingHoursSlots[index]['to'] ?? '') ??
        const TimeOfDay(hour: 22, minute: 0);
  }

  void setOpeningTimeAt(int index, TimeOfDay time) {
    if (index < 0 || index >= openingHoursSlots.length) return;
    openingHoursSlots[index]['from'] = _formatTime(time);
    notifyListeners();
  }

  void setClosingTimeAt(int index, TimeOfDay time) {
    if (index < 0 || index >= openingHoursSlots.length) return;
    openingHoursSlots[index]['to'] = _formatTime(time);
    notifyListeners();
  }

  void addOpeningHoursSlot() {
    openingHoursSlots.add({'from': '09:00', 'to': '22:00'});
    notifyListeners();
  }

  void removeOpeningHoursSlot(int index) {
    if (openingHoursSlots.length == 1) {
      openingHoursSlots[0] = {'from': '09:00', 'to': '22:00'};
      notifyListeners();
      return;
    }
    if (index < 0 || index >= openingHoursSlots.length) return;
    openingHoursSlots.removeAt(index);
    notifyListeners();
  }

  Future<void> getVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(token)
          .get();

      if (docSnapshot.exists) {
        vendor = VendorModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
        latLng = LatLng(double.parse(vendor!.lat), double.parse(vendor!.long));
        nameController.text = vendor!.shopName;
        packingFeeController.text = vendor!.packingFee;
        openingHoursSlots = vendor!.openingHoursSlots.isNotEmpty
            ? vendor!.openingHoursSlots
                .map((slot) => {
                      'from': (slot['from'] ?? '09:00').toString(),
                      'to': (slot['to'] ?? '22:00').toString(),
                    })
                .toList()
            : [{'from': '09:00', 'to': '22:00'}];
        notifyListeners();
      } else {}
    } catch (_) {}
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<String> uploadImageToStorage(File imageFile,
      {bool isBanner = false}) async {
    try {
      isLoading = true;
      notifyListeners();
      final path = isBanner
          ? 'vendor_banners/${vendor?.id ?? "vendor"}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(path);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> pickImage2() async {
    final pickedFile = await _picker2.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image2 = File(pickedFile.path);
      notifyListeners();
    }
  }

  void onLatlongChanged(LatLng ponint) {
    latLng = ponint;
    notifyListeners();
  }

  Future<void> updateVendor(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('vendors').doc(vendor!.id);
      final slots = openingHoursSlots
          .map((slot) => {
                'from': (slot['from'] ?? '').trim(),
                'to': (slot['to'] ?? '').trim(),
              })
          .where((s) => (s['from'] ?? '').isNotEmpty || (s['to'] ?? '').isNotEmpty)
          .toList();

      Map<String, dynamic> dataToUpdate = {
        "shop_name": nameController.text,
        "packing_fee": num.tryParse(packingFeeController.text.trim()) ?? 0,
        "opening_hours_slots": slots.isNotEmpty
            ? slots
            : [{'from': '09:00', 'to': '22:00'}],
      };

      if (image != null) {
        String logo = await uploadImageToStorage(image!);
        dataToUpdate["shop_image"] = logo;
      }

      if (image2 != null) {
        String bannerUrl = await uploadImageToStorage(image2!, isBanner: true);
        dataToUpdate["banner"] = bannerUrl;
      }

      await docRef.update(dataToUpdate);
      await getVendor();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF084D00),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error updating vendor: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onLatLongUpdated(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendor!.id)
          .update({
        "lat": latLng!.latitude.toString(),
        "long": latLng!.longitude.toString()
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Locaton Updated SuccessFull')));
      isLoading = false;
      notifyListeners();
      getVendor();
    } catch (e) {}
  }
}
