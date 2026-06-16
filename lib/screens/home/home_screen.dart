import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_card.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../data/dummy_data.dart';
import '../../services/product_service_test.dart';
int currentIndex = 0;
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final searchController =
      TextEditingController();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    ProductServiceTest()
        .testConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     bottomNavigationBar: BottomNavBar(
  currentIndex: currentIndex,
  onTap: (index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
        break;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.cart,
        );
        break;

      case 2:
       Navigator.pushReplacementNamed(
          context,
          AppRoutes.scan,
        );
        break;

      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.notifications,
        );
        break;

      case 4:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.more,
        );
        break;
    }
  },
),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 10),

              const Text(
                "Grocery Plus",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SearchBarWidget(
                controller:
                    searchController,
              ),

              const SizedBox(height: 25),

              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,

                  itemCount:
                      DummyData.categories.length,

                  itemBuilder:
                      (context, index) {

                    final category =
                        DummyData.categories[index];

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 12,
                      ),

                      child: CategoryCard(
                        image:
                            category.image,

                        title:
                            category.name,

                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.categories,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}