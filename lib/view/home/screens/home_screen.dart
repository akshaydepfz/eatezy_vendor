import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/home/services/home_provider.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<OrderService>(context, listen: false).fetchOrders();
    Provider.of<OrderService>(context, listen: false).fetchCustomers();

    Provider.of<HomeProvider>(context, listen: false).updateAdminFcmToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello KFC',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                AppSpacing.h10,
                Container(
                  padding: EdgeInsets.all(20),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.primary),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Orders',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '223',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '20.000',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.h10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Status',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(value: true, onChanged: (v) {})
                  ],
                ),
                AppSpacing.h10,
                Divider(
                  color: AppColor.lightGrey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Orders',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(onPressed: () {}, child: Text('See All'))
                  ],
                ),
                Consumer<OrderService>(builder: (context, p, _) {
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: p.pendingOrders.length,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return OrderPendingCard(
                            name: p.pendingOrders[i].name,
                            date: DateFormat('MMMM d, yyyy').format(
                                DateTime.parse(p.pendingOrders[i].createdDate)),
                            amount: "₹${p.pendingOrders[i].price}",
                            orderId: p.pendingOrders[i].id,
                            customerName: 'Akshay',
                            producID: p.pendingOrders[i].id.substring(0, 6),
                            quantity: p.pendingOrders[i].itemCount.toString(),
                            customerAddress: p.pendingOrders[i].address,
                            image: p.pendingOrders[i].image,
                            onTap: () {
                              p.acceptOrder(context, p.pendingOrders[i].id,
                                  p.pendingOrders[i].uuid);
                              Navigator.pop(context);
                            });
                      });
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderPendingCard extends StatelessWidget {
  const OrderPendingCard({
    super.key,
    required this.name,
    required this.date,
    required this.amount,
    required this.orderId,
    required this.customerName,
    required this.producID,
    required this.quantity,
    required this.customerAddress,
    required this.image,
    required this.onTap,
  });
  final String name;
  final String date;
  final String amount;
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String producID;
  final String quantity;
  final String image;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(image), fit: BoxFit.cover)),
                    height: 70,
                    width: 70,
                  ),
                  AppSpacing.w10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppStyle.titleBold,
                      ),
                      Text('$customerName | $customerAddress',
                          style: AppStyle.subSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('orderd on:$date', style: AppStyle.subSmall),
                          AppSpacing.w20,
                          const Text('Order ID: 123828',
                              style: AppStyle.subSmall),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Amount', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          amount,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Product ID', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          producID,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Qty', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          quantity,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          'Pending',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.h10,
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Accept Order'),
                      content: Text('Do you want to accept this order?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: onTap,
                          child: Text('Accept'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.primary),
                  child: Center(
                    child: Text(
                      'Accept Order',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
