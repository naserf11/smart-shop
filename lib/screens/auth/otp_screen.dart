import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 40),

              Image.asset(
                'assets/images/login.png',
                height: 180,
              ),

              const SizedBox(height: 30),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: List.generate(
                  5,
                  (_) => Container(
                    width: 55,
                    height: 55,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade200,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              PrimaryButton(
                title: "Next",
                icon:
                    Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.register,
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