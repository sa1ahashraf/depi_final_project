import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/screens/pharmacy_details_screen.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/presentation/screens/pharmacy_search_screen.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/presentation/widgets/global_medicine_search_bar.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/presentation/widgets/pharmacy_search_result_card.dart';
import 'package:depi_final_project/features/customer/pharmacy_search/presentation/widgets/sort_options_bar.dart';
import '../pharmacy_details/pharmacy_details_cubit_test.dart';
import 'pharmacy_search_cubit_test.dart';

void main() {
  testWidgets('PharmacySearchScreen renders header, search bar, sort options and pharmacy cards', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockPharmacySearchRepository();
    final mockDetailsRepo = MockPharmacyDetailsRepository();
    tester.view.physicalSize = const Size(390 * 2.0, 1000 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      mockDetailsRepo.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: PharmacySearchScreen(
          repository: mockRepo,
          pharmacyDetailsRepository: mockDetailsRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Top Header:
    expect(find.text('البحث في جميع الصيدليات'), findsOneWidget);
    expect(find.textContaining('المعادي، القاهرة'), findsOneWidget);

    // 2. Verify Search Bar:
    expect(find.byType(GlobalMedicineSearchBar), findsOneWidget);

    // 3. Verify Sort Options:
    expect(find.byType(SortOptionsBar), findsOneWidget);
    expect(find.text('الأقرب إليك'), findsOneWidget);
    expect(find.text('الأعلى تقييماً'), findsOneWidget);
    expect(find.text('الأسرع توصيلاً'), findsOneWidget);
    expect(find.text('الأقل سعراً'), findsOneWidget);

    // 4. Verify Pharmacy Cards are displayed (sorted by nearest first):
    // Nearest should be Al-Amal (0.5 km)
    expect(find.byType(PharmacySearchResultCard), findsWidgets);
    expect(find.text('صيدلية الأمل الحديثة'), findsOneWidget);
    expect(find.text('صيدلية النور'), findsOneWidget);

    // 5. Test interaction: Enter medicine search "Panadol"
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Panadol');
    await tester.pumpAndSettle();

    // Should show results subtitle with query
    expect(find.textContaining('نتائج دواء: "Panadol"'), findsOneWidget);
    expect(find.textContaining('Panadol Extra'), findsWidgets);

    // 6. Test interaction: Tapping on any pharmacy card navigates to PharmacyDetailsScreen ("this page")
    await tester.tap(find.text('صيدلية النور'));
    await tester.pumpAndSettle();

    // Verify PharmacyDetailsScreen opened with its specific components
    expect(find.byType(PharmacyDetailsScreen), findsOneWidget);
    expect(find.text('صيدلية معتمدة ومرخصة'), findsOneWidget);
    expect(find.text('شارع النصر، أمام مستشفى المعادي، عمارة 24'), findsOneWidget);

    // Verify search query carried over into PharmacyDetailsScreen
    expect(find.widgetWithText(TextField, 'Panadol'), findsOneWidget);
    expect(find.text('Panadol Extra'), findsOneWidget);

    // Verify clearing the search resets the query and displays other medicines
    await tester.tap(find.byIcon(Icons.cancel_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Congestal Tablets'), findsOneWidget);
  });

  testWidgets('Tapping different pharmacy opens its specific details and address', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockPharmacySearchRepository();
    final mockDetailsRepo = MockPharmacyDetailsRepository();
    tester.view.physicalSize = const Size(390 * 2.0, 1000 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      mockDetailsRepo.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: PharmacySearchScreen(
          repository: mockRepo,
          pharmacyDetailsRepository: mockDetailsRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on "صيدلية الأمل الحديثة"
    await tester.tap(find.text('صيدلية الأمل الحديثة'));
    await tester.pumpAndSettle();

    expect(find.byType(PharmacyDetailsScreen), findsOneWidget);
    expect(find.text('صيدلية الأمل الحديثة'), findsOneWidget);
    expect(
      find.text('تقاطع شارع 9 مع شارع دمشق، المعادي'),
      findsOneWidget,
    );
  });
}
