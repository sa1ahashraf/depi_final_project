import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:depi_final_project/core/widgets/splash/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      _route(AppRoutes.auth, 'auth', 'الدخول والتسجيل'),
      _route(AppRoutes.login, 'login', 'تسجيل الدخول'),
      _route(AppRoutes.register, 'register', 'إنشاء حساب'),
      _route(AppRoutes.customerHome, 'customer-home', 'الرئيسية'),
      _route(
        AppRoutes.pharmacyDiscovery,
        'pharmacy-discovery',
        'اكتشاف الصيدليات',
      ),
      _route(AppRoutes.medicineSearch, 'medicine-search', 'البحث عن دواء'),
      _route(AppRoutes.medicineDetails, 'medicine-details', 'تفاصيل الدواء'),
      _route(AppRoutes.cart, 'cart', 'السلة والدفع'),
      _route(AppRoutes.customerOrders, 'customer-orders', 'طلباتي'),
      _route(AppRoutes.customerProfile, 'customer-profile', 'حسابي'),
      _route(AppRoutes.pharmacyHome, 'pharmacy-home', 'لوحة الصيدلية'),
      _route(AppRoutes.inventory, 'inventory', 'المخزون'),
      _route(AppRoutes.inventoryItem, 'inventory-item', 'عنصر المخزون'),
      _route(AppRoutes.pharmacyOrders, 'pharmacy-orders', 'طلبات الصيدلية'),
      _route(AppRoutes.pharmacyProfile, 'pharmacy-profile', 'بيانات الصيدلية'),
    ],
    errorBuilder: (context, state) => _RoutePlaceholder(
      title: 'الصفحة غير موجودة',
      message: state.uri.toString(),
    ),
  );

  static GoRoute _route(String path, String name, String title) {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) => _RoutePlaceholder(title: title),
    );
  }
}

abstract final class AppRoutes {
  static const splashName = 'splash';
  static const auth = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const customerHome = '/customer';
  static const pharmacyDiscovery = '/customer/pharmacies';
  static const medicineSearch = '/customer/medicines';
  static const medicineDetails = '/customer/medicines/:medicineId';
  static const cart = '/customer/cart';
  static const customerOrders = '/customer/orders';
  static const customerProfile = '/customer/profile';
  static const pharmacyHome = '/pharmacy';
  static const inventory = '/pharmacy/inventory';
  static const inventoryItem = '/pharmacy/inventory/item/:itemId';
  static const pharmacyOrders = '/pharmacy/orders';
  static const pharmacyProfile = '/pharmacy/profile';
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(message ?? 'سيتم ربط هذه الشاشة بميزة الفريق المختصة.'),
      ),
    );
  }
}
