import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/vendor_model.dart';
import 'package:eatezy_vendor/view/home/screens/home_screen.dart';
import 'package:eatezy_vendor/view/offer/screens/offers_screen.dart';
import 'package:eatezy_vendor/view/orders/screens/orders_screen.dart';
import 'package:eatezy_vendor/view/product/screens/product_screen.dart';
import 'package:eatezy_vendor/view/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  int selectedIndex = 0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _vendorSubscription;

  final List<Widget> screens = [
    HomeScreen(),
    OrdersScreen(),
    ProductScreen(),
    OffersScreen(),
    ProfileScreen(),
  ];

  VendorModel? vendor;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }




  Future<void> updateAdminFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('token') ?? "";
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(id)
            .set({'fcm_token': token}, SetOptions(merge: true));

        print('FCM token updated successfully: $token');
      } else {
        print('Failed to get FCM token.');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  void onStatusChanged(bool v) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    vendor!.isActive = v;
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(token)
        .update({
      "is_active": v,
      "isActive": v,
    });
    notifyListeners();
  }

  Future<void> fetchVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(token)
          .get();

      vendor = VendorModel.fromFirestore(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  /// Listen to vendor document for real-time updates (e.g. is_suspend).
  void startVendorStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    if (token.isEmpty) return;
    _vendorSubscription?.cancel();
    _vendorSubscription = FirebaseFirestore.instance
        .collection('vendors')
        .doc(token)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        vendor = VendorModel.fromFirestore(snapshot.data()!, snapshot.id);
      } else {
        vendor = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _vendorSubscription?.cancel();
    super.dispose();
  }
}
