import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/chat/screens/chat_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/order_service.dart';

String _getDisplayTotal(CartModel order) {
  try {
    double total = double.tryParse(order.totalPrice) ?? 0.0;
    if (order.discount != 'null' && order.discount.isNotEmpty) {
      final discountPct = double.tryParse(order.discount) ?? 0.0;
      total = total - (discountPct / 100) * total;
    }
    final displayAmount = total - order.platformCharge;
    return displayAmount >= 0 ? "₹${displayAmount.toStringAsFixed(0)}" : "₹${order.totalPrice}";
  } catch (_) {
    return "₹${order.totalPrice}";
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final CartModel order;
  const OrderDetailsScreen({super.key, required this.order});

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, color: AppColor.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderService>(context);
    final orderIdShort = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(DateTime.parse(order.createdDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Order header card
            _buildOrderHeaderCard(context, orderIdShort, dateStr),
            const SizedBox(height: 16),
            // Items section
            _buildItemsCard(context),
            const SizedBox(height: 16),
            // Customer details
            _buildCustomerCard(context),
            const SizedBox(height: 16),
            // Contact options
            _buildContactCard(context),
            const SizedBox(height: 16),
            // Order summary / total
            _buildTotalCard(context),
            const SizedBox(height: 16),
            // Notes if present
            if (order.notes.isNotEmpty) _buildNotesCard(context),
            if (order.notes.isNotEmpty) const SizedBox(height: 16),
            // Cancel order button
            if (order.orderStatus == 'Waiting' && !order.isCancelled) _buildCancelButton(context, provider),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, provider),
    );
  }

  Widget _buildOrderHeaderCard(BuildContext context, String orderIdShort, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary.withOpacity(0.15),
                      AppColor.primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$orderIdShort',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (order.deliveryType.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.delivery_dining_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  order.deliveryType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          Row(
            children: [
              Icon(
                order.isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                size: 18,
                color: order.isPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                order.isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(
                  fontSize: 14,
                  color: order.isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    String label;
    if (order.isCancelled) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Cancelled';
    } else {
      switch (order.orderStatus) {
        case 'Waiting':
          bgColor = Colors.amber.shade50;
          textColor = Colors.amber.shade800;
          label = 'New';
          break;
        case 'Order Accepted':
          bgColor = Colors.blue.shade50;
          textColor = Colors.blue.shade700;
          label = 'Confirmed';
          break;
        case 'Ready For Pickup':
          bgColor = Colors.orange.shade50;
          textColor = Colors.orange.shade700;
          label = 'Ready';
          break;
        default:
          bgColor = Colors.green.shade50;
          textColor = Colors.green.shade700;
          label = order.orderStatus;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu_rounded, color: AppColor.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...order.products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.restaurant, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          '× ${product.quantity} • ₹${product.price.toStringAsFixed(0)}/${product.unit}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${(product.price * product.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: AppColor.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColor.primary.withOpacity(0.12),
                backgroundImage: order.customerImage.isNotEmpty
                    ? NetworkImage(order.customerImage)
                    : null,
                child: order.customerImage.isEmpty
                    ? Icon(Icons.person, color: AppColor.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+91 ${order.phone}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Customer',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  onTap: () => _openChat(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  onTap: () {
                    launchUrl(Uri(scheme: 'tel', path: '+91${order.phone}'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final doc = '${order.uuid}$token';
    if (order.chatId.isEmpty) {
      await FirebaseFirestore.instance.collection('chats').doc(doc).set({
        'lastMessage': 'Hello!',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'customer_name': order.customerName,
        'customer_image': '',
        'participants': [token, order.uuid],
      });
    }
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatViewScreen(chatId: doc),
        ),
      );
    }
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    final subtotal = order.products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.quantity),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColor.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          if (order.deliveryCharge > 0) _buildSummaryRow('Delivery charge', '₹${order.deliveryCharge}'),
          if (order.packingFee > 0) _buildSummaryRow('Packing charge', '₹${order.packingFee.toStringAsFixed(0)}'),
          if (order.discount != 'null' && order.discount.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '-${order.discount}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              Text(
                _getDisplayTotal(order),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 10),
              Text(
                'Order Notes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.notes,
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, OrderService provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Confirm cancellation'),
                content: const Text(
                  'Are you sure you want to cancel this order? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('No', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      provider.cancellOrder(context, order.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Yes, cancel'),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, OrderService provider) {
    if (order.orderStatus == 'Waiting') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            title: 'Confirm Order',
            isLoading: false,
            onTap: () {
              _showConfirmDialog(
                context,
                'Confirm Order',
                'Are you sure you want to confirm this order? The customer will be notified.',
                () => provider.acceptOrder(context, order.id, order.uuid),
              );
            },
          ),
        ),
      );
    } else if (order.orderStatus == 'Order Accepted') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            title: 'Ready For Pickup',
            isLoading: false,
            onTap: () {
              _showConfirmDialog(
                context,
                'Ready For Pickup',
                'Are you sure you want to mark this order as ready for pickup?',
                () => provider.orderReady(context, order.id, order.uuid),
              );
            },
          ),
        ),
      );
    } else if (order.orderStatus == 'Ready For Pickup') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            title: 'Complete Order',
            isLoading: false,
            onTap: () {
              _showConfirmDialog(
                context,
                'Complete Order',
                'Are you sure you want to mark this order as completed?',
                () => provider.completeOrder(context, order.id, order.uuid),
              );
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
