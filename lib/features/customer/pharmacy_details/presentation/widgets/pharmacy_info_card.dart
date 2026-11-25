import 'package:flutter/material.dart';
import 'package:depi_final_project/core/theme/app_colors.dart';
import 'package:depi_final_project/core/theme/app_styles.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';

class PharmacyInfoCard extends StatelessWidget {
  final PharmacyDetailModel pharmacy;

  const PharmacyInfoCard({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE5EDE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0D5C52),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery time and Verified badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delivery time
                        Flexible(
                          child: Text(
                            'توصيل ${pharmacy.deliveryTime}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Verified badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'صيدلية معتمدة ومرخصة',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Address with pin
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            pharmacy.address,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Pharmacy Logo/Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCCE4DF)),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.local_pharmacy_outlined,
                        size: 28,
                        color: AppColors.primary,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment badges row
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 6.0,
            children: pharmacy.paymentMethods.map((method) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2ECE9)),
                ),
                child: Text(
                  method,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    fontSize: 10.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
