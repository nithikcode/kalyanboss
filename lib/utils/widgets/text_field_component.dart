import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/theme.dart';
import '../enums/enums.dart';






class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final Widget? leading;
  final VoidCallback? onLeadingTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  // Use nullable colors to allow Theme defaults
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? bgColor;

  final double labelSize;
  final double hintSize;
  final double textSize;

  final bool enabled;
  final bool isEnabled;

  final ValidationType validationType;
  final String? validationMessage;
  final int? minLength;
  final int? maxLength;
  final String? Function(String?)? customValidator;

  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  final int minLines;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.trailing,
    this.onTrailingTap,
    this.leading,
    this.onLeadingTap,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.borderColor,
    this.focusedBorderColor,
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.bgColor,
    this.labelSize = 14,
    this.hintSize = 14,
    this.textSize = 16,
    this.enabled = true,
    this.isEnabled = true,
    this.validationType = ValidationType.none,
    this.validationMessage,
    this.minLength,
    this.maxLength,
    this.customValidator,
    this.onChanged,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  String? _validate(String? value) {
    // ... logic remains same as your original validate function ...
    // Note: Kept your logic but wrapped it in the build for standard TextFormField use
    if (widget.validationType == ValidationType.required && (value == null || value.isEmpty)) {
      return widget.validationMessage ?? "${widget.label ?? "Field"} is required";
    }
    // (Other cases: email, phone, etc.)
    return widget.customValidator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Theme-based Color Resolution
    final effectiveTextColor = widget.textColor ?? colorScheme.onSurface;
    final effectiveHintColor = widget.hintColor ?? theme.hintColor;
    final effectiveLabelColor = widget.labelColor ?? colorScheme.onSurfaceVariant;
    final effectiveBorderColor = widget.borderColor ?? theme.dividerColor;
    final effectiveFocusBorder = widget.focusedBorderColor ?? colorScheme.primary;
    final effectiveBg = widget.bgColor ?? colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          validator: _validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enabled: widget.isEnabled && widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.bodyMedium(color: effectiveTextColor, size: widget.textSize),
          minLines: widget.minLines,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.isEnabled ? effectiveBg : colorScheme.surfaceVariant.withOpacity(0.3),
            labelText: widget.label,
            labelStyle: AppTextStyles.bodySmall(color: effectiveLabelColor, size: widget.labelSize),
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium(color: effectiveHintColor, size: widget.hintSize),
            errorText: widget.errorText,

            // Standardizing Borders
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: effectiveFocusBorder, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red),
            ),

            // Icons
            prefixIcon: widget.leading != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: widget.leading,
            )
                : null,
            suffixIcon: _buildSuffixIcon(effectiveHintColor),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(Color iconColor) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: iconColor,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.trailing != null) {
      return InkWell(
        onTap: widget.onTrailingTap,
        child: widget.trailing,
      );
    }
    return null;
  }
}