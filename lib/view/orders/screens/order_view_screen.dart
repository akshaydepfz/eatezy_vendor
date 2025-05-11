import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/chat/screens/chat_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/order_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CartModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderService>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Order Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items :', style: TextStyle(fontSize: 16)),
                      AppSpacing.h10,
                      ListView.builder(
                          itemCount: order.products.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return Row(
                              children: [
                                Text(order.products[i].name),
                                AppSpacing.w10,
                                Text(
                                    "X${order.products[i].quantity.toString()}"),
                              ],
                            );
                          })
                    ],
                  ),
                ),
                AppSpacing.h20,
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Details :',
                          style: TextStyle(fontSize: 16)),
                      AppSpacing.h10,
                      Text("Name: ${order.customerName}"),
                      Text("Phone: ${order.phone}"),
                    ],
                  ),
                ),
                AppSpacing.h20,
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Options :'),
                      AppSpacing.h10,
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String token = prefs.getString('token') ?? "";
                                String doc = "${order.uuid}$token";
                                if (order.chatId == '') {
                                  final dummyMessage = "Hello!";
                                  final timestamp =
                                      FieldValue.serverTimestamp();

                                  await FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(doc)
                                      .set({
                                    'lastMessage': dummyMessage,
                                    "lastMessageTime": timestamp,
                                    "customer_name": order.customerName,
                                    "customer_image": '',
                                    "participants": [
                                      token,
                                      order.uuid,
                                    ]
                                  });
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatViewScreen(chatId: doc),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.chat)),
                                    AppSpacing.w10,
                                    Text('Chat')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.w10,
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final Uri phoneLaunchUri = Uri(
                                    scheme: 'tel', path: "+91${order.phone}");

                                launchUrl(phoneLaunchUri);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.call)),
                                    AppSpacing.w10,
                                    Text('Call')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.h20,
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Amount :'),
                      AppSpacing.h10,
                      ListView.builder(
                          itemCount: order.products.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return Row(
                              children: [
                                Text(order.products[i].name),
                                AppSpacing.w10,
                                Text(
                                    "X${order.products[i].quantity.toString()}"),
                                AppSpacing.w10,
                                Text(
                                    "₹${order.products[i].quantity * order.products[i].price}"),
                              ],
                            );
                          }),
                      AppSpacing.h5,
                      order.discount != 'null'
                          ? Row(
                              children: [
                                Text(
                                  'Discount :',
                                  style: TextStyle(color: Colors.green),
                                ),
                                AppSpacing.w10,
                                Text(
                                  "${order.discount}%",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            )
                          : SizedBox(),
                      AppSpacing.h5,
                      Row(
                        children: [
                          Text(
                            'Grand Total :',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          AppSpacing.w10,
                          Text(
                            order.discount != 'null'
                                ? "₹${applyDiscount(double.parse(order.totalPrice), double.parse(order.discount)).toString()}"
                                : "₹${order.totalPrice}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: button(order.orderStatus, () {
          if (order.orderStatus == 'Waiting') {
            provider.acceptOrder(context, order.id, order.uuid);
          } else if (order.orderStatus == 'Order Accepted') {
            provider.orderReady(context, order.id, order.uuid);
          } else if (order.orderStatus == 'Ready For Pickup') {
            provider.completeOrder(context, order.id, order.uuid);
          }
        }));
  }

  double applyDiscount(double totalPrice, double discountPercentage) {
    double discountAmount = (discountPercentage / 100) * totalPrice;
    return totalPrice - discountAmount;
  }

  Widget button(String statis, Function() onTap) {
    if (statis == 'Waiting') {
      return Container(
        margin: EdgeInsets.all(15),
        child: PrimaryButton(
            title: 'Confirm Order', isLoading: false, onTap: onTap),
      );
    } else if (statis == 'Order Accepted') {
      return Container(
        margin: EdgeInsets.all(15),
        child: PrimaryButton(
            title: 'Ready For Pickup', isLoading: false, onTap: onTap),
      );
    } else if (statis == 'Ready For Pickup') {
      return Container(
        margin: EdgeInsets.all(15),
        child: PrimaryButton(
            title: 'Complete Order', isLoading: false, onTap: onTap),
      );
    }
    return SizedBox();
  }
}
