import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchResultsScreen
    extends StatelessWidget {

  final String keyword;

  const SearchResultsScreen({
    super.key,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {

    final results =
        DummyData.products
            .where(
              (product) =>
                  product.name
                      .toLowerCase()
                      .contains(
                        keyword
                            .toLowerCase(),
                      ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Results"),
      ),

      body: ListView.builder(
        padding:
            const EdgeInsets.all(20),

        itemCount: results.length,

        itemBuilder:
            (context, index) {

          final product =
              results[index];

          return GestureDetector(
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailsScreen(
                    product:
                        product,
                  ),
                ),
              );
            },

            child: ProductCard(
              product: product,
              onAdd: () {},
            ),
          );
        },
      ),
    );
  }
}