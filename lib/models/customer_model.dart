class CustomerModel {
  final String image;
  final String name;
  final String email;
  final String phoneNumber;
  final String id;
  final String referId;
  final String address;
  final String token;

  CustomerModel(
      {required this.image,
      required this.name,
      required this.email,
      required this.id,
      required this.phoneNumber,
      required this.referId,
      required this.address,
      required this.token});

  factory CustomerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomerModel(
        email: data['email'],
        name: data['name'] ?? '',
        phoneNumber: data['phone'] ?? '',
        image: data['profile_image'] ?? '',
        id: data['uid'],
        referId: data['referred_by'] ?? '',
        address: data['address'] ?? '',
        token: data['fcm_token'] ?? "");
  }
}
