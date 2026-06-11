import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Product"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 100,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "AI Product Recognition",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Scan a product and the system will identify it automatically.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                title: "Scan Product",
                icon: Icons.camera_alt,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}