import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    enabled: enabled,
    obscureText: obscureText,
    maxLines: obscureText ? 1 : maxLines,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ),
  );
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.validator,
  });
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: widget.controller,
    label: widget.label ?? 'كلمة المرور',
    validator: widget.validator,
    obscureText: _obscure,
    suffixIcon: IconButton(
      onPressed: () => setState(() => _obscure = !_obscure),
      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
    ),
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, this.controller, this.hint, this.onChanged});
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    hint: hint ?? 'ابحث هنا',
    onChanged: onChanged,
    keyboardType: TextInputType.text,
    prefixIcon: const Icon(Icons.search),
  );
}

class AppPhoneField extends StatelessWidget {
  const AppPhoneField({super.key, this.controller, this.validator});
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: 'رقم الهاتف',
    validator: validator,
    keyboardType: TextInputType.phone,
    prefixIcon: const Icon(Icons.phone_outlined),
  );
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.value,
    this.label,
    this.validator,
    this.onChanged,
  });
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String? label;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    items: items,
    initialValue: value,
    onChanged: onChanged,
    validator: validator,
    decoration: InputDecoration(labelText: label),
  );
}
