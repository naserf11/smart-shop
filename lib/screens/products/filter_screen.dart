import 'package:flutter/material.dart';

class FilterScreen
    extends StatefulWidget {

  const FilterScreen({
    super.key,
  });

  @override
  State<FilterScreen>
      createState() =>
          _FilterScreenState();
}

class _FilterScreenState
    extends State<FilterScreen> {

  bool discountOnly = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Filters"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            SwitchListTile(
              title:
                  const Text(
                "Discount Only",
              ),

              value:
                  discountOnly,

              onChanged: (value) {

                setState(() {
                  discountOnly =
                      value;
                });
              },
            ),

            const SizedBox(
                height: 20),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text(
                "Apply",
              ),
            ),
          ],
        ),
      ),
    );
  }
}