import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/view/orders/screens/order_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable order card matching the design used in the Orders tab.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.isCancelled = false,
  });

  final CartModel order;
  final bool isCancelled;

  /// Full order total: subtotal + delivery + packing + platform + transaction fee (with decimals).
  static String getDisplayTotal(CartModel order) {
    try {
      final subtotal = order.products.fold<double>(
        0, (sum, p) => sum + (p.price * p.quantity),
      );
      double grandTotal = subtotal +
          order.deliveryCharge +
          order.packingFee +
          order.platformCharge +
          order.transactionFee;
      final discountPct = double.tryParse(order.discount) ?? 0.0;
      if (discountPct > 0) {
        grandTotal = subtotal * (1 - discountPct / 100) +
            order.deliveryCharge +
            order.packingFee +
            order.platformCharge +
            order.transactionFee;
      }
      return grandTotal >= 0 ? grandTotal.toStringAsFixed(2) : order.totalPrice;
    } catch (_) {
      return order.totalPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderIdShort = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;
    final dateStr = DateFormat('MMM d, yyyy • h:mm a')
        .format(DateTime.parse(order.createdDate));
    final displayTotal = getDisplayTotal(order);
    final hasPackingCharge = order.packingFee > 0;
    final hasDeliveryCharge = order.deliveryCharge > 0;
    final hasTransactionFee = order.transactionFee > 0;
    final isCod = order.deliveryType.toLowerCase() == 'cod' || !order.isPaid;
    final showPlatformFee = isCod && order.platformCharge > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(order: order),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Left accent bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCancelled
                            ? [Colors.grey.shade400, Colors.grey.shade300]
                            : [
                                AppColor.primary,
                                AppColor.primary.withOpacity(0.5),
                              ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: order ID, scheduled badge, status, date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          if (order.isScheduled) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.deepPurple.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: Colors.deepPurple.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Scheduled',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepPurple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          _buildStatusChip(context),
                          const SizedBox(width: 12),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isCancelled &&
                          order.cancellationReason.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.shade100, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.cancellationReason.trim(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 16),
                      // Customer info
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppColor.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (order.address.isNotEmpty)
                                  Text(
                                    order.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (order.preparationTimeMinutes > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${order.preparationTimeMinutes} mins prep',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
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
                      ),
                      const SizedBox(height: 18),
                      // Products preview
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            ...order.products.take(3).map((product) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        product.image,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.restaurant, color: Colors.grey.shade400),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '× ${product.quantity} • ₹${(product.price * product.quantity).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (order.products.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(left: 66, top: 4),
                                child: Text(
                                  '+${order.products.length - 3} more item(s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Charges breakdown
                      if (hasPackingCharge || hasDeliveryCharge || showPlatformFee || hasTransactionFee) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (hasDeliveryCharge)
                                _buildChargeRow('Delivery charge', '₹${order.deliveryCharge.toStringAsFixed(2)}'),
                              if (hasDeliveryCharge && (hasPackingCharge || showPlatformFee || hasTransactionFee)) const SizedBox(height: 8),
                              if (hasPackingCharge)
                                _buildChargeRow('Packing charge', '₹${order.packingFee.toStringAsFixed(2)}'),
                              if (hasPackingCharge && (showPlatformFee || hasTransactionFee)) const SizedBox(height: 8),
                              if (showPlatformFee)
                                _buildChargeRow('Platform fee', '₹${order.platformCharge.toStringAsFixed(2)}'),
                              if (showPlatformFee && hasTransactionFee) const SizedBox(height: 8),
                              if (hasTransactionFee)
                                _buildChargeRow('Transaction fee', '₹${order.transactionFee.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      // Total row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primary.withOpacity(0.08),
                              AppColor.primary.withOpacity(0.04),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '₹$displayTotal',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // View details CTA
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColor.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18, color: AppColor.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color textColor;
    Color bgColor;
    String label;
    if (order.isCancelled) {
      textColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
      label = 'Cancelled';
    } else {
      switch (order.orderStatus) {
        case 'Waiting':
          textColor = Colors.amber.shade800;
          bgColor = Colors.amber.shade50;
          label = 'New';
          break;
        case 'Order Accepted':
          textColor = Colors.blue.shade700;
          bgColor = Colors.blue.shade50;
          label = 'Confirmed';
          break;
        case 'Ready For Pickup':
          textColor = Colors.orange.shade700;
          bgColor = Colors.orange.shade50;
          label = 'Ready';
          break;
        case 'Completed':
        case 'Order Delivered':
          textColor = Colors.green.shade700;
          bgColor = Colors.green.shade50;
          label = 'Completed';
          break;
        default:
          textColor = Colors.green.shade700;
          bgColor = Colors.green.shade50;
          label = order.orderStatus;
      }
    }
    return _chip(label, textColor, bgColor);
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildChargeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
