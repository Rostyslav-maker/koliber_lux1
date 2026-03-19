import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koliber_lux/features/home/user_provider.dart';
import 'package:koliber_lux/core/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Słuchamy danych o użytkowniku i stanie logowania
    final userData = ref.watch(userProvider);
    final profile = userData.profile;
    final authState = ref.watch(authProvider);

    // Wybieramy najlepsze dostępne imię
    // 1. Z bazy danych, 2. Z Google/Apple, 3. Domyślne
    final String displayName = profile.name.isNotEmpty 
        ? profile.name 
        : (authState.user?.displayName ?? "Klient Koliber Lux");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "MOJE KONTO",
          style: TextStyle(color: Colors.black, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- SEKACJA 1: PROFIL ---
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1A1A1A),
              child: Icon(Icons.person_outline, size: 50, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              profile.tier.toUpperCase(),
              style: const TextStyle(color: Colors.amber, letterSpacing: 2, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // --- SEKCJA 2: STATYSTYKI ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("PUNKTY", profile.points.toString()),
                  Container(width: 1, height: 40, color: Colors.white10),
                  _buildStatItem("ZAKUPY", userData.transactions.length.toString()),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- SEKCJA 3: MENU OPCJI ---
            _buildMenuOption(Icons.edit_outlined, "Edytuj imię", () {
              _showEditNameDialog(context, ref, displayName);
            }),
            
            _buildMenuOption(Icons.notifications_outlined, "Powiadomienia", () {
              _showInfoDialog(context, "POWIADOMIENIA", 
                "Twoje powiadomienia są aktywne. Będziemy Cię informować o nowych kolekcjach i nagrodach.");
            }),

            _buildMenuOption(Icons.security_outlined, "Polityka prywatności", () {
              _showInfoDialog(context, "PRYWATNOŚĆ", 
                "Twoje dane są przetwarzane zgodnie z RODO przez Koliber Lux. Dbamy o Twoje bezpieczeństwo.");
            }),
            
            const SizedBox(height: 20),
            
            // --- SEKCJA 4: WYLOGOWANIE ---
            ListTile(
              onTap: () => _showLogoutDialog(context, ref),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              tileColor: Colors.red.withOpacity(0.05),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Wyloguj się", 
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
            ),
            
            const SizedBox(height: 40),
            const Text(
              "Wersja 1.0.0 (Live)",
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcja pomocnicza dla statystyk (Punkty/Zakupy)
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
      ],
    );
  }

  // Funkcja pomocnicza dla elementów listy menu
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
    );
  }

  // DIALOG: Edycja Imienia
  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Zmień imię"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Wpisz jak mamy się do Ciebie zwracać"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANULUJ")),
          ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).updateName(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Imię zostało zaktualizowane")),
              );
            },
            child: const Text("ZAPISZ"),
          ),
        ],
      ),
    );
  }

  // DIALOG: Informacyjny (Prywatność/Powiadomienia)
  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ROZUMIEM")),
        ],
      ),
    );
  }

  // DIALOG: Wylogowanie
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Czy chcesz się wylogować?"),
        content: const Text("Będziesz musiał zalogować się ponownie, aby korzystać z karty klienta."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANULUJ")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Zamyka okno dialogowe
              await ref.read(authProvider.notifier).logout();
              
              // Powrót do ekranu logowania i wyczyszczenie historii nawigacji
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text("WYLOGUJ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}