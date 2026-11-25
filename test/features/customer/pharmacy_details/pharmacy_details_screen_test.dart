import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/screens/pharmacy_details_screen.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/medicine_card_widget.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/medicine_search_bar.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/presentation/widgets/missing_medicine_card.dart';
import 'pharmacy_details_cubit_test.dart';

void main() {
  testWidgets('PharmacyDetailsScreen renders every point in screenshot', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockPharmacyDetailsRepository();

    // Set screen size matching modern mobile screen with ample height for test inspection
    tester.view.physicalSize = const Size(390 * 2.0, 1200 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      mockRepo.dispose();
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
        home: PharmacyDetailsScreen(
          pharmacyId: 'pharmacy_al_nour',
          repository: mockRepo,
          preloadCartForDemo: true,
        ),
      ),
    );

    // Pump frames to load streams and post-frame callback
    await tester.pumpAndSettle();

    // 1. Verify Top Header:
    // - Pharmacy Name
    expect(find.text('صيدلية النور'), findsOneWidget);
    // - Rating
    expect(find.text('4.8'), findsOneWidget);
    // - Distance
    expect(find.textContaining('1.2 كم من موقعك'), findsOneWidget);
    // - Open Status
    expect(find.text('مفتوح الآن'), findsOneWidget);
    // - Chat button
    expect(find.text('محادثة'), findsOneWidget);

    // 2. Verify Pharmacy Info Card:
    // - Verified Badge
    expect(find.text('صيدلية معتمدة ومرخصة'), findsOneWidget);
    // - Delivery Time
    expect(find.text('توصيل 20-30 دقيقة'), findsOneWidget);
    // - Address
    expect(
      find.text('شارع النصر، أمام مستشفى المعادي، عمارة 24'),
      findsOneWidget,
    );
    // - Payment Badges
    expect(find.text('إكسترا باي InstaPay'), findsOneWidget);
    expect(find.text('فودافون كاش'), findsOneWidget);
    expect(find.text('دفع عند الاستلام'), findsOneWidget);

    // 2.5 Verify Search Bar:
    expect(find.byType(MedicineSearchBar), findsOneWidget);
    expect(
      find.text('ابحث عن اسم الدواء أو المادة الفعالة...'),
      findsOneWidget,
    );

    // 3. Verify Category Filter Pills:
    expect(find.text('جميع الأدوية (120)'), findsOneWidget);
    expect(find.text('مسكنات وحرارة'), findsOneWidget);
    expect(find.text('البرد والإنفلونزا'), findsOneWidget);

    // 4. Verify Live Inventory Header:
    expect(
      find.text('المخزون الفعلي للصيدلية (متجدد لحظياً)'),
      findsOneWidget,
    );
    expect(find.text('تحديث فوري'), findsOneWidget);

    // 5. Verify Medicine Cards (all 4 items):
    // Card 1: Panadol Extra
    expect(find.text('Panadol Extra'), findsOneWidget);
    expect(
      find.text('باراسيتامول + كافيين (مسكن للصداع والآلام)'),
      findsOneWidget,
    );
    expect(find.text('متوفر 18 علبة'), findsAtLeast(1));
    expect(find.text('45 ج.م'), findsAtLeast(1));
    expect(find.text('24 قرص'), findsAtLeast(1));

    // Card 2: Congestal Tablets
    expect(find.text('Congestal Tablets'), findsOneWidget);
    expect(
      find.text('لعلاج أعراض نزلات البرد والاحتقان والرشح'),
      findsOneWidget,
    );
    expect(find.text('متوفر 25 علبة'), findsAtLeast(1));
    expect(find.text('31 ج.م'), findsAtLeast(1));
    expect(find.text('20 قرص'), findsAtLeast(1));

    // Card 3: C-Retard 500mg
    expect(find.text('C-Retard 500mg'), findsOneWidget);
    expect(
      find.text('فيتامين C ممتد المفعول لتعزيز المناعة اليومية'),
      findsOneWidget,
    );
    expect(find.text('متوفر 12 علبة'), findsAtLeast(1));
    expect(find.text('28 ج.م'), findsAtLeast(1));
    expect(find.text('10 كبسولات'), findsAtLeast(1));

    // Card 4: Antinal 200mg
    expect(find.text('Antinal 200mg'), findsOneWidget);
    expect(
      find.text('مطهر معوي واسع المدى لعلاج النزلات المعوية'),
      findsOneWidget,
    );
    expect(find.text('متوفر 9 علب'), findsAtLeast(1));
    expect(find.text('36 ج.م'), findsAtLeast(1));
    expect(find.text('24 كبسولة'), findsAtLeast(1));

    // 6. Verify Missing Medicine Help Banner:
    await tester.scrollUntilVisible(
      find.byType(MissingMedicineCard),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('مش لاقي دواك أو محتاج بديل؟'), findsOneWidget);
    expect(
      find.text('ابعت روشتة أو اسأل صيدلي النور مباشرة في الشات'),
      findsOneWidget,
    );
    expect(find.text('شات الصيدلي'), findsOneWidget);

    // 7. Verify Sticky Bottom Floating Cart Bar:
    // - Counter badge "2"
    expect(find.text('2'), findsOneWidget);
    // - Subtitle "الإجمالي الحالي:"
    expect(find.text('الإجمالي الحالي:'), findsOneWidget);
    // - Total Price "76 ج.م" (Panadol 45 + Congestal 31 = 76)
    expect(find.text('76 ج.م'), findsOneWidget);
    // - Button "عرض السلة وإتمام الطلب"
    expect(find.text('عرض السلة وإتمام الطلب'), findsOneWidget);

    // 8. Test Interaction: Tapping "عرض السلة وإتمام الطلب" opens Cart Bottom Sheet
    await tester.tap(find.text('عرض السلة وإتمام الطلب'));
    await tester.pumpAndSettle();

    expect(find.text('سلة المشتريات'), findsOneWidget);
    expect(find.text('2 أصناف'), findsOneWidget);
    expect(find.textContaining('متابعة'), findsOneWidget);
  });

  testWidgets('PharmacyDetailsScreen search filters items and shows empty state', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockPharmacyDetailsRepository();
    tester.view.physicalSize = const Size(390 * 2.0, 1200 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      mockRepo.dispose();
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
        home: PharmacyDetailsScreen(
          pharmacyId: 'pharmacy_al_nour',
          repository: mockRepo,
          preloadCartForDemo: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Search for "Panadol"
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Panadol');
    await tester.pumpAndSettle();

    expect(find.text('Panadol Extra'), findsOneWidget);
    expect(find.text('Congestal Tablets'), findsNothing);

    // Search for nonexistent medicine
    await tester.enterText(searchField, 'NonExistentMedicine123');
    await tester.pumpAndSettle();

    expect(find.textContaining('لا توجد أدوية مطابقة للبحث'), findsOneWidget);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    expect(find.text('Panadol Extra'), findsOneWidget);
    expect(find.text('Congestal Tablets'), findsOneWidget);
  });

  testWidgets('MedicineCardWidget disables button and shows out-of-stock badge when quantity is 0', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    final outOfStockItem = PharmacyInventoryItemModel(
      id: 'inv_out',
      pharmacyId: 'pharmacy_al_nour',
      medicineId: 'med_1',
      name: 'Panadol Extra',
      genericName: 'باراسيتامول',
      description: 'مسكن',
      category: 'مسكنات',
      price: 45.0,
      quantity: 0,
      unitDescription: '24 قرص',
      isAvailable: false,
      publicVisible: true,
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MedicineCardWidget(
            item: outOfStockItem,
            onAddToCart: () => tapped = true,
          ),
        ),
      ),
    );

    // Stock badge shows 'غير متوفر'
    expect(find.text('غير متوفر'), findsOneWidget);

    // Tapping the + icon does nothing
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(tapped, false);
  });
}
