import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:koliber_lux/core/auth_provider.dart';
import 'package:koliber_lux/features/home/user_provider.dart'; // Import Twojego providera

// Importy ekranów
import 'admin_panel.dart'; 
import 'history_screen.dart';
import '../rewards/rewards_screen.dart';
import '../rewards/my_rewards_screen.dart'; // Nowy ekran z kodami QR nagród
import '../profile/profile_screen.dart';
import '../locations/locations_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Słuchamy stanu użytkownika z Providera (Punkty + Historia)
    final userState = ref.watch(userProvider);
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isAdmin = user.email == 'kontakt@koliberlux.pl';
    
    // Liczymy aktywne prezenty do odebrania (status pending)
    final int pendingCount = userState.transactions
        .where((t) => t.isReward && t.status == 'pending')
        .length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'KOLIBER LUX',
          style: TextStyle(
            color: Colors.black, 
            letterSpacing: 6, 
            fontWeight: FontWeight.w300, 
            fontSize: 18
          ),
        ),
        centerTitle: true,
        leading: isAdmin
            ? IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const AdminPanel())
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black54),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "TWOJE PUNKTY", 
                  style: TextStyle(
                    color: Colors.black54, 
                    letterSpacing: 3, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 5),
                // Punkty pobierane bezpośrednio z userProvider
                Text(
                  "${userState.profile.points}", 
                  style: const TextStyle(fontSize: 84, fontWeight: FontWeight.w100, color: Colors.black87)
                ),
                const SizedBox(height: 30),
                
                // KARTA QR KLIENTA
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08), 
                        blurRadius: 30, 
                        offset: const Offset(0, 10)
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: user.uid,
                        version: QrVersions.auto,
                        size: 180.0,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "ID KLIENTA PREMIUM", 
                        style: TextStyle(letterSpacing: 2, fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // MENU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // NOWY PRZYCISK: MOJE PREZENTY (Z LICZNIKIEM)
                      _buildMenuOption(
                        icon: Icons.card_giftcard_outlined,
                        title: "MOJE PREZENTY",
                        badgeCount: pendingCount, // Pokazuje ile nagród czeka
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const MyRewardsScreen())
                        ),
                      ),
                      _buildMenuOption(
                        icon: Icons.shopping_bag_outlined,
                        title: "SKLEP Z NAGRODAMI",
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const RewardsScreen())
                        ),
                      ),
                      _buildMenuOption(
                        icon: Icons.history_outlined,
                        title: "HISTORIA PUNKTÓW",
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const HistoryScreen())
                        ),
                      ),
                      _buildMenuOption(
                        icon: Icons.person_outline,
                        title: "MÓJ PROFIL",
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const ProfileScreen())
                        ),
                      ),
                      _buildMenuOption(
                        icon: Icons.storefront_outlined,
                        title: "NASZE SALONY",
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const LocationsScreen())
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(15)
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black87, size: 22),
        title: Text(
          title, 
          style: const TextStyle(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w400, color: Colors.black87)
        ),
        trailing: SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  child: Text(
                    "$badgeCount", 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}