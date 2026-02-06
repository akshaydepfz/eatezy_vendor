import 'package:eatezy_vendor/models/cart_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderService>(context, listen: false).fetchRatedOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, _) {
          if (orderService.isLoadingRatedOrders) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColor.primary),
                  AppSpacing.h15,
                  Text('Loading reviews...'),
                ],
              ),
            );
          }
          final ratedOrders = orderService.ratedOrders;
          if (ratedOrders.isEmpty) {
            return _buildEmptyState();
          }
          final avgRating = ratedOrders.fold<double>(
                  0, (sum, c) => sum + c.rating) /
              ratedOrders.length;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(avgRating, ratedOrders.length)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _RatingCard(cart: ratedOrders[index]),
                      );
                    },
                    childCount: ratedOrders.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            AppSpacing.h20,
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            AppSpacing.h10,
            Text(
              'Ratings from completed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double avgRating, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primary.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count == 1 ? '1 review' : '$count reviews',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formats cart createdDate (ISO or plain string) to a readable date.
String _formatReviewDate(String createdDate) {
  if (createdDate.isEmpty) return '—';
  try {
    final dt = DateTime.tryParse(createdDate);
    if (dt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    }
  } catch (_) {}
  return createdDate;
}

class _RatingCard extends StatelessWidget {
  final CartModel cart;

  const _RatingCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final hasComment = cart.ratingText.isNotEmpty && cart.ratingText != 'null';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with order reference
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColor.primary.withOpacity(0.06),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 18, color: AppColor.primary.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Text(
                    'Order #${cart.id.length > 8 ? cart.id.substring(0, 8) : cart.id}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatReviewDate(cart.createdDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColor.primary.withOpacity(0.12),
                        backgroundImage: cart.customerImage.isNotEmpty && cart.customerImage != 'null'
                            ? NetworkImage(cart.customerImage)
                            : null,
                        child: cart.customerImage.isEmpty || cart.customerImage == 'null'
                            ? Text(
                                cart.customerName.isNotEmpty
                                    ? cart.customerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cart.customerName.isNotEmpty ? cart.customerName : 'Customer',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < cart.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 22,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${cart.rating.toStringAsFixed(1)} / 5',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (hasComment) ...[
                    AppSpacing.h15,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cart.ratingText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                  if (cart.products.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.restaurant_menu_outlined, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cart.products
                                .map((p) => p.quantity > 1 ? '${p.name} × ${p.quantity}' : p.name)
                                .join(', '),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        'Order total: ${cart.totalPrice}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
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
    );
  }
}
