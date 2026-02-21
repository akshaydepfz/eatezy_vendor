import 'package:eatezy_vendor/models/product_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/product/screens/add_product_screen.dart';
import 'package:eatezy_vendor/view/product/screens/product_edit_screen.dart';
import 'package:eatezy_vendor/view/product/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<ProductService>(context, listen: false).fetchProducts();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((p) {
      final name = p.name.toLowerCase();
      final desc = p.description.toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddProductScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Menu'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductService>(builder: (context, p, _) {
              if (p.products == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final filtered = _filterProducts(p.products!);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No menu items' : 'No items match "$_searchQuery"',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final product = filtered[i];
                  return ProductsCard(
                    product: product,
                    productService: p,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductEditScreen(
                                    product: product,
                                  )));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ProductsCard extends StatelessWidget {
  const ProductsCard({
    super.key,
    required this.product,
    required this.productService,
    required this.onTap,
  });
  final ProductModel product;
  final ProductService productService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final productId = product.id.length >= 8 ? product.id.substring(0, 8) : product.id;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: product.isAvailable ? Colors.white : Colors.grey.shade50,
            border: product.isAvailable ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: product.isAvailable
                          ? null
                          : Container(
                              color: Colors.black26,
                              alignment: Alignment.center,
                              child: Text(
                                'Sold out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ),
                  ),
                  AppSpacing.w10,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.titleBold.copyWith(
                            color: product.isAvailable ? null : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Amount', style: AppStyle.subSmall),
                        Text(product.price.toString(), style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Product ID', style: AppStyle.subSmall),
                        Text(productId, style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('unit', style: AppStyle.subSmall),
                        Text(product.unitPerItem.toString(), style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total sold', style: AppStyle.subSmall),
                        Text('0', style: AppStyle.titleBold),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Available', style: AppStyle.subSmall),
                        Text(
                          product.availabilitySlots
                              .map((slot) =>
                                  '${slot['from'] ?? '--:--'} - ${slot['to'] ?? '--:--'}')
                              .join(', '),
                          style: AppStyle.titleBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    product.isAvailable ? 'Available' : 'Sold out',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: product.isAvailable ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: product.isAvailable,
                    onChanged: (value) {
                      productService.setProductAvailability(product.id, value);
                    },
                    activeColor: AppColor.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            onPressed: onTap,
            icon: Icon(Icons.edit, color: AppColor.primary),
          ),
        ),
      ],
    );
  }
}
