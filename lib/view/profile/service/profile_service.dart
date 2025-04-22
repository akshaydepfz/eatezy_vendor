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
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _picker2 = ImagePicker();
  VendorModel? vendor;
  LatLng? latLng;
  File? image;
  File? image2;
  bool isLoading = false;

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

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      isLoading = true;
      notifyListeners();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

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
      Map<String, dynamic> dataToUpdate = {
        "shop_name": nameController.text,
      };

      if (image != null) {
        String logo = await uploadImageToStorage(image!);
        dataToUpdate["shop_image"] = logo;
      }

      if (image2 != null) {
        String banner = await uploadImageToStorage(image2!);
        dataToUpdate["banner"] = banner;
      }

      await docRef.update(dataToUpdate);
      await getVendor();
    } catch (e) {
      print("Error updating vendor: $e");
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
