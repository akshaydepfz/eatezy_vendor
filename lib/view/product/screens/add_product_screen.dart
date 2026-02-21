import 'package:eatezy_vendor/models/catrgory_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/product/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  void initState() {
    Provider.of<ProductService>(context, listen: false).clear();
    super.initState();
  }

  Future<void> _pickFromTime(ProductService provider, int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.availableFromTimeOfDayAt(index),
    );
    if (picked != null) {
      provider.setAvailableFromTimeAt(index, picked);
    }
  }

  Future<void> _pickToTime(ProductService provider, int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.availableToTimeOfDayAt(index),
    );
    if (picked != null) {
      provider.setAvailableToTimeAt(index, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Menu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height * .10,
                        width: MediaQuery.of(context).size.height * .10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: provider.image == null
                            ? IconButton(
                                onPressed: () => provider.pickImage(),
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey,
                                ))
                            : GestureDetector(
                                onTap: () => provider.pickImage(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    provider.image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                    AppSpacing.h10,
                    const Text(
                      'Add Image',
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
                AppSpacing.h20,
                PrimaryTextField(
                    title: 'Name', controller: provider.nameController),
                AppSpacing.h10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter item description'),
                    AppSpacing.h10,
                    TextField(
                      controller: provider.descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        errorBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)),
                        disabledBorder: OutlineInputBorder(),
                      ),
                    )
                  ],
                ),
                AppSpacing.h10,
                const Text('Select item category'),
                AppSpacing.h10,
                FutureBuilder<List<CategoryModel>?>(
                  future: provider.fetchCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No items found.'));
                    } else {
                      final items = snapshot.data!;
                      // Deduplicate by name so each value appears exactly once
                      final seen = <String>{};
                      final uniqueItems = items
                          .where((item) => seen.add(item.name))
                          .toList();
                      final validValue = provider.selectedItem != null &&
                              uniqueItems
                                  .any((item) => item.name == provider.selectedItem)
                          ? provider.selectedItem
                          : null;

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select product category',
                          border: OutlineInputBorder(),
                        ),
                        value: validValue,
                        items: uniqueItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.name,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          provider.onCategoryChanged(value!);
                        },
                      );
                    }
                  },
                ),
                AppSpacing.h10,
                PrimaryTextField(
                    title:
                        'Enter item unit per item (eg: 500g for 1 Qty or Large, Small Ect)',
                    controller: provider.unitController),
                AppSpacing.h10,
                PrimaryTextField(
                    title: 'MRP', controller: provider.mrpController),
                AppSpacing.h10,
                PrimaryTextField(
                    title: 'Selling Price',
                    controller: provider.priceController),
                AppSpacing.h10,
                const Text('Availability Slots'),
                AppSpacing.h10,
                ...provider.availabilitySlots.asMap().entries.map((entry) {
                  final index = entry.key;
                  final slot = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Slot ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            if (provider.availabilitySlots.length > 1)
                              IconButton(
                                onPressed: () =>
                                    provider.removeAvailabilitySlot(index),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.red),
                              ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _pickFromTime(provider, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    color: AppColor.primary, size: 22),
                                const SizedBox(width: 12),
                                const Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  slot['from'] ?? '09:00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey.shade400, size: 22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _pickToTime(provider, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    color: AppColor.primary, size: 22),
                                const SizedBox(width: 12),
                                const Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  slot['to'] ?? '18:00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey.shade400, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: provider.addAvailabilitySlot,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Slot'),
                  ),
                ),
                AppSpacing.h10,
                AppSpacing.h20,
                PrimaryButton(
                    title: 'Add Menu',
                    isLoading: provider.isLoading,
                    onTap: () => provider.addProduct(context))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PrimaryTextField extends StatelessWidget {
  PrimaryTextField({
    super.key,
    required this.title,
    required this.controller,
    this.validator = null,
    this.keyboardType,
  });
  final String title;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        AppSpacing.h10,
        TextFormField(
          validator: validator,
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
