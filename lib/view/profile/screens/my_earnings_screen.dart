import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = endOfMonth.isAfter(today) ? today : endOfMonth;
  }

  Future<void> _pickDateRange() async {
    final lastDate = DateTime.now();
    final clampedEnd = _endDate.isAfter(lastDate) ? lastDate : _endDate;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: lastDate,
      initialDateRange: DateTimeRange(start: _startDate, end: clampedEnd),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColor.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate =
            DateTime(picked.start.year, picked.start.month, picked.start.day);
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, _) {
          final ordersInRange =
              orderService.getDeliveredInDateRange(_startDate, _endDate);
          ordersInRange.sort((a, b) {
            final da = DateTime.tryParse(a.createdDate);
            final db = DateTime.tryParse(b.createdDate);
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da);
          });
          final totalOrders = ordersInRange.length;
          final totalEarnings =
              orderService.calculateEarningsInRange(_startDate, _endDate);
          final dateFormat = DateFormat('MMM d, yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColor.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month,
                                color: AppColor.primary, size: 22),
                            AppSpacing.w10,
                            Text(
                              '${dateFormat.format(_startDate)} – ${dateFormat.format(_endDate)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.edit_calendar,
                            color: AppColor.primary, size: 20),
                      ],
                    ),
                  ),
                ),
                AppSpacing.h20,
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColor.primary,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Orders',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            totalOrders.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.h15,
                      Divider(color: Colors.white.withOpacity(0.5), height: 1),
                      AppSpacing.h15,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${totalEarnings.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.h20,
                Text(
                  'Earnings are based on completed orders in the selected date range.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                AppSpacing.h20,
                if (ordersInRange.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No orders in this date range',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  AppSpacing.h10,
                  ...ordersInRange.map((CartModel order) => _OrderEarningTile(
                        order: order,
                        orderService: orderService,
                        dateFormat: dateFormat,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderEarningTile extends StatelessWidget {
  const _OrderEarningTile({
    required this.order,
    required this.orderService,
    required this.dateFormat,
  });

  final CartModel order;
  final OrderService orderService;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final amount = orderService.getOrderEarning(order);
    final date = DateTime.tryParse(order.createdDate);
    final dateStr = date != null ? dateFormat.format(date) : order.createdDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColor.primary, size: 22),
              AppSpacing.w10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (order.id.isNotEmpty)
                    Text(
                      'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
