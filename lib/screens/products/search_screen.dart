import 'package:flutter/material.dart';

import '../../widgets/search_bar_widget.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  final controller =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            SearchBarWidget(
              controller: controller,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SearchResultsScreen(
                      keyword:
                          controller.text,
                    ),
                  ),
                );
              },

              child:
                  const Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}