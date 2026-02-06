import 'package:eatezy_vendor/models/catrgory_model.dart';
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
                PrimaryTextField(
                    title: 'Preparation time (e.g. 15 mins)',
                    controller: provider.preparationTimeController),
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
