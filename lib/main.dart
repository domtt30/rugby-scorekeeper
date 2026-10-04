import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(RugbyScorekeeperApp(storage: storage));
}

class RugbyScorekeeperApp extends StatelessWidget {
  final StorageService storage;
  const RugbyScorekeeperApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Rugby Scorekeeper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF102A43)),
          scaffoldBackgroundColor: const Color(0xFFF1F4F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF102A43),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        home: HomeScreen(storage: storage),
      );
}
