import 'package:eatezy_vendor/models/catrgory_model.dart';
import 'package:eatezy_vendor/models/product_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/product/services/product_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  @override
  void initState() {
    Provider.of<ProductService>(context, listen: false)
        .onProductInit(widget.product);
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
        title: const Text('Edit Item'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: provider.NetworkImage != null &&
                          provider.image == null,
                      child: GestureDetector(
                        onTap: () {
                          provider.pickImage();
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * .10,
                          width: MediaQuery.of(context).size.height * .10,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(provider.NetworkImage!),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: provider.image != null,
                      child: Container(
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
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    provider.image!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                    ),
                    AppSpacing.h10,
                    const Text(
                      'Add Image',
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
                AppSpacing.h20,
                PrimaryTextField(
                    title: 'Enter Item name',
                    controller: provider.nameController),
                AppSpacing.h20,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Item description'),
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
                            borderSide: BorderSide(color: AppColor.primary)),
                        disabledBorder: OutlineInputBorder(),
                      ),
                    )
                  ],
                ),
                // AppSpacing.h20,
                // const Text('Select product category'),
                // AppSpacing.h10,
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 12.0, vertical: 5.0),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(6.0),
                //     border: Border.all(color: Colors.grey),
                //   ),
                //   child: DropdownButtonHideUnderline(
                //     child: DropdownButton<String>(
                //       value: provider.selectedcategory,
                //       icon: const Icon(Icons.arrow_drop_down),
                //       iconSize: 24,
                //       isExpanded: true,
                //       style: const TextStyle(color: Colors.black, fontSize: 16),
                //       hint: const Text("Select product category"),
                //       onChanged: (String? newValue) {
                //         provider.oncategoryChanged(newValue!);
                //       },
                //       items: provider.categories
                //           .map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(value),
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),

                AppSpacing.h20,
                const Text('Select Item category'),
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
                      // If product's category is not in the list (e.g. category removed), add it so value is valid
                      if (provider.selectedItem != null &&
                          provider.selectedItem!.isNotEmpty &&
                          !uniqueItems.any((item) => item.name == provider.selectedItem)) {
                        uniqueItems.insert(0, CategoryModel(id: '', name: provider.selectedItem!, image: '', order: '', mainCategory: ''));
                      }
                      final validValue = provider.selectedItem != null &&
                              uniqueItems
                                  .any((item) => item.name == provider.selectedItem)
                          ? provider.selectedItem
                          : null;

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Item category',
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
                AppSpacing.h20,

                PrimaryTextField(
                    title: 'Enter Item Price',
                    controller: provider.priceController),
                AppSpacing.h20,
                PrimaryTextField(
                    title: 'Enter Item MRP Price',
                    controller: provider.mrpController),
                AppSpacing.h20,
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
                AppSpacing.h20,
                SizedBox(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Set the border radius to 8
                        ),
                      ),
                      onPressed: () {
                        provider.updateProduct(context, widget.product.id);
                      },
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )),
                ),
                AppSpacing.h10,
                SizedBox(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Set the border radius to 8
                        ),
                      ),
                      onPressed: () {
                        provider.deleteProdut(context, widget.product.id);
                      },
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )),
                ),
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
  });
  final String title;
  final TextEditingController controller;
  FormFieldValidator<String>? validator;

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
          decoration: const InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary)),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
