import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Ważne dla obsługi Chrome
import 'package:koliber_lux/core/auth_provider.dart';
import 'package:koliber_lux/features/auth/login_screen.dart';
import 'package:koliber_lux/features/home/home_screen.dart';

// Opcje Firebase (wymagane szczególnie dla Chrome/Web)
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyC98WNJ4SRwEeN_BrxnwkshUpgTxx29T-U",
  appId: "1:521923515909:android:0577f88f28b29e0032e6c", 
  messagingSenderId: "521923515909",
  projectId: "lojalnosc-app",
  storageBucket: "lojalnosc-app.firebasestorage.app",
  authDomain: "lojalnosc-app.firebaseapp.com",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // W przeglądarce Chrome musimy podać opcje jawnie
      await Firebase.initializeApp(options: firebaseOptions);
      print("Firebase zainicjalizowane w Chrome.");
    } else {
      // Na Androidzie korzystamy z pliku google-services.json (już go skonfigurowaliśmy)
      await Firebase.initializeApp();
      print("Firebase zainicjalizowane na Androidzie.");
    }
  } catch (e) {
    print("BŁĄD FIREBASE: $e");
  }

  runApp(
    const ProviderScope(
      child: KoliberLuxApp(),
    ),
  );
}

class KoliberLuxApp extends ConsumerWidget {
  const KoliberLuxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Koliber Lux',
      debugShowCheckedModeBanner: false,
      
      // --- LUKSUSOWY CIEMNY MOTYW (BLACK & GOLD) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Kolorystyka
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
          surface: Colors.black,       // Głęboka czerń kart i tła
          primary: Colors.amber,       // Złote akcenty (przyciski, ikony)
          onPrimary: Colors.black,     // Czarny tekst na złotym tle
          secondary: Colors.amberAccent,
        ),
        
        scaffoldBackgroundColor: Colors.black, // Prawdziwa czerń tła aplikacji
        
        // Wygląd AppBar (Paska górnego)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          centerTitle: true,
          elevation: 0,
        ),

        // Wygląd przycisków
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),

        // Wygląd pól tekstowych (Inputów)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.amber, width: 2),
          ),
        ),
      ),
      
      // Logika wyboru ekranu startowego
      home: authState.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}