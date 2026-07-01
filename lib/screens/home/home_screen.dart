import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_card.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../home/categories_screen.dart';
import '../products/category_products_screen.dart';
import '../products/product_details_screen.dart';
import '../products/product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;

  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _offersFuture;
  late Future<List<Product>> _bestSellersFuture;

  @override
  void initState() {
    super.initState();

    // Initialize futures
    _categoriesFuture = _categoryService.getCategories();
    _offersFuture = _productService.getOffers();
    _bestSellersFuture = _productService.getBestSellers();
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

    setState(() {
      currentIndex = index;
    });

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
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning', style: textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text('Grocery Plus', style: textTheme.headlineLarge),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
                            SearchBarWidget(
                controller: searchController,
                readOnly: true,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.search);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'Offers',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(
                        title: 'All Offers',
                        productsFuture: _productService.getOffers(),
                        emptyMessage: 'No offers available at the moment.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Product>>(
                future: _offersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: Text('Error loading offers')),
                    );
                  }

                  final offers = snapshot.data ?? [];

                  if (offers.isEmpty) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: Text('No offers available')),
                    );
                  }

                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return _buildOfferCard(context, offers[index]);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              _buildSectionHeader(
                title: 'Categories',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoriesScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: Text('Error loading categories')),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: Text('No categories available')),
                    );
                  }

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
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
                  );
                },
              ),
              const SizedBox(height: 26),
              _buildSectionHeader(
                title: 'Best Sellers',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(
                        title: 'Best Sellers',
                        productsFuture: _productService.getBestSellers(),
                        emptyMessage:
                            'No best sellers available at the moment.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Product>>(
                future: _bestSellersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text('Error loading best sellers'),
                      ),
                    );
                  }

                  final bestSellers = snapshot.data ?? [];

                  if (bestSellers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text('No best sellers available'),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bestSellers.length,
                    itemBuilder: (context, index) {
                      final product = bestSellers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppSizes.cardRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: product.image.isNotEmpty
                                          ? (product.image.startsWith('http')
                                                ? Image.network(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                  )
                                                : Image.asset(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                  ))
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'RM ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (product.oldPrice > 0)
                                        Text(
                                          'RM ${product.oldPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: GestureDetector(
                                    onTap: () {
                                      CartService().addToCart(product);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.name} added to cart',
                                          ),
                                          backgroundColor:
                                              Colors.green.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        TextButton(onPressed: onViewAll, child: const Text('View all')),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, Product offer) {
    final discountPercentage = offer.oldPrice > 0
        ? (((offer.oldPrice - offer.price) / offer.oldPrice) * 100)
              .toStringAsFixed(0)
        : '0';

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: offer),
            ),
          );
        },
        child: Container(
          width: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEDF8F1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.cardRadius),
                      topRight: Radius.circular(AppSizes.cardRadius),
                    ),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: offer.image.isNotEmpty
                          ? (offer.image.startsWith('http')
                                ? Image.network(
                                    offer.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.cardColor,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    offer.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.cardColor,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ))
                          : Container(
                              color: AppColors.cardColor,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'RM ${offer.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (offer.oldPrice > 0)
                          Text(
                            'RM ${offer.oldPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
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
    );
  }
}
