import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/models/customer_model.dart';
import 'package:eatezy_vendor/models/delivery_boy_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderService extends ChangeNotifier {
  List<CartModel> pendingOrders = [];
  List<CartModel> inTransist = [];
  List<CartModel> delivered = [];
  List<CartModel> readyForPickup = [];
  List<CartModel> cancelledOrders = [];
  List<CartModel> totalOrders = [];
  List<CartModel> ratedOrders = [];
  List<CustomerModel> customers = [];
  List<DeliveryBoyModel> deliveryBoys = [];
  bool isLoadingRatedOrders = false;

  Future<void> cancellOrder(
      BuildContext context, String id, String userId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(id)
        .update({"isCancelled": true});
    final customer = findCustomerById(userId);
    if (customer != null && customer.token.isNotEmpty) {
      await sendFCMMessage(customer.token, 'Your order was cancelled');
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Cancelled by you!")),
    );
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? "";
      pendingOrders.clear();
      inTransist.clear();
      delivered.clear();
      readyForPickup.clear();
      cancelledOrders.clear();

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('vendor_id', isEqualTo: token)
          .get();

      totalOrders = snapshot.docs.map((doc) {
        return CartModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      notifyListeners();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final bool isCancelled = data['isCancelled'] == true;
        final bool isDeliveredFlag = data['isDelivered'] == true;
        final String status = data['order_status'] ?? '';

        // Cancelled takes highest priority
        if (isCancelled) {
          cancelledOrders.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
          continue;
        }

        // Anything marked delivered/completed should always be in completed tab
        if (status == 'Completed' || isDeliveredFlag) {
          delivered.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
          continue;
        }

        // Waiting → New tab
        if (status == 'Waiting') {
          pendingOrders.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
          continue;
        }

        // Ready For Pickup tab
        if (status == 'Ready For Pickup') {
          readyForPickup.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
          continue;
        }

        // All other non-cancelled, non-completed, non-waiting statuses → Confirmed/In transit tab
        inTransist.add(CartModel.fromFirestore(data, doc.id));
        notifyListeners();
      }
      print(pendingOrders.length);
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  /// Fetches carts where is_rated == true and vendor_id == current vendor.
  Future<void> fetchRatedOrders() async {
    try {
      isLoadingRatedOrders = true;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      ratedOrders.clear();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('vendor_id', isEqualTo: token)
          .where('is_rated', isEqualTo: true)
          .get();
      ratedOrders = snapshot.docs.map((doc) {
        return CartModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      // Sort by created date descending (latest first)
      ratedOrders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      isLoadingRatedOrders = false;
      notifyListeners();
    } catch (e) {
      isLoadingRatedOrders = false;
      notifyListeners();
      print('Error fetching rated orders: $e');
    }
  }

  /// Parses cart date (created_date) for filtering. Returns null if unparseable.
  static DateTime? _parseCartDate(String createdDate) {
    if (createdDate.isEmpty) return null;
    return DateTime.tryParse(createdDate);
  }

  /// Returns delivered orders whose created date falls within [start] and [end] (inclusive of day).
  List<CartModel> getDeliveredInDateRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay =
        DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    return delivered.where((cart) {
      final d = _parseCartDate(cart.createdDate);
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(startDay) && day.isBefore(endDay);
    }).toList();
  }

  /// Earning for a single order (vendor share after platform charge).
  double getOrderEarning(CartModel cart) {
    final storedTotal = double.tryParse(cart.totalPrice);
    double orderTotal;
    if (storedTotal != null && storedTotal > 0) {
      // totalPrice is already: subtotal×(1−discount/100) + delivery + packing + platform
      orderTotal = storedTotal - cart.platformCharge;
    } else {
      // Fallback: subtotal → apply coupon % → + delivery → + packing → - platform
      orderTotal = 0.0;
      for (var product in cart.products) {
        orderTotal += product.price * product.quantity;
      }
      if (cart.discount.isNotEmpty && cart.discount != 'null') {
        try {
          final discountPercent = double.parse(cart.discount);
          orderTotal -= orderTotal * (discountPercent / 100);
        } catch (_) {}
      }
      orderTotal += cart.deliveryCharge;
      orderTotal += cart.packingFee;
      orderTotal -= cart.platformCharge;
    }
    return orderTotal >= 0 ? orderTotal : 0;
  }

  /// Total earnings from delivered orders in the given date range.
  double calculateEarningsInRange(DateTime start, DateTime end) {
    final list = getDeliveredInDateRange(start, end);
    double totalEarnings = 0.0;
    for (var cart in list) {
      totalEarnings += getOrderEarning(cart);
    }
    return totalEarnings;
  }

  double calculateTotalEarnings() {
    double totalEarnings = 0.0;

    for (var cart in delivered) {
      // Prefer order's stored total (includes packing and any backend-applied charges)
      final storedTotal = double.tryParse(cart.totalPrice);
      double orderTotal;
      if (storedTotal != null && storedTotal > 0) {
        orderTotal = storedTotal - cart.platformCharge;
      } else {
        orderTotal = 0.0;
        for (var product in cart.products) {
          orderTotal += product.price * product.quantity;
        }
        if (cart.discount.isNotEmpty && cart.discount != 'null') {
          try {
            final discountPercent = double.parse(cart.discount);
            orderTotal -= orderTotal * (discountPercent / 100);
          } catch (_) {}
        }
        orderTotal += cart.deliveryCharge;
        orderTotal += cart.packingFee;
        orderTotal -= cart.platformCharge;
      }
      totalEarnings += orderTotal >= 0 ? orderTotal : 0;
    }

    return totalEarnings;
  }

  CustomerModel? findCustomerById(String id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  DeliveryBoyModel? findDeliveryBoyById(String id) {
    try {
      return deliveryBoys.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  CartModel? getOrderById(String id) {
    for (final list in [
      pendingOrders,
      inTransist,
      delivered,
      readyForPickup,
      cancelledOrders
    ]) {
      try {
        return list.firstWhere((o) => o.id == id);
      } catch (_) {}
    }
    return null;
  }

  Future<void> updatePreparationTime(
      BuildContext context, String orderId, int minutes) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(orderId)
        .update({'preparation_time': minutes});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparation time updated')),
      );
    }
    await fetchOrders();
  }

  Future<void> fetchCustomers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('customers').get();

    customers = snapshot.docs.map((doc) {
      return CustomerModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
    notifyListeners();
  }

  Future<void> fetchDeliveryBoys() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('delivery_boys')
          .where('vendor_id', isEqualTo: token)
          .get();
      deliveryBoys = snapshot.docs
          .map((doc) => DeliveryBoyModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching delivery boys: $e');
    }
  }

  Future<void> acceptOrder(BuildContext context, String id, String userId,
      int preparationTimeMinutes) async {
    await FirebaseFirestore.instance.collection('cart').doc(id).update({
      "order_status": "Order Accepted",
      "preparation_time": preparationTimeMinutes,
      "confrimTime": DateTime.now().toIso8601String(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Order Confirm by you",
        ),
        backgroundColor: Colors.black,
      ),
    );
    Navigator.pop(context);
    _sendOrderNotification(userId, 'Your Order Confirmed');
    fetchOrders();
  }

  Future<void> orderReady(
      BuildContext context, String id, String userId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(id)
        .update({"order_status": "Ready For Pickup"});
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text(
    //       "Order Confirm by you",
    //     ),
    //     backgroundColor: Colors.black,
    //   ),
    // );
    _sendOrderNotification(userId, 'Your Order Ready for pickup');
    Navigator.pop(context);
    fetchOrders();
  }

  Future<void> completeOrder(
    BuildContext context,
    String id,
    String userId, {
    bool markAsPaid = false,
  }) async {
    final updates = <String, dynamic>{
      "order_status": "Completed",
      "isDelivered": true,
    };
    if (markAsPaid) {
      updates['isPaid'] = true;
    }
    await FirebaseFirestore.instance.collection('cart').doc(id).update(updates);
    _sendOrderNotification(userId, 'Your Order is Completed');
    await fetchOrders();
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> assignDeliveryBoy(
    BuildContext context,
    String orderId,
    String userId,
    String deliveryBoyId, {
    String? deliveryBoyName,
  }) async {
    await FirebaseFirestore.instance.collection('cart').doc(orderId).update({
      'deliveryBoyId': deliveryBoyId,
    });
    final message = deliveryBoyName != null && deliveryBoyName.isNotEmpty
        ? 'Your delivery partner $deliveryBoyName has been assigned'
        : 'A delivery partner has been assigned to your order';
    _sendOrderNotification(userId, message);
    // Notify delivery boy that a new order has been assigned.
    await _sendDeliveryBoyNotification(
      deliveryBoyId,
      'A new order has been assigned to you',
    );
    await fetchOrders();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery partner assigned')),
      );
    }
  }

  // Base URL for your HTTPS Cloud Functions that proxy FCM.
  // Adjust the function name/path to match your deployed backend.
  static const String _cloudFunctionsBaseUrl =
      'https://us-central1-eatezy-63f35.cloudfunctions.net';
  static const List<String> _fcmFunctionPaths = <String>[
    // Keep the currently used path first.
    'sendFcmNotification',
    // Common alternate naming used in many Firebase projects.
    'sendFCMNotification',
    'sendNotification',
  ];

  /// Sends order status notification to customer. Uses findCustomerById, so
  /// fetchCustomers must be called first. Prints success/failure.
  Future<void> _sendOrderNotification(String userId, String text) async {
    final customer = findCustomerById(userId);
    if (customer == null || customer.token.isEmpty) {
      print('FCM: Cannot send - customer not found or token empty');
      return;
    }
    await sendFCMMessage(customer.token, text);
  }

  /// Sends order / assignment notification to a delivery boy.
  /// Requires fetchDeliveryBoys to be called before, so tokens are loaded.
  Future<void> _sendDeliveryBoyNotification(
      String deliveryBoyId, String text) async {
    final boy = findDeliveryBoyById(deliveryBoyId);
    if (boy == null || boy.fcmToken.isEmpty) {
      print('FCM: Cannot send - delivery boy not found or token empty');
      return;
    }
    await sendFCMMessage(boy.fcmToken, text);
  }

  /// Sends FCM message via your HTTPS Cloud Function instead of directly using
  /// the service account from the client app.
  Future<void> sendFCMMessage(String token, String text) async {
    await sendFCMMessageWithBody(
      token,
      text,
      'Check your Order update!',
    );
  }

  /// Sends FCM notification with custom title and body through a backend
  /// Cloud Function. The backend is responsible for talking to FCM.
  Future<void> sendFCMMessageWithBody(
      String token, String title, String body) async {
    for (final path in _fcmFunctionPaths) {
      final uri = Uri.parse('$_cloudFunctionsBaseUrl/$path');
      try {
        final response = await http.post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'token': token,
            'title': title,
            'body': body,
          }),
        );

        if (response.statusCode == 200) {
          print('Cloud Function notification sent successfully ✓ ($uri)');
          return;
        }

        print(
            'Cloud Function FCM failed at $uri: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print('Error calling Cloud Function for FCM at $uri: $e');
      }
    }

    print(
      'FCM notification not sent: no matching Cloud Function route found under '
      '$_cloudFunctionsBaseUrl. Please verify deployed function name.',
    );
  }

  /// Fetches customer FCM token from Firestore.
  Future<String?> getCustomerFcmToken(String customerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['fcm_token'] as String?;
      }
    } catch (e) {
      print('Error fetching customer FCM token: $e');
    }
    return null;
  }

  /// Sends chat notification to customer when vendor sends a message.
  Future<void> sendChatNotificationToCustomer(
      String customerId, String messagePreview) async {
    final token = await getCustomerFcmToken(customerId);
    if (token != null && token.isNotEmpty) {
      final body = messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview;
      await sendFCMMessageWithBody(
        token,
        'New message',
        body,
      );
    } else {
      print('FCM: Cannot send chat notification - customer token not found');
    }
  }
}
