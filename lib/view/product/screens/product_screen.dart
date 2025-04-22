import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:eatezy_vendor/utils/app_spacing.dart';
import 'package:eatezy_vendor/utils/app_style.dart';
import 'package:eatezy_vendor/view/product/screens/add_product_screen.dart';
import 'package:eatezy_vendor/view/product/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    Provider.of<ProductService>(context, listen: false).fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddProductScreen()));
        },
        icon: Icon(Icons.add),
        label: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Consumer<ProductService>(builder: (context, p, _) {
              return p.products == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: p.products!.length,
                          itemBuilder: (context, i) {
                            return ProductsCard(
                              description: p.products![i].description,
                              image: p.products![i].image,
                              name: p.products![i].name,
                              price: p.products![i].price.toString(),
                              stock: p.products![i].unitPerItem.toString(),
                              sold: "0",
                              productId: p.products![i].id.substring(0, 8),
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => ProductEditScreen(
                                //               product: p.products![i],
                                //             )));
                              },
                            );
                          }),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

class ProductsCard extends StatelessWidget {
  const ProductsCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.stock,
    required this.sold,
    required this.productId,
    required this.onTap,
    required this.description,
  });
  final String image;
  final String name;
  final String price;
  final String stock;
  final String sold;
  final String productId;
  final Function() onTap;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(image))),
                  ),
                  AppSpacing.w10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .55,
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.titleBold,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .55,
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Amount', style: AppStyle.subSmall),
                        Text(
                          price,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Product ID', style: AppStyle.subSmall),
                        Text(
                          productId,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('unit', style: AppStyle.subSmall),
                        Text(
                          stock,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total sold', style: AppStyle.subSmall),
                        Text(
                          sold,
                          style: AppStyle.titleBold,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
            right: 0,
            top: 0,
            child: IconButton(
                onPressed: onTap,
                icon: Icon(
                  Icons.edit,
                  color: AppColor.primary,
                )))
      ],
    );
  }
}
