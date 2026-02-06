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
    return displayAmount >= 0
        ? "₹${displayAmount.toStringAsFixed(0)}"
        : "₹${order.totalPrice}";
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
              child: Icon(Icons.info_outline_rounded,
                  color: AppColor.primary, size: 24),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, proceed'),
          ),
        ],
      ),
    );
  }

  void _showConfirmOrderWithPrepTimeDialog(
    BuildContext context,
    OrderService provider,
    String orderId,
    String userId,
  ) {
    final prepTimeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
              child: Icon(Icons.schedule_rounded,
                  color: AppColor.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter estimated preparation time (in minutes)',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: prepTimeController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. 15',
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter preparation time';
                  }
                  final minutes = int.tryParse(value.trim());
                  if (minutes == null || minutes < 1) {
                    return 'Enter a valid number of minutes';
                  }
                  return null;
                },
              ),
            ],
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
              if (!formKey.currentState!.validate()) return;
              final minutes = int.tryParse(prepTimeController.text.trim()) ?? 0;
              if (minutes < 1) return;
              Navigator.of(ctx).pop();
              provider.acceptOrder(context, orderId, userId, minutes);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _showEditPrepTimeDialog(
    BuildContext context,
    OrderService provider,
    String orderId,
    int currentMinutes,
  ) {
    final prepTimeController = TextEditingController(
        text: currentMinutes > 0 ? currentMinutes.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit preparation time'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter estimated preparation time (in minutes)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: prepTimeController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. 15',
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter preparation time';
                  }
                  final minutes = int.tryParse(value.trim());
                  if (minutes == null || minutes < 1) {
                    return 'Enter a valid number of minutes';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final minutes = int.tryParse(prepTimeController.text.trim()) ?? 0;
              if (minutes < 1) return;
              Navigator.of(ctx).pop();
              provider.updatePreparationTime(context, orderId, minutes);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderService>(context);
    final effectiveOrder = provider.getOrderById(order.id) ?? order;
    final orderIdShort = effectiveOrder.id.length >= 8
        ? effectiveOrder.id.substring(0, 8)
        : effectiveOrder.id;
    final dateStr = DateFormat('MMM d, yyyy • h:mm a')
        .format(DateTime.parse(effectiveOrder.createdDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.grey.shade800),
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
            _buildOrderHeaderCard(
                context, effectiveOrder, orderIdShort, dateStr, provider),
            const SizedBox(height: 16),
            // Items section
            _buildItemsCard(context, effectiveOrder),
            const SizedBox(height: 16),
            // Customer details
            _buildCustomerCard(context, effectiveOrder),
            const SizedBox(height: 16),
            // Contact options (hidden for cancelled orders)
            if (!effectiveOrder.isCancelled) ...[
              _buildContactCard(context, effectiveOrder),
              const SizedBox(height: 16),
            ],
            // Order summary / total
            _buildTotalCard(context, effectiveOrder),
            const SizedBox(height: 16),
            // Notes if present
            if (effectiveOrder.notes.isNotEmpty)
              _buildNotesCard(context, effectiveOrder),
            if (effectiveOrder.notes.isNotEmpty) const SizedBox(height: 16),
            // Cancel order button
            if (effectiveOrder.orderStatus == 'Waiting' &&
                !effectiveOrder.isCancelled)
              _buildCancelButton(context, provider, effectiveOrder),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, provider, effectiveOrder),
    );
  }

  Widget _buildOrderHeaderCard(
    BuildContext context,
    CartModel orderData,
    String orderIdShort,
    String dateStr,
    OrderService provider,
  ) {
    final showPrepTime =
        orderData.orderStatus != 'Waiting' && !orderData.isCancelled;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              _buildStatusChip(orderData),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 18, color: Colors.grey.shade600),
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
          if (orderData.isCancelled &&
              orderData.cancellationReason.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cancel_outlined,
                      size: 18, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancellation reason',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderData.cancellationReason.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (orderData.deliveryType.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.delivery_dining_outlined,
                    size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  orderData.deliveryType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (showPrepTime) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showEditPrepTimeDialog(
                context,
                provider,
                orderData.id,
                orderData.preparationTimeMinutes,
              ),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      orderData.preparationTimeMinutes > 0
                          ? 'Preparation time: ${orderData.preparationTimeMinutes} mins'
                          : 'Preparation time: Not set',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_outlined,
                        size: 16, color: AppColor.primary),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                orderData.isPaid
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                size: 18,
                color: orderData.isPaid ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                orderData.isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(
                  fontSize: 14,
                  color: orderData.isPaid
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CartModel orderData) {
    Color bgColor;
    Color textColor;
    String label;
    if (orderData.isCancelled) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Cancelled';
    } else {
      switch (orderData.orderStatus) {
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
          label = orderData.orderStatus;
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

  Widget _buildItemsCard(BuildContext context, CartModel orderData) {
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
              Icon(Icons.restaurant_menu_rounded,
                  color: AppColor.primary, size: 22),
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
          ...orderData.products.map((product) {
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
                        child:
                            Icon(Icons.restaurant, color: Colors.grey.shade400),
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

  Widget _buildCustomerCard(BuildContext context, CartModel orderData) {
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
              Icon(Icons.person_outline_rounded,
                  color: AppColor.primary, size: 22),
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
                backgroundImage: orderData.customerImage.isNotEmpty
                    ? NetworkImage(orderData.customerImage)
                    : null,
                child: orderData.customerImage.isEmpty
                    ? Icon(Icons.person, color: AppColor.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderData.customerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${orderData.phone}',
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
          if (orderData.address.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    orderData.address,
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

  Widget _buildContactCard(BuildContext context, CartModel orderData) {
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
                  onTap: () => _openChat(context, orderData),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  onTap: () {
                    launchUrl(Uri(scheme: 'tel', path: '${orderData.phone}'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context, CartModel orderData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final doc = '${orderData.uuid}$token';
    if (orderData.chatId.isEmpty) {
      await FirebaseFirestore.instance.collection('chats').doc(doc).set({
        'lastMessage': 'Hello!',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'customer_name': orderData.customerName,
        'customer_image': '',
        'participants': [token, orderData.uuid],
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

  Widget _buildTotalCard(BuildContext context, CartModel orderData) {
    final subtotal = orderData.products.fold<double>(
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
              Icon(Icons.receipt_long_rounded,
                  color: AppColor.primary, size: 22),
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
          if (orderData.deliveryCharge > 0)
            _buildSummaryRow('Delivery charge', '₹${orderData.deliveryCharge}'),
          if (orderData.packingFee > 0)
            _buildSummaryRow('Packing charge',
                '₹${orderData.packingFee.toStringAsFixed(0)}'),
          if (orderData.discount != 'null' && orderData.discount.isNotEmpty)
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
                    '-${orderData.discount}%',
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
                _getDisplayTotal(orderData),
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

  Widget _buildNotesCard(BuildContext context, CartModel orderData) {
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
              Icon(Icons.note_alt_outlined,
                  color: Colors.amber.shade800, size: 20),
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
            orderData.notes,
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

  Widget _buildCancelButton(
      BuildContext context, OrderService provider, CartModel orderData) {
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Confirm cancellation'),
                content: const Text(
                  'Are you sure you want to cancel this order? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('No',
                        style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      provider.cancellOrder(context, orderData.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                Icon(Icons.cancel_outlined,
                    color: Colors.red.shade600, size: 22),
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

  Widget _buildBottomBar(
      BuildContext context, OrderService provider, CartModel orderData) {
    if (orderData.isCancelled) return const SizedBox.shrink();
    if (orderData.orderStatus == 'Waiting') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            title: 'Confirm Order',
            isLoading: false,
            onTap: () {
              _showConfirmOrderWithPrepTimeDialog(
                  context, provider, orderData.id, orderData.uuid);
            },
          ),
        ),
      );
    } else if (orderData.orderStatus == 'Order Accepted') {
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
                () =>
                    provider.orderReady(context, orderData.id, orderData.uuid),
              );
            },
          ),
        ),
      );
    } else if (orderData.orderStatus == 'Ready For Pickup') {
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
                () => provider.completeOrder(
                    context, orderData.id, orderData.uuid),
              );
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
