import 'package:eatezy_vendor/models/product_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/view/auth/screens/primary_button.dart';
import 'package:eatezy_vendor/view/offer/services/offer_service.dart';
import 'package:eatezy_vendor/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountValueController = TextEditingController();

  ProductModel? _selectedProduct;
  String _discountType = 'percentage';
  List<ProductModel> _products = [];
  bool _productsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final offerService = Provider.of<OfferService>(context, listen: false);
    final products = await offerService.fetchVendorProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _productsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final discountStr = _discountValueController.text.trim();

    if (title.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter offer title');
      return;
    }
    if (_selectedProduct == null) {
      AppAlerts.wrongAlert(context, 'Please select a menu item');
      return;
    }
    if (discountStr.isEmpty) {
      AppAlerts.wrongAlert(context, 'Please enter discount value');
      return;
    }

    final discountValue = double.tryParse(discountStr);
    if (discountValue == null || discountValue <= 0) {
      AppAlerts.wrongAlert(context, 'Please enter a valid discount value');
      return;
    }
    if (_discountType == 'percentage' && discountValue > 100) {
      AppAlerts.wrongAlert(context, 'Percentage cannot exceed 100');
      return;
    }

    final offerService = Provider.of<OfferService>(context, listen: false);
    offerService.addOffer(
      context,
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      productImage: _selectedProduct!.image,
      title: title,
      discountType: _discountType,
      discountValue: discountValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final offerService = Provider.of<OfferService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select menu item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h10,
              if (_productsLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_products.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No menu items found. Add products in Menu first.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProductModel>(
                      isExpanded: true,
                      value: _selectedProduct,
                      hint: const Text('Choose a product'),
                      items: _products.map((p) {
                        return DropdownMenuItem<ProductModel>(
                          value: p,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image.network(
                                    p.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                                  ),
                                ),
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: Text(
                                  p.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProduct = value);
                      },
                    ),
                  ),
                ),
              AppSpacing.h20,
              const Text(
                'Offer title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h10,
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Weekend Special, Buy 1 Get 1',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColor.primary)),
                ),
              ),
              AppSpacing.h20,
              const Text(
                'Discount type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h10,
              Row(
                children: [
                  Expanded(
                    child: _ChoiceChip(
                      label: 'Percentage',
                      selected: _discountType == 'percentage',
                      onSelected: () => setState(() => _discountType = 'percentage'),
                    ),
                  ),
                  AppSpacing.w10,
                  Expanded(
                    child: _ChoiceChip(
                      label: 'Fixed amount',
                      selected: _discountType == 'fixed',
                      onSelected: () => setState(() => _discountType = 'fixed'),
                    ),
                  ),
                ],
              ),
              AppSpacing.h20,
              Text(
                _discountType == 'percentage' ? 'Discount (%)' : 'Discount (₹)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h10,
              TextField(
                controller: _discountValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: _discountType == 'percentage' ? 'e.g. 20' : 'e.g. 50',
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColor.primary)),
                ),
              ),
              AppSpacing.h20,
              PrimaryButton(
                title: 'Add Offer',
                isLoading: offerService.isLoading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColor.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColor.primary : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
