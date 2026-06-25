import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_card.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../data/dummy_data.dart';
import '../../services/product_service_test.dart';
import '../products/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ProductServiceTest().testConnection();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (currentIndex == index) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    // Using pushNamedAndRemoveUntil to clear the previous stack.
    // This prevents the "back" button from popping to a previous screen
    // that might trigger a splash screen redirect loop.
    switch (index) {
      case 0:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.home);
        break;
      case 1:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.cart);
        break;
      case 2:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.scan);
        break;
      case 3:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.notifications);
        break;
      case 4:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.more);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Grocery Plus",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SearchBarWidget(controller: searchController),
              const SizedBox(height: 25),
              // Offers Section
              const Text(
                "Offers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyData.offers.length,
                  itemBuilder: (context, index) {
                    final offer = DummyData.offers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                offer.image,
                                fit: BoxFit.contain,
                                height: 120,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${(((offer.oldPrice! - offer.price) / offer.oldPrice!) * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              // Categories Section
              const Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyData.categories.length,
                  itemBuilder: (context, index) {
                    final category = DummyData.categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CategoryCard(
                        image: category.image,
                        title: category.name,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              // Best Sellers Section
              const Text(
                "Best Sellers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: DummyData.bestSellers.length,
                itemBuilder: (context, index) {
                  final product = DummyData.bestSellers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade100,
                              ),
                              child: Image.asset(
                                product.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '₦${product.price}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (product.oldPrice != null)
                                      Text(
                                        '₦${product.oldPrice}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.green.shade600,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
