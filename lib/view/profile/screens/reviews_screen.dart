import 'package:eatezy_vendor/models/review_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  static final List<ReviewModel> dummyReviews = [
    ReviewModel(
      id: '1',
      customerName: 'Sarah M.',
      rating: 5.0,
      comment:
          'Amazing food and quick delivery! The biryani was perfectly spiced. Will definitely order again.',
      date: 'Feb 5, 2025',
    ),
    ReviewModel(
      id: '2',
      customerName: 'James K.',
      rating: 4.0,
      comment:
          'Good quality and generous portions. Only minor issue was the packaging could be better.',
      date: 'Feb 4, 2025',
    ),
    ReviewModel(
      id: '3',
      customerName: 'Priya S.',
      rating: 5.0,
      comment:
          'Best restaurant in the area! The butter chicken is to die for. Highly recommend.',
      date: 'Feb 3, 2025',
    ),
    ReviewModel(
      id: '4',
      customerName: 'Mike R.',
      rating: 3.0,
      comment:
          'Food was okay. Took a bit longer than expected but tasted fine once it arrived.',
      date: 'Feb 2, 2025',
    ),
    ReviewModel(
      id: '5',
      customerName: 'Emma L.',
      rating: 5.0,
      comment:
          'Consistently great! I order from here every week. Never disappointed.',
      date: 'Feb 1, 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final avgRating = dummyReviews.fold<double>(
            0, (sum, r) => sum + r.rating) /
        dummyReviews.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColor.primary.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 36),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    Text(
                      '${dummyReviews.length} reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dummyReviews.length,
              separatorBuilder: (_, __) => AppSpacing.h15,
              itemBuilder: (context, index) {
                final review = dummyReviews[index];
                return _ReviewCard(review: review);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.primary.withOpacity(0.2),
                  child: Text(
                    review.customerName.isNotEmpty
                        ? review.customerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.date,
                            style: TextStyle(
                              fontSize: 12,
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
            AppSpacing.h10,
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
