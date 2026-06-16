import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../widgets/category_card.dart';


int currentIndex = 1;
class CategoriesScreen
    extends StatelessWidget {

  const CategoriesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Categories"),
      ),

      body: GridView.builder(
        padding:
            const EdgeInsets.all(20),

        itemCount:
            DummyData.categories.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),

        itemBuilder:
            (context, index) {

          final category =
              DummyData.categories[
                  index];

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