import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:depi_final_project/core/routing/app_router.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:depi_final_project/features/customer/cart/logic/cubits/customer_cart_cubit.dart';
import 'package:depi_final_project/features/customer/orders/data/repositories/firebase_customer_order_repository.dart';
import 'package:depi_final_project/features/customer/orders/logic/cubits/customer_orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MosaedApp extends StatelessWidget {
  final CustomerCartCubit? cartCubit;
  final CustomerOrdersCubit? ordersCubit;

  const MosaedApp({super.key, this.cartCubit, this.ordersCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => cartCubit ?? CustomerCartCubit(),
        ),
        BlocProvider(
          create: (context) =>
              ordersCubit ??
              (CustomerOrdersCubit(
                repository: FirebaseCustomerOrderRepository(),
              )..loadInitialData()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        // Application Theme
        theme: AppTheme.lightTheme,

        // Language
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],

        // Localization Delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Navigation
        routerConfig: AppRouter.router,
      ),
    );
  }
}
