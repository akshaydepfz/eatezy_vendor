import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<OrderService>(context, listen: false).fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TabBar(
                  indicatorWeight: 3,
                  labelPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey.shade400,
                  controller: tabController,
                  indicatorColor: Colors.green,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Text('Processing'),
                    Text('Ready for Pickup'),
                    Text('Completed'),
                  ]),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Consumer<OrderService>(builder: (context, provider, _) {
                      return RefreshIndicator(
                        onRefresh: () => provider.fetchOrders(),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: provider.inTransist.length,
                            itemBuilder: (context, i) {
                              return ProcessingOrderCard(
                                status: provider.inTransist[i].orderStatus,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Food is Ready for pickup?'),
                                      content: Text(
                                          'Do you want to change status to pickup?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            provider.orderReady(
                                              context,
                                              provider.inTransist[i].id,
                                              provider.inTransist[i].uuid,
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                name: provider.inTransist[i].name,
                                date: DateFormat('MMMM d, yyyy').format(
                                    DateTime.parse(
                                        provider.inTransist[i].createdDate)),
                                amount: "₹${provider.inTransist[i].price}",
                                orderId: provider.inTransist[i].id,
                                customerName: provider.inTransist[i].name,
                                producID:
                                    provider.inTransist[i].id.substring(0, 6),
                                quantity:
                                    provider.inTransist[i].itemCount.toString(),
                                customerAddress: provider.inTransist[i].address,
                                image: provider.inTransist[i].image,
                              );
                            }),
                      );
                    }),
                    Consumer<OrderService>(builder: (context, provider, _) {
                      return RefreshIndicator(
                        onRefresh: () => provider.fetchOrders(),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: provider.readyForPickup.length,
                            itemBuilder: (context, i) {
                              return PickupCard(
                                status: provider.readyForPickup[i].orderStatus,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Complete This Order?'),
                                      content: Text(
                                          'Do you want to complete this order?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            provider.completeOrder(
                                              context,
                                              provider.readyForPickup[i].id,
                                              provider.readyForPickup[i].uuid,
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                name: provider.readyForPickup[i].name,
                                date: DateFormat('MMMM d, yyyy').format(
                                    DateTime.parse(provider
                                        .readyForPickup[i].createdDate)),
                                amount: "₹${provider.readyForPickup[i].price}",
                                orderId: provider.readyForPickup[i].id,
                                customerName: provider.readyForPickup[i].name,
                                producID: provider.readyForPickup[i].id
                                    .substring(0, 6),
                                quantity: provider.readyForPickup[i].itemCount
                                    .toString(),
                                customerAddress:
                                    provider.readyForPickup[i].address,
                                image: provider.readyForPickup[i].image,
                              );
                            }),
                      );
                    }),
                    Consumer<OrderService>(builder: (context, provider, _) {
                      return RefreshIndicator(
                        onRefresh: () => provider.fetchOrders(),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: provider.delivered.length,
                            itemBuilder: (context, i) {
                              return CompletedCard(
                                status: provider.delivered[i].orderStatus,
                                onTap: () {},
                                name: provider.delivered[i].name,
                                date: DateFormat('MMMM d, yyyy').format(
                                    DateTime.parse(
                                        provider.delivered[i].createdDate)),
                                amount: "₹${provider.delivered[i].price}",
                                orderId: provider.delivered[i].id,
                                customerName: provider.delivered[i].name,
                                producID:
                                    provider.delivered[i].id.substring(0, 6),
                                quantity:
                                    provider.delivered[i].itemCount.toString(),
                                customerAddress: provider.delivered[i].address,
                                image: provider.delivered[i].image,
                              );
                            }),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcessingOrderCard extends StatelessWidget {
  const ProcessingOrderCard(
      {super.key,
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
      required this.status});
  final String name;
  final String date;
  final String amount;
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String producID;
  final String quantity;
  final String image;
  final String status;
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
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
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.primary),
                  child: Center(
                    child: Text(
                      'Order Ready for pickup',
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

class PickupCard extends StatelessWidget {
  const PickupCard(
      {super.key,
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
      required this.status});
  final String name;
  final String date;
  final String amount;
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String producID;
  final String quantity;
  final String image;
  final String status;
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
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
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.primary),
                  child: Center(
                    child: Text(
                      'Complete Order',
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

class CompletedCard extends StatelessWidget {
  const CompletedCard(
      {super.key,
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
      required this.status});
  final String name;
  final String date;
  final String amount;
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String producID;
  final String quantity;
  final String image;
  final String status;
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
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
            ],
          ),
        ),
      ),
    );
  }
}
