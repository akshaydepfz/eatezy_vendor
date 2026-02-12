import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
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

        if (data['order_status'] == 'Waiting' &&
            data['isCancelled'] == false &&
            data['order_status'] != 'Completed') {
          pendingOrders.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
        } else if (data['order_status'] != 'Waiting' &&
            data['order_status'] != "Ready For Pickup" &&
            data['order_status'] != "Completed" &&
            data['isCancelled'] == false) {
          inTransist.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
        } else if (data['order_status'] == "Completed") {
          delivered.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
        } else if (data['isCancelled'] == false &&
            data['order_status'] == "Ready For Pickup" &&
            data['order_status'] != "Completed") {
          readyForPickup.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
        } else if (data['isCancelled'] == true) {
          cancelledOrders.add(CartModel.fromFirestore(data, doc.id));
          notifyListeners();
        }
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
    final updates = <String, dynamic>{"order_status": "Completed"};
    if (markAsPaid) {
      updates['isPaid'] = true;
    }
    await FirebaseFirestore.instance.collection('cart').doc(id).update(updates);
    _sendOrderNotification(userId, 'Your Order is Completed');
    await fetchOrders();
    if (context.mounted) Navigator.pop(context);
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "eatezy-63f35",
      "private_key_id": "4e6862e9eb1f24d0ee0e7979a1a35ac6e26e196d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDUZC5vPTCVz+ui\nOGa+3aK7RaTXhwPFAIPMeZd0qqhkWJAYGngKV/5Rwlq8OMvwdALSIIFI/35eQ4Ps\nUWuiME9fb9su1XdaOq51BoEvodkDQk4kBWX3+HplMmeazdWKA3QDfi8pZ8+nJ+U8\n72y05c/0H/DSfL2vKWHkxUqOWt+NrPLuk7Qm1W5vLhDZG8srC2c+WSfTWAEQG2yF\nlgAVEeYyXAmYoA5zJlMvpMLxZvJqBzYnwfERS5Wyv7gYIzt43M0cWS/XbWG+JUPX\n0F79ACOvS41MKFC1PiLpKKggh4szWqR2KCxrZS+IOfzbpRMGX65pyrFYBfllEeJa\nq6B1BA0HAgMBAAECggEAWXY9TOPUVDY5RaJGPP00b3d9YL9hKhj2aymITz8XIPVg\n9JYpnAnGeP/JomC2HnlvOr0wV+QugVwk9GSzVqTMuiFujIKj/GCdXXO49KxSsZm7\nOlb/xXxnabragw1SdgjQVCxRhzpP8FPQrmMXQfdPKcBOewrKBz8CGg+0QNQsOAst\n6rZRScdV1dO3GhuQl9dfiVLFXPUOkVLrCwg5jg/gKW+f/yA5x9RkMzrL9LgK66o4\n4ZydFlX3PCwk0JrAc4MPLSrjJMRQ/D0PFKY0gC3Jv7Fwu4EY+ulEbfW6iv+WY8o+\nJI04jEF+RucOD7uCnVYQn0bRR7THa3KmHGuvxSl2KQKBgQDt0HsaAEBng7O7YQC3\nKOGr2uem7mEmh0+Oa0WZRR6GtNqUAKA7xJiuKFvxTQL0ViXYecE02RtKTmM/OFEQ\nqS5b0tJM1dvUY8k6oOssSu8eJ8u0Qb+DCgo6vZLf0dEcIKj0Za/TqYWpqLSaR3M3\ndcdQ5d8Wk5XpQVWaa3zKEVz9iwKBgQDkogMWUw2NJ6ZR0SU+sQJjt8Z/7FU8f32H\nhi7cztfWXeAJocDPJedsQiwf2gLTgUC43o4nBAOxK171Jzt6iN9DF8hDaMVnU2Ki\nyhDk7EP0DZ93lYQloSqVbaiadf6nWfv61waKBiLmjC9FHk1qdIR24Cu8donL3Vj7\nhL3Tm8sV9QKBgF/5wISoz1U3aMTZjCFfRVxHFzBeiiSzfR78GfWWWJCC0qfibMhS\nOlAnB5wluWiEj/eCg7/hUss1QYaVIto3fPcf6TGLKZHYx7B6mw6gG0qvQt23nyOy\nXJiCQ5FCq0LPx4ACvegNRV1IMcMFzPD3/n2el98Tpu+hJ3wPnygpw76rAoGAEfEg\n2uSjoJsm8y69hIDxlg+69Rj/y2KZ4EPIc62LxJfTWA4oilkIIzfCLLG4HQ78nEVi\n1G79Ny8XIZf1k/UfyC0amyeiriweBnZjAwQDhSh4hjLmjulp5RYY8B4oYMuv+Yxc\nSAKZRIxlvT/WhW8lYgrPg9etkqEJNZvCJdQJCO0CgYEAg9nX6MAquqGBIZzgJuRZ\nKSJxThZJP4kBW51qVSeoYpp5J3K96sIYk4/jhc0C190OtprrMDfn37yOGc/KsTF8\nHuEzOoTrk+3uMuJ4oQ9HIUcRFIYRCi50k/lTjm3xHSiwBQQBxkh4Zp2pS976my+O\nlkEqX6PJqrUMf04cXg4rgpQ=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@eatezy-63f35.iam.gserviceaccount.com",
      "client_id": "105045129822052618782",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40eatezy-63f35.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

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

  Future<void> sendFCMMessage(String token, String text) async {
    await _sendFCM(token, '$text 🥳', 'Check your Order update!');
  }

  /// Sends FCM notification with custom title and body (e.g. for chat).
  Future<void> sendFCMMessageWithBody(
      String token, String title, String body) async {
    await _sendFCM(token, title, body);
  }

  Future<void> _sendFCM(String token, String title, String body) async {
    final String serverKey = await getAccessToken();

    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/eatezy-63f35/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM notification sent successfully ✓');
    } else {
      print('FCM failed: ${response.statusCode} - ${response.body}');
    }
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
