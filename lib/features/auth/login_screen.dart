import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koliber_lux/core/auth_provider.dart';
import 'package:koliber_lux/features/auth/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // LOGO / TYTUŁ
              const Icon(Icons.star_outline, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'KOLIBER LUX',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2),
              ),
              const Text('Ekskluzywny program lojalnościowy', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),

              // POLA TEKSTOWE
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.amber),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.amber)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.amber, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  labelStyle: const TextStyle(color: Colors.amber),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.amber)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.amber, width: 2)),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // PRZYCISK ZALOGUJ (EMAIL)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : () => ref.read(authProvider.notifier).login(_emailController.text.trim(), _passwordController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  child: authState.isLoading ? const CircularProgressIndicator() : const Text('ZALOGUJ SIĘ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 25),
              const Text("LUB ZALOGUJ PRZEZ", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 25),

              // PRZYCISKI SPOŁECZNOŚCIOWE
              Row(
                children: [
                  // GOOGLE
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                      label: const Text("Google", style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // APPLE
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(authProvider.notifier).signInWithApple(),
                      icon: const Icon(Icons.apple, size: 24, color: Colors.white),
                      label: const Text("Apple", style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text("Nie masz konta? Dołącz do nas", style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}