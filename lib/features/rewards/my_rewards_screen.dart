import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:koliber_lux/features/home/user_provider.dart';

class MyRewardsScreen extends ConsumerWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    // Filtrujemy tylko nagrody (isReward), które czekają na odbiór (status 'pending')
    final pendingRewards = userState.transactions.where((t) {
      return t.isReward && t.status == 'pending';
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "MOJE PREZENTY", 
          style: TextStyle(color: Colors.amber, letterSpacing: 3, fontSize: 14, fontWeight: FontWeight.w300)
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: pendingRewards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 20),
                  const Text(
                    "NIE MASZ ŻADNYCH\nAKTYWNYCH PREZENTÓW",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, letterSpacing: 2, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: pendingRewards.length,
              itemBuilder: (context, index) {
                final reward = pendingRewards[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: Colors.amber,
                      collapsedIconColor: Colors.white38,
                      title: Text(
                        reward.title.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                      ),
                      subtitle: const Text(
                        "KLIKNIJ, ABY POKAZAĆ KOD QR",
                        style: TextStyle(color: Colors.amber, fontSize: 9, letterSpacing: 1),
                      ),
                      leading: const Icon(Icons.qr_code_2, color: Colors.amber),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "POKAŻ TEN KOD SPRZEDAWCY",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                              ),
                              const SizedBox(height: 20),
                              QrImageView(
                                // Dane dla skanera admina: REWARD|ID_TRANSAKCJI|ID_USERA
                                data: "REWARD|${reward.id}|${userState.profile.id}",
                                version: QrVersions.auto,
                                size: 200.0,
                                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "KOD NAGRODY: ${reward.id.substring(0, 8).toUpperCase()}",
                                style: const TextStyle(color: Colors.grey, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}