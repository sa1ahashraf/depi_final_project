import 'package:depi_final_project/core/theme/app_dimensions.dart';
import 'package:depi_final_project/core/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: AppDimensions.minTouchTarget,
    child: FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
    ),
  );
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: AppDimensions.minTouchTarget,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
    ),
  );
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) =>
      IconButton(onPressed: onPressed, icon: Icon(icon), tooltip: tooltip);
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) =>
      PrimaryButton(label: label, onPressed: onPressed, isLoading: isLoading);
}
