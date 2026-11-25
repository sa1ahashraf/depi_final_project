import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:depi_final_project/core/enums/medicine_form.dart';
import 'package:depi_final_project/core/enums/order_status.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/cart/presentation/screens/customer_cart_screen.dart';
import 'package:depi_final_project/features/customer/orders/data/repositories/firebase_customer_order_repository.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:depi_final_project/features/customer/orders/presentation/screens/customer_orders_screen.dart';
import 'package:depi_final_project/features/customer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_detail_model.dart';
import 'package:depi_final_project/features/customer/pharmacy_details/data/models/pharmacy_inventory_item_model.dart';

void main() {
  final now = DateTime(2026, 11, 25, 14, 0);

  final pharmacy = PharmacyDetailModel(
    id: 'pharmacy_al_nour',
    name: 'صيدلية النور',
    address: 'شارع النصر، المعادي',
    rating: 4.8,
    distanceKm: 0.8,
    isOpen: true,
    isVerified: true,
    deliveryTime: '20-30 دقيقة',
    paymentMethods: const ['دفع عند الاستلام'],
    createdAt: now,
    updatedAt: now,
  );

  final medicine = PharmacyInventoryItemModel(
    id: 'pharmacy_al_nour_inv_1',
    pharmacyId: 'pharmacy_al_nour',
    medicineId: 'med_1',
    name: 'Panadol Extra',
    genericName: 'باراسيتامول',
    description: 'مسكن للصداع',
    category: 'مسكنات وحرارة',
    price: 45.0,
    quantity: 10,
    unitDescription: '24 قرص',
    form: MedicineForm.tablet,
    isAvailable: true,
    publicVisible: true,
    updatedAt: now,
  );

  Widget wrapWithProviders({
    required Widget child,
    required CustomerCartCubit cartCubit,
    required CustomerOrdersCubit ordersCubit,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cartCubit),
        BlocProvider.value(value: ordersCubit),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  testWidgets('CustomerCartScreen completes order and navigates to OrderTrackingScreen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 900 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    final repo = FirebaseCustomerOrderRepository(
      customerIdOverride: 'widget_customer',
      enableFirestoreSync: false,
      seedDemoData: true,
    );
    final ordersCubit = CustomerOrdersCubit(repository: repo);
    final cartCubit = CustomerCartCubit();
    await ordersCubit.loadInitialData();

    cartCubit.addToCart(medicine, pharmacy);

    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await ordersCubit.close();
      await cartCubit.close();
      repo.dispose();
    });

    await tester.pumpWidget(
      wrapWithProviders(
        child: const CustomerCartScreen(),
        cartCubit: cartCubit,
        ordersCubit: ordersCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('سلة المشتريات والدفع'), findsOneWidget);
    expect(find.text('Panadol Extra'), findsOneWidget);
    expect(find.text('عنوان التوصيل'), findsOneWidget);
    expect(find.textContaining('تأكيد وإرسال الطلب'), findsOneWidget);

    await tester.tap(find.textContaining('تأكيد وإرسال الطلب'));
    await tester.pumpAndSettle();

    // Should navigate to OrderTrackingScreen with the created pending order
    expect(find.byType(OrderTrackingScreen), findsOneWidget);
    expect(find.text('مراحل تتبع الطلب'), findsOneWidget);
    expect(find.text('بانتظار موافقة الصيدلية'), findsWidgets);
    expect(cartCubit.state.isEmpty, true);
  });

  testWidgets('CustomerOrdersScreen filters orders and live-updates tracking timeline', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 900 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    final repo = FirebaseCustomerOrderRepository(
      customerIdOverride: 'widget_customer',
      enableFirestoreSync: false,
      seedDemoData: true,
    );
    final ordersCubit = CustomerOrdersCubit(repository: repo);
    final cartCubit = CustomerCartCubit();
    await ordersCubit.loadInitialData();

    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await ordersCubit.close();
      await cartCubit.close();
      repo.dispose();
    });

    await tester.pumpWidget(
      wrapWithProviders(
        child: const CustomerOrdersScreen(),
        cartCubit: cartCubit,
        ordersCubit: ordersCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('طلباتي وسجل الطلبات'), findsOneWidget);
    // Seeded active & completed orders are visible
    expect(find.text('صيدلية النور'), findsOneWidget);
    expect(find.text('صيدلية الأمل الحديثة'), findsOneWidget);

    // Filter to completed only
    await tester.tap(find.text('المكتملة'));
    await tester.pumpAndSettle();
    expect(find.text('صيدلية الأمل الحديثة'), findsOneWidget);
    expect(find.text('صيدلية النور'), findsNothing);

    // Back to active and open live tracking
    await tester.tap(find.text('النشطة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تتبع الطلب'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderTrackingScreen), findsOneWidget);
    expect(find.text('جاري تحضير الأدوية'), findsWidgets);

    // Simulate pharmacy marking order ready in real time
    repo.updateLocalOrderStatus('ORD-20261125-01', OrderStatus.ready);
    await tester.pumpAndSettle();
    expect(find.text('جاهز للتوصيل'), findsWidgets);

    // Simulate rejection with reason
    repo.updateLocalOrderStatus(
      'ORD-20261125-01',
      OrderStatus.rejected,
      rejectionReason: 'نقص في أحد الأصناف المطلوبة',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('نقص في أحد الأصناف المطلوبة'), findsOneWidget);
  });
}
