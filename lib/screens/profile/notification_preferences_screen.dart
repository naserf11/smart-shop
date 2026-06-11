import 'package:flutter/material.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {

  bool orderUpdates = true;
  bool promotions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Order Updates'),
            value: orderUpdates,
            onChanged: (value) {
              setState(() {
                orderUpdates = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Promotions'),
            value: promotions,
            onChanged: (value) {
              setState(() {
                promotions = value;
              });
            },
          ),
        ],
      ),
    );
  }
}