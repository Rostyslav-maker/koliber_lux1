import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Stan autoryzacji używany przez UI aplikacji
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  AuthState({
    required this.isLoggedIn,
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

/// Kontroler logiki autoryzacji zoptymalizowany pod Flutter Web
class AuthNotifier extends StateNotifier<AuthState> {
  // Twoje Client ID zostało zachowane. 
  // Dodano scopes, aby wymusić na Google przekazanie danych profilowych na Webie.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? '521923515909-jt5ubk3ddlaid6foqhp1g11rdtfg8dl3.apps.googleusercontent.com' 
        : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid',
    ],
  );

  AuthNotifier() : super(AuthState(isLoggedIn: false)) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        state = state.copyWith(
          isLoggedIn: user != null,
          user: user,
          isLoading: false,
        );
      }
    });
  }

  // --- LOGOWANIE E-MAIL ---
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  // --- REJESTRACJA ---
  Future<bool> register(String email, String password, [String? name]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    }
  }

  // --- LOGOWANIE GOOGLE ---
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Wywołanie okna logowania Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. Pobranie danych autentykacji (tokenów)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Przygotowanie poświadczenia dla Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Logowanie do Firebase i aktualizacja stanu
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print("🎉 Sukces: Zalogowano użytkownika: ${userCredential.user!.email}");
      }
      
    } catch (e) {
      print("❌ Błąd logowania Google: $e");
      state = state.copyWith(
        isLoading: false, 
        errorMessage: "Błąd Google: Sprawdź połączenie i autoryzację localhost w Firebase."
      );
    }
  }

  // --- LOGOWANIE APPLE ---
  Future<void> signInWithApple() async {
    state = state.copyWith(
      errorMessage: "Logowanie Apple jest obecnie niedostępne."
    );
  }

  // --- WYLOGOWANIE ---
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
    state = AuthState(isLoggedIn: false);
  }
}

/// Globalny provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});