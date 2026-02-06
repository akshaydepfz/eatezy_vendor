import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/offer_model.dart';
import 'package:eatezy_vendor/models/product_model.dart';
import 'package:eatezy_vendor/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfferService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OfferModel>? offers;
  bool isLoading = false;

  Future<void> fetchOffers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String vendorId = prefs.getString('token') ?? '';

      QuerySnapshot snapshot = await _firestore
          .collection('offers')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      final list = snapshot.docs.map((doc) {
        return OfferModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      offers = list;

      notifyListeners();
    } catch (e) {
      print('Error fetching offers: $e');
      offers = null;
      notifyListeners();
    }
  }

  Future<List<ProductModel>> fetchVendorProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String vendorId = prefs.getString('token') ?? '';

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('vendor_id', isEqualTo: vendorId)
          .get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products for offers: $e');
      return [];
    }
  }

  Future<void> addOffer(
    BuildContext context, {
    required String productId,
    required String productName,
    required String productImage,
    required String title,
    required String discountType,
    required double discountValue,
    String? startDate,
    String? endDate,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String vendorId = prefs.getString('token') ?? '';

      String createdAt = DateTime.now().toIso8601String();

      await _firestore.collection('offers').add({
        'vendorId': vendorId,
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'title': title,
        'discountType': discountType,
        'discountValue': discountValue,
        'startDate': startDate,
        'endDate': endDate,
        'isActive': true,
        'createdAt': createdAt,
      });

      await fetchOffers();
      if (context.mounted) {
        Navigator.pop(context);
        AppAlerts.successAlert(context, 'Offer added successfully');
      }
    } catch (e) {
      if (context.mounted) {
        AppAlerts.wrongAlert(context, 'Failed to add offer: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOfferStatus(BuildContext context, String offerId, bool isActive) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({
        'isActive': isActive,
      });
      await fetchOffers();
      if (context.mounted) {
        AppAlerts.successAlert(context, isActive ? 'Offer enabled' : 'Offer disabled');
      }
    } catch (e) {
      if (context.mounted) {
        AppAlerts.wrongAlert(context, 'Failed to update offer');
      }
    }
  }

  Future<void> deleteOffer(BuildContext context, String offerId) async {
    isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('offers').doc(offerId).delete();
      await fetchOffers();
      if (context.mounted) {
        Navigator.pop(context);
        AppAlerts.successAlert(context, 'Offer deleted');
      }
    } catch (e) {
      if (context.mounted) {
        AppAlerts.wrongAlert(context, 'Failed to delete offer');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
