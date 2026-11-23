import 'package:depi_final_project/core/constants/app_constants.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/app_icon.jpeg',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'صيدليتك ودوائك في أقرب مكان',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'جاري التحميل...',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const SizedBox(
                    width: 220,
                    height: 5,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
