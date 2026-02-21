import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy_vendor/models/catrgory_model.dart';
import 'package:eatezy_vendor/models/product_model.dart';
import 'package:eatezy_vendor/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService extends ChangeNotifier {
  File? image;
  String? NetworkImage;
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<Map<String, String>> availabilitySlots = [
    {'from': '09:00', 'to': '18:00'}
  ];

  static TimeOfDay? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        return TimeOfDay(hour: h, minute: m);
      }
    }
    return null;
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay availableFromTimeOfDayAt(int index) {
    if (index < 0 || index >= availabilitySlots.length) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    return _parseTime(availabilitySlots[index]['from'] ?? '') ??
        const TimeOfDay(hour: 9, minute: 0);
  }

  TimeOfDay availableToTimeOfDayAt(int index) {
    if (index < 0 || index >= availabilitySlots.length) {
      return const TimeOfDay(hour: 18, minute: 0);
    }
    return _parseTime(availabilitySlots[index]['to'] ?? '') ??
        const TimeOfDay(hour: 18, minute: 0);
  }

  void setAvailableFromTimeAt(int index, TimeOfDay time) {
    if (index < 0 || index >= availabilitySlots.length) return;
    availabilitySlots[index]['from'] = _formatTime(time);
    notifyListeners();
  }

  void setAvailableToTimeAt(int index, TimeOfDay time) {
    if (index < 0 || index >= availabilitySlots.length) return;
    availabilitySlots[index]['to'] = _formatTime(time);
    notifyListeners();
  }

  void addAvailabilitySlot() {
    availabilitySlots.add({'from': '09:00', 'to': '18:00'});
    notifyListeners();
  }

  void removeAvailabilitySlot(int index) {
    if (availabilitySlots.length == 1) {
      availabilitySlots[0] = {'from': '09:00', 'to': '18:00'};
      notifyListeners();
      return;
    }
    if (index < 0 || index >= availabilitySlots.length) return;
    availabilitySlots.removeAt(index);
    notifyListeners();
  }
  String? selectedItem;
  List<ProductModel>? products;
  List<CategoryModel>? category;
  List<Map<String, String>> _buildAvailabilitySlots() {
    final parsed = availabilitySlots
        .map((slot) => {
              'from': (slot['from'] ?? '').trim(),
              'to': (slot['to'] ?? '').trim(),
            })
        .where((slot) => slot['from']!.isNotEmpty || slot['to']!.isNotEmpty)
        .toList();
    return parsed.isNotEmpty
        ? parsed
        : [
            {'from': '09:00', 'to': '18:00'}
          ];
  }

  Future<void> onProductInit(ProductModel product) async {
    String price = product.price.toString();
    image = null;
    String slashedPrice = product.slashedPrice.toString();
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = price;
    mrpController.text = slashedPrice;
    selectedItem = product.category;
    NetworkImage = product.image;
    availabilitySlots = product.availabilitySlots.isNotEmpty
        ? product.availabilitySlots
            .map((slot) => {
                  'from': (slot['from'] ?? '09:00').toString(),
                  'to': (slot['to'] ?? '18:00').toString(),
                })
            .toList()
        : [
            {'from': '09:00', 'to': '18:00'}
          ];
    notifyListeners();
  }

  void clear() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    mrpController.clear();
    unitController.clear();
    availabilitySlots = [
      {'from': '09:00', 'to': '18:00'}
    ];
    NetworkImage = null;
    selectedItem = null;
    image = null;
    notifyListeners();
  }

  Future<void> updateProduct(BuildContext context, String id) async {
    isLoading = true;
    notifyListeners();
    if (image != null) {
      String imageUrl = await uploadImageToStorage(image!);
      await _firestore.collection('products').doc(id).set({
        'image': imageUrl,
        'name': nameController.text,
        'description': descriptionController.text,
        'category': selectedItem,
        'price': priceController.text,
        'slashedPrice': mrpController.text,
        'availability_slots': _buildAvailabilitySlots(),
        'lastEdited': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await fetchProducts();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("product Updated Success")),
      );
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = true;
      notifyListeners();
      try {
        await _firestore.collection('products').doc(id).set({
          'name': nameController.text,
          'description': descriptionController.text,
          'category': selectedItem,
          'price': priceController.text,
          'slashedPrice': mrpController.text,
          'availability_slots': _buildAvailabilitySlots(),
          'lastEdited': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        isLoading = false;
        notifyListeners();
        await fetchProducts();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("product Updated Success")),
        );
      } on FirebaseException catch (e) {
        isLoading = false;
        notifyListeners();
        print('Failed to add user: ${e.message}');
      } catch (e) {
        isLoading = false;
        notifyListeners();
        print('An unexpected error occurred: $e');
      }
    }
  }

  Future<void> deleteProdut(BuildContext context, String id) async {
    isLoading = true;
    notifyListeners();
    await _firestore.collection('products').doc(id).delete();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("product deleted Success")),
    );
    fetchProducts();
    isLoading = false;
    notifyListeners();
  }

  /// Toggle product availability (available / sold out) using is_active. Customers can filter by is_active.
  Future<void> setProductAvailability(String productId, bool available) async {
    try {
      await _firestore.collection('products').doc(productId).set({
        'is_active': available,
        'lastEdited': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await fetchProducts();
      notifyListeners();
    } catch (e) {
      print('Error updating product availability: $e');
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? "";

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('vendor_id', isEqualTo: token)
          .get();

      products = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      products = null;
    }
  }

  Future<List<CategoryModel>?> fetchCategory() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    category = snapshot.docs.map((doc) {
      return CategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    return category;
  }

  void onCategoryChanged(String newValue) {
    selectedItem = newValue;
    notifyListeners();
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      isLoading = true;
      notifyListeners();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> addProduct(BuildContext context) async {
    if (image == null) {
      AppAlerts.wrongAlert(context, 'Please select product image');
    } else if (nameController.text.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter product name');
    } else if (descriptionController.text.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter product description');
    } else if (selectedItem == null) {
      AppAlerts.wrongAlert(context, 'Please select product category');
    } else if (mrpController.text.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter product MRP');
    } else if (priceController.text.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter product price');
    } else {
      try {
        String imageUrl = await uploadImageToStorage(image!);
        final pref = await SharedPreferences.getInstance();

        String token = pref.getString('token') ?? "";
        String shopName = pref.getString('shop_name') ?? "";
        DocumentReference docRef = await _firestore.collection('products').add({
          'id': "",
          'name': nameController.text,
          'image': imageUrl,
          'createdAt': DateTime.now().toString(),
          'description': descriptionController.text,
          'category': selectedItem,
          'price': priceController.text,
          'slashedPrice': mrpController.text,
          'totalSold': 0,
          'vendor_id': token,
          'is_flash_sale': false,
          'is_active': true,
          'lastEdited': FieldValue.serverTimestamp(),
          'unitPerItem': unitController.text,
          'favorites': [],
          'shop_name': shopName,
          'availability_slots': _buildAvailabilitySlots(),
        });
        await docRef.update({
          'id': docRef.id,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("product Added Success")),
        );
        fetchProducts();
        nameController.clear();
        descriptionController.clear();
        priceController.clear();
        selectedItem = null;
        mrpController.clear();
        unitController.clear();
        availabilitySlots = [
          {'from': '09:00', 'to': '18:00'}
        ];
        image = null;
        isLoading = false;

        notifyListeners();
        print('User added successfully!');
      } on FirebaseException catch (e) {
        isLoading = false;
        notifyListeners();
        print('Failed to add user: ${e.message}');
      } catch (e) {
        isLoading = false;
        notifyListeners();
        print('An unexpected error occurred: $e');
      }
    }
  }
}
