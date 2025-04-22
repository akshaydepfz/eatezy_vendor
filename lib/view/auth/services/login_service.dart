import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/view/home/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .where('email', isEqualTo: emailController.text.trim())
          .where('password', isEqualTo: passwordController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String token = querySnapshot.docs.first.id;
        // Save the delivery boy's ID in shared preferences for later access
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString(
            'shop_name', querySnapshot.docs.first['shop_name']);
        // Credentials match, proceed with login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );
        isLoading = false;
        notifyListeners();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LandingScreen()));
      } else {
        isLoading = false;
        notifyListeners();
        // Credentials do not match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
      }
    } catch (e) {
      print(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }
}
