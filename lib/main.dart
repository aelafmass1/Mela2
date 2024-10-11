import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/bloc/bank_fee/bank_fee_bloc.dart';
import 'package:transaction_mobile_app/bloc/banks/banks_bloc.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb_currencies/equb_currencies_bloc.dart';
import 'package:transaction_mobile_app/bloc/location/location_bloc.dart';
import 'package:transaction_mobile_app/bloc/currency/currency_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb_member/equb_member_bloc.dart';
import 'package:transaction_mobile_app/bloc/fee/fee_bloc.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/bloc/navigation/navigation_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_card/payment_card_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_intent/payment_intent_bloc.dart';
import 'package:transaction_mobile_app/bloc/pincode/pincode_bloc.dart';
import 'package:transaction_mobile_app/bloc/plaid/plaid_bloc.dart';
import 'package:transaction_mobile_app/bloc/transaction/transaction_bloc.dart';
import 'package:transaction_mobile_app/data/repository/banks_repository.dart';
import 'package:transaction_mobile_app/data/repository/contact_repository.dart';
import 'package:transaction_mobile_app/data/repository/currency_rate_repository.dart';
import 'package:transaction_mobile_app/data/repository/currency_repository.dart';
import 'package:transaction_mobile_app/data/repository/equb_repository.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';
import 'package:transaction_mobile_app/data/repository/money_transfer_repository.dart';
import 'package:transaction_mobile_app/data/repository/payment_card_repository.dart';
import 'package:transaction_mobile_app/data/repository/payment_intent_repository.dart';
import 'package:transaction_mobile_app/data/repository/plaid_repository.dart';
import 'package:transaction_mobile_app/data/repository/transaction_repository.dart';
import 'package:transaction_mobile_app/firebase_options.dart';

import 'bloc/bank_currency_rate/bank_currency_rate_bloc.dart';
import 'config/routing.dart';
import 'data/repository/auth_repository.dart';
import 'data/services/api/api_service.dart';

//main method
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Set the Stripe publishable key, which is necessary to identify your Stripe account.
  Stripe.publishableKey = dotenv.env['PUBLISHABLE_KEY']!;

  // Set the Stripe merchant identifier, which is required for Apple Pay integration.
  Stripe.merchantIdentifier = 'Mela Fi';

  // Apply Stripe settings to ensure the configuration is set up properly.
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics instance to track user interactions and app events.
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Enable analytics data collection and log an event for app open.
  await analytics.setAnalyticsCollectionEnabled(true);
  await analytics.logAppOpen();

  // Initialize Firebase Crashlytics instance to capture and report crash data.
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = crashlytics.recordFlutterError;

  /// Initialize Sentry for crash reporting and error tracking.
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://b3a58e9d555b70af3cdc4783b47a74ad@o4508032233308160.ingest.us.sentry.io/4508032245235712';

      // Set tracesSampleRate to 1.0 to capture 100% of transactions for trWacing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MainApp()),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  final client = ApiService().client;
  late AuthRepository authRepo;
  late BanksRepository banksRepository;
  late ContactRepository contactRepository;
  late CurrencyRateRepository currencyRateRepository;
  late CurrencyRepository currencyRepository;
  late EqubRepository equbRepository;
  late FeeRepository feeRepository;
  late MoneyTransferRepository moneyTransferRepository;
  late PaymentCardRepository paymentCardRepository;
  late PaymentIntentRepository paymentIntentRepository;
  late PlaidRepository plaidRepository;
  late TransactionRepository transactionRepository;

  @override
  void initState() {
    authRepo = AuthRepository(client: client);
    banksRepository = BanksRepository(client: client);
    contactRepository = ContactRepository(client: client);
    currencyRateRepository = CurrencyRateRepository(client: client);
    currencyRepository = CurrencyRepository(client: client);
    equbRepository = EqubRepository(client: client);
    feeRepository = FeeRepository(client: client);
    moneyTransferRepository = MoneyTransferRepository(client: client);
    paymentCardRepository = PaymentCardRepository(client: client);
    paymentIntentRepository = PaymentIntentRepository(client: client);
    plaidRepository = PlaidRepository(client: client);
    transactionRepository = TransactionRepository(client: client);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BankCurrencyRateBloc(
            repository: currencyRateRepository,
          ),
        ),
        BlocProvider(
          create: (context) => EqubBloc(repository: equbRepository),
        ),
        BlocProvider(
          create: (context) => AuthBloc(repository: authRepo),
        ),
        BlocProvider(
          create: (context) =>
              TransactionBloc(repository: transactionRepository),
        ),
        BlocProvider(
          create: (context) =>
              MoneyTransferBloc(repository: moneyTransferRepository),
        ),
        BlocProvider(
          create: (context) => CurrencyBloc(
            repository: currencyRepository,
          ),
        ),
        BlocProvider(
          create: (context) => NavigationBloc(
            tabController: TabController(length: 5, vsync: this),
          ),
        ),
        BlocProvider(
          create: (context) => PaymentIntentBloc(
            repository: paymentIntentRepository,
          ),
        ),
        BlocProvider(
          create: (context) => PaymentCardBloc(
            repository: paymentCardRepository,
          ),
        ),
        BlocProvider(
          create: (context) => FeeBloc(
            feeRepository: feeRepository,
          ),
        ),
        BlocProvider(
          create: (context) => PlaidBloc(
            repository: plaidRepository,
          ),
        ),
        BlocProvider(
          create: (context) => PincodeBloc(
            repository: authRepo,
          ),
        ),
        BlocProvider(
          create: (context) => BanksBloc(
            repository: banksRepository,
          ),
        ),
        BlocProvider(
          create: (context) => BankFeeBloc(
            repository: banksRepository,
          ),
        ),
        BlocProvider(
          create: (context) => ContactBloc(
            repository: contactRepository,
          ),
        ),
        BlocProvider(
          create: (context) => EqubMemberBloc(
            repository: equbRepository,
          ),
        ),
        BlocProvider(
          create: (context) => EqubCurrenciesBloc(
            repository: equbRepository,
          ),
        ),
        BlocProvider(
          create: (context) => LocationBloc(),
        ),
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
