import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../widgets/category_card.dart';
import '../../core/app_routes.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        // Manually override the leading widget to force the back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Adjust color if needed
          onPressed: () {
            // Safely check if we can just pop the screen off the stack
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If the stack is empty, force navigation back to the Home Screen
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: DummyData.categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final category = DummyData.categories[index];

          return CategoryCard(
            image: category.image,
            title: category.name,
            onTap: () {},
          );
        },
      ),
    );
  }
}
