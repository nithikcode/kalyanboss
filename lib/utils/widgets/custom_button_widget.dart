import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor, // Leave null to use Theme defaults
    this.disabledColor,
    this.borderColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logic: Manual override > Theme primary > AppColors fallback
    final activeColor = backgroundColor ?? theme.primaryColor;
    final inactiveColor = disabledColor ?? theme.disabledColor;
    final currentBgColor = isEnabled && !isLoading ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: (isEnabled && !isLoading) ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: currentBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: isEnabled && !isLoading ? [
            BoxShadow(
              color: activeColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        padding: padding,
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : DefaultTextStyle(
          // This ensures any Text child uses the correct contrast color
          style: AppTextStyles.button(color: AppColors.whiteText),
          child: child,
        ),
      ),
    );
  }
}
