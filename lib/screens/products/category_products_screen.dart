import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    final List<Product> products =
        DummyData.products
            .where(
              (product) =>
                  product.categoryId ==
                  widget.categoryId,
            )
            .where(
              (product) =>
                  product.name
                      .toLowerCase()
                      .contains(
                        searchText.toLowerCase(),
                      ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  searchController,
              decoration:
                  const InputDecoration(
                hintText:
                    "Search Product",
                prefixIcon:
                    Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      "No products found",
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        products.length,
                    itemBuilder:
                        (context, index) {

                      final product =
                          products[index];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(
                          title: Text(
                            product.name,
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                "RM ${product.oldPrice}",
                                style:
                                    const TextStyle(
                                  decoration:
                                      TextDecoration
                                          .lineThrough,
                                  color:
                                      Colors.grey,
                                ),
                              ),

                              Text(
                                "RM ${product.price}",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.orange,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      18,
                                ),
                              ),
                            ],
                          ),

                          trailing:
                              ElevatedButton(
                            onPressed: () {

                              CartService()
                                  .addToCart(
                                product,
                              );

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product.name} added to cart",
                                  ),
                                ),
                              );
                            },

                            child:
                                const Text(
                              "Add",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}