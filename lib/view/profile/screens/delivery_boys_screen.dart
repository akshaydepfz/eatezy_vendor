import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatezy_vendor/view/profile/screens/add_delivery_boy_screen.dart';

class DeliveryBoysScreen extends StatefulWidget {
  const DeliveryBoysScreen({super.key});

  @override
  State<DeliveryBoysScreen> createState() => _DeliveryBoysScreenState();
}

class _DeliveryBoysScreenState extends State<DeliveryBoysScreen> {
  late Future<String> _vendorIdFuture;

  @override
  void initState() {
    super.initState();
    _vendorIdFuture = _loadVendorId();
  }

  Future<String> _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<int> _fetchTotalOrdersForBoy(String deliveryBoyId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('deliveryBoyId', isEqualTo: deliveryBoyId)
        .where('order_status', isEqualTo: 'Completed')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _vendorIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final vendorId = snapshot.data ?? '';
        if (vendorId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to load vendor information'),
            ),
          );
        }

        final stream = FirebaseFirestore.instance
            .collection('delivery_boys')
            .where('vendor_id', isEqualTo: vendorId)
            .orderBy('created_at', descending: true)
            .snapshots();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Delivery boys'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDeliveryBoyScreen(vendorId: vendorId),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add delivery boy'),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Failed to load delivery boys'),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No delivery boys found.\nTap the button below to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final id = docs[index].id;
                  final name = (data['name'] ?? '').toString();
                  final phone = (data['phone'] ?? '').toString();
                  final email = (data['email'] ?? '').toString();
                  final vehicle = (data['vehicle_number'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  final createdAt = data['created_at'];
                  DateTime? joinedDate;
                  if (createdAt is Timestamp) {
                    joinedDate = createdAt.toDate();
                  }
                  final isActive = (data['is_active'] as bool?) ?? true;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColor.primary.withOpacity(0.12),
                        backgroundImage:
                            image.isNotEmpty ? NetworkImage(image) : null,
                        child: image.isEmpty
                            ? Icon(
                                Icons.delivery_dining_rounded,
                                color: AppColor.primary,
                              )
                            : null,
                      ),
                      title: Text(
                        name.isEmpty ? 'Unnamed delivery boy' : name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (phone.isNotEmpty) Text('Phone: $phone'),
                          if (email.isNotEmpty) Text('Email: $email'),
                          if (vehicle.isNotEmpty)
                            Text('Vehicle: $vehicle'),
                          if (joinedDate != null)
                            Text(
                              'Joined: ${joinedDate.day}/${joinedDate.month}/${joinedDate.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          FutureBuilder<int>(
                            future: _fetchTotalOrdersForBoy(id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Total orders: ...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              }
                              final count = snapshot.data ?? 0;
                              return Text(
                                'Total orders: $count',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: isActive,
                        activeColor: AppColor.primary,
                        onChanged: (value) {
                          FirebaseFirestore.instance
                              .collection('delivery_boys')
                              .doc(id)
                              .update({'is_active': value});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

