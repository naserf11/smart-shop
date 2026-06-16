import 'package:flutter/material.dart';
import '../core/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  // 1. Added the '?' to make onPressed nullable.
  // When you pass 'null' during loading, Flutter automatically grays out the button.
  final VoidCallback? onPressed;
  final IconData? icon;

  // 2. Added the isLoading boolean property
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.isLoading =
        false, // Defaults to false to prevent breaking other screens
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        // 3. Conditionally render the spinner or the normal Row
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white, // Matches your existing text/icon color
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}
