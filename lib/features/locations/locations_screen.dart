import 'package:flutter/material.dart';
import 'package:koliber_lux/core/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  // Twoje dane salonu w Gdyni
  final List<Map<String, String>> salons = const [
    {
      'name': 'KOLIBER LUX - Gdynia',
      'address': 'ul. Morska 150/u4',
      'city': '81-225 Gdynia',
      'hours': 'PN-PT 10:00 - 18:00 SOB 10:00 - 14:00',
      'image': 'https://images.unsplash.com/photo-1773731461486-f1186a4c367e?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', 
      'mapUrl': 'https://www.google.com/maps/place/Koliber+Lux/@54.532902,18.4874669,17z/data=!3m1!4b1!4m6!3m5!1s0x46fda764d3a5699f:0xa10860f629c39efc!8m2!3d54.532902!4d18.4900418!16s%2Fg%2F11ygk3x5bk?authuser=0&entry=ttu&g_ep=EgoyMDI2MDMxNS4wIKXMDSoASAFQAw%3D%3D',
    },
  ];

  Future<void> _launchMap(String url) async {
    final Uri uri = Uri.parse(url);
    // Na Chrome/Web musimy użyć mode: LaunchMode.externalApplication
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Nie można otworzyć mapy: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NASZE SALONY")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: salons.length,
        itemBuilder: (context, index) {
          final salon = salons[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 24), // POPRAWIONE: EdgeInsets.only
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(salon['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon['name']!, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.white54),
                          const SizedBox(width: 8),
                          // Expanded zapobiega błędom renderowania przy długim adresie
                          Expanded(
                            child: Text(
                              "${salon['address']}, ${salon['city']}", 
                              style: const TextStyle(color: Colors.white70)
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.white54),
                          const SizedBox(width: 8),
                          Text(salon['hours']!, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryGold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () => _launchMap(salon['mapUrl']!),
                          child: const Text(
                            "PROWADŹ DO SALONU", 
                            style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}