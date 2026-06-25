import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String keyword;

  const SearchResultsScreen({
    super.key,
    required this.keyword,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = _productService.searchProducts(widget.keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
      ),
      body: FutureBuilder<List<Product>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return Center(
              child: Text('No results found for "${widget.keyword}"'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        product: product,
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
          );
        },
      ),
    );
  }
}