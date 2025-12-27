import 'package:appfast/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
// Screens
import 'screens/screens.dart';
// Services
import 'services/services.dart';
// State
import 'state/state.dart';
// Utils
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  // 🔧 CONFIGURACIÓN DE EMULADORES PARA DESARROLLO LOCAL
  // Auth usa producción (Google Sign-In requiere OAuth real)
  // Firestore y Functions en local para ver datos en tiempo real

  // ❌ Auth Emulator desactivado - usar producción para Google Sign-In
  // await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9199);

  // ✅ Firestore Emulator - Puerto 8180 (verificado en emulator output)
  // Usar 10.0.2.2 para emulador Android (apunta al localhost de la PC host)
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8180);

  // ✅ Functions Emulator - Puerto 5101 (verificado en emulator output)
  FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5101);

  debugPrint('🔥 Firebase emulators configured for Android Emulator:');
  debugPrint('   Firestore: 10.0.2.2:8180');
  debugPrint('   Functions: 10.0.2.2:5101');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: 'Shared Grocery Budget',
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          locale: appProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('es'), // Spanish
          ],
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

Future<void> initServices() async {
  // Configurar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar Superwall
  final superwallService = SuperwallService();
  superwallService.configure();

  // Configurar AppsFlyer
  final appsflyerService = AppsFlyerService();
  await appsflyerService.initAppsFlyer();
}
