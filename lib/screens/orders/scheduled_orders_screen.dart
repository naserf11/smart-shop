import 'package:flutter/material.dart';

class ScheduledOrdersScreen
    extends StatelessWidget {

  const ScheduledOrdersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scheduled Orders",
        ),
      ),
      body: ListView(
        children: const [

          ListTile(
            leading: Icon(
              Icons.calendar_today,
            ),
            title: Text(
              "Weekly Grocery Order",
            ),
            subtitle: Text(
              "Every Saturday",
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.calendar_today,
            ),
            title: Text(
              "Monthly Essentials",
            ),
            subtitle: Text(
              "1st of each month",
            ),
          ),
        ],
      ),
    );
  }
}