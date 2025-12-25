// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = theme.primaryColor;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case ButtonVariant.secondary:
        backgroundColor = theme.primaryColor.withOpacity(0.1);
        foregroundColor = theme.primaryColor;
        borderSide = null;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.primaryColor;
        borderSide = BorderSide(color: theme.primaryColor, width: 2);
        break;
      case ButtonVariant.danger:
        backgroundColor = Colors.red;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case ButtonVariant.success:
        backgroundColor = Colors.green;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: variant == ButtonVariant.outline ? 0 : 4,
          shadowColor: backgroundColor.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
