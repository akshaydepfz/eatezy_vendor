import 'package:eatezy_vendor/models/offer_model.dart';
import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/offer/screens/add_offer_screen.dart';
import 'package:eatezy_vendor/view/offer/services/offer_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    Provider.of<OfferService>(context, listen: false).fetchOffers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddOfferScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Offer', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<OfferService>(
          builder: (context, offerService, _) {
            if (offerService.offers == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (offerService.offers!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined,
                        size: 64, color: Colors.grey.shade400),
                    AppSpacing.h20,
                    Text(
                      'No offers yet',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    AppSpacing.h5,
                    Text(
                      'Tap "Add Offer" to create an offer on a menu item',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => offerService.fetchOffers(),
              child: ListView.builder(
                itemCount: offerService.offers!.length,
                itemBuilder: (context, index) {
                  final offer = offerService.offers![index];
                  return _OfferCard(
                    offer: offer,
                    onToggleActive: () {
                      offerService.updateOfferStatus(
                        context,
                        offer.id,
                        !offer.isActive,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(context, offerService, offer);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, OfferService offerService, OfferModel offer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text(
          'Remove offer "${offer.title}" for ${offer.productName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              offerService.deleteOffer(context, offer.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onToggleActive,
    required this.onDelete,
  });

  final OfferModel offer;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final discountText = offer.discountType == 'percentage'
        ? '${offer.discountValue.toInt()}% off'
        : '₹${offer.discountValue.toInt()} off';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: offer.isActive
              ? AppColor.primary.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onToggleActive,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: Image.network(
                      offer.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, size: 32),
                      ),
                    ),
                  ),
                ),
                AppSpacing.w10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: AppStyle.titleBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.h5,
                      Text(
                        offer.productName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.h10,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          discountText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                      AppSpacing.h10,
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: offer.isActive
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offer.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: offer.isActive
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400, size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
