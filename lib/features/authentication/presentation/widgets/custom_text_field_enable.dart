import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendor_app/core/utils/app_colors.dart';

class CustomTextFieldEnable extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  // New (optional) props
  final bool enabled;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines; // defaults to 1

  const CustomTextFieldEnable({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe padding so keyboard खुलने पर field cover न हो
    final scrollPadding = EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 80,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.labelColor,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          scrollPadding: scrollPadding,

          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            hintStyle: TextStyle(color: AppColors.textFieldColor),
            counterText: '', // maxLength दिखाना हो तो हटाएँ
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),

            suffixIcon: suffixIcon,
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
