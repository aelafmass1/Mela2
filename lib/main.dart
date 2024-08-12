import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'bloc/currency_rate/currency_rate_bloc.dart';
import 'config/routing.dart';

void main() {
  runApp(
    DevicePreview(enabled: false, builder: (_) => const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CurrencyRateBloc(),
        ),
        //
      ],
      child: ResponsiveApp(
        builder: (_) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: goRouting,
        ),
      ),
    );
  }
}