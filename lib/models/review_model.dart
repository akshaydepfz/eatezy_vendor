class ReviewModel {
  final String id;
  final String customerName;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
