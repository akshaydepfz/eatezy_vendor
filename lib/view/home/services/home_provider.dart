import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/view/home/screens/home_screen.dart';
import 'package:eatezy_vendor/view/orders/screens/orders_screen.dart';
import 'package:eatezy_vendor/view/product/screens/product_screen.dart';
import 'package:eatezy_vendor/view/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  int selectedIndex = 0;
  final List<Widget> screens = [
    HomeScreen(),
    OrdersScreen(),
    ProductScreen(),
    ProfileScreen(),
  ];

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
}
