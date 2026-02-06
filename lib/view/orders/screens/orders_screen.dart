import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:eatezy_vendor/view/orders/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedIndex = 0;

  static const List<String> _tabLabels = [
    'New',
    'Confirmed',
    'Ready',
    'Completed',
    'Cancelled',
  ];

  static const List<IconData> _tabIcons = [
    Icons.receipt_long_outlined,
    Icons.check_circle_outline,
    Icons.local_shipping_outlined,
    Icons.done_all,
    Icons.cancel_outlined,
  ];

  List<CartModel> _getOrderList(OrderService p) {
    switch (_selectedIndex) {
      case 0:
        return p.pendingOrders;
      case 1:
        return p.inTransist;
      case 2:
        return p.readyForPickup;
      case 3:
        return p.delivered;
      case 4:
        return p.cancelledOrders;
      default:
        return p.pendingOrders;
    }
  }

  bool get _isCancelledTab => _selectedIndex == 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderService>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab bar
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabLabels.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedIndex = index),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColor.primary.withOpacity(0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _tabIcons[index],
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _tabLabels[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Consumer<OrderService>(
                builder: (context, p, _) {
                  final orders = _getOrderList(p);
                  return RefreshIndicator(
                    onRefresh: () => p.fetchOrders(),
                    color: AppColor.primary,
                    backgroundColor: Colors.white,
                    child: orders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return OrderCard(
                                order: orders[index],
                                isCancelled: _isCancelledTab,
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      children: [
        const SizedBox(height: 40),
        Icon(
          _tabIcons[_selectedIndex],
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 24),
        Text(
          'No ${_tabLabels[_selectedIndex]} orders',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Orders in this section will show up here',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

}

// Legacy card widgets kept for reference; main UI uses OrderCard.
class ProcessingOrderCard extends StatelessWidget {
  const ProcessingOrderCard({
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
    required this.status,
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
  final String status;
  final VoidCallback onTap;

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
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 70,
                    width: 70,
                  ),
                  AppSpacing.w10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppStyle.titleBold),
                      Text(
                        '$customerName | $customerAddress',
                        style: AppStyle.subSmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('orderd on:$date', style: AppStyle.subSmall),
                          AppSpacing.w20,
                          Text('Order ID: 123828', style: AppStyle.subSmall),
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
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        Text(amount, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Product ID', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(producID, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Qty', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(quantity, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.h10,
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColor.primary,
                  ),
                  child: const Center(
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
  const PickupCard({
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
    required this.status,
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
  final String status;
  final VoidCallback onTap;

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
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 70,
                    width: 70,
                  ),
                  AppSpacing.w10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppStyle.titleBold),
                      Text(
                        '$customerName | $customerAddress',
                        style: AppStyle.subSmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('orderd on:$date', style: AppStyle.subSmall),
                          AppSpacing.w20,
                          Text('Order ID: 123828', style: AppStyle.subSmall),
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
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        Text(amount, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Product ID', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(producID, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Qty', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(quantity, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.h10,
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColor.primary,
                  ),
                  child: const Center(
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
  const CompletedCard({
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
    required this.status,
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
  final String status;
  final VoidCallback onTap;

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
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 70,
                    width: 70,
                  ),
                  AppSpacing.w10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppStyle.titleBold),
                      Text(
                        '$customerName | $customerAddress',
                        style: AppStyle.subSmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('orderd on:$date', style: AppStyle.subSmall),
                          AppSpacing.w20,
                          Text('Order ID: 123828', style: AppStyle.subSmall),
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
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        Text(amount, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Product ID', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(producID, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Qty', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(quantity, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Order Status', style: AppStyle.subSmall),
                        AppSpacing.h5,
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
    );
  }
}
