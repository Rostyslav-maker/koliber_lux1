import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koliber_lux/features/home/user_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    final transactions = userData.transactions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "HISTORIA PUNKTÓW",
          style: TextStyle(color: Colors.black, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text("Brak historii transakcji"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                
                // Proste formatowanie daty bez biblioteki intl
                final String dateStr = "${tx.date.day.toString().padLeft(2, '0')}.${tx.date.month.toString().padLeft(2, '0')}.${tx.date.year}";
                final bool isMinus = tx.isReward; 

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMinus 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.amber.withOpacity(0.1),
                      child: Icon(
                        isMinus ? Icons.remove : Icons.add,
                        color: isMinus ? Colors.redAccent : Colors.amber,
                      ),
                    ),
                    title: Text(
                      tx.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: Text(
                      "${isMinus ? '-' : '+'}${tx.points} pkt",
                      style: TextStyle(
                        color: isMinus ? Colors.redAccent : Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}