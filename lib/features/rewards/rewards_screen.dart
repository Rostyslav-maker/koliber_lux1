import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koliber_lux/features/home/user_provider.dart';
import 'reward_model.dart'; // Upewnij się, że klasa w środku to 'Reward'
import 'rewards_provider.dart';
import 'success_screen.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Słuchamy punktów użytkownika
    final userData = ref.watch(userProvider);
    final userPoints = userData.profile.points;
    
    // Słuchamy listy nagród (Traktujemy jako List<Reward>, nie AsyncValue)
    final List<Reward> rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "NAGRODY",
          style: TextStyle(color: Colors.black, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // PANEL PUNKTÓW
          _buildPointsHeader(userPoints),

          // LISTA NAGRÓD
          Expanded(
            child: rewards.isEmpty
                ? const Center(child: Text("Brak dostępnych nagród"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final bool canAfford = userPoints >= reward.cost;

                      return _buildRewardCard(context, ref, reward, canAfford);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHeader(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "TWOJE PUNKTY",
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            "$points",
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, WidgetRef ref, Reward reward, bool canAfford) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.redeem, color: Colors.amber),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${reward.cost} pkt",
                  style: TextStyle(
                    color: canAfford ? Colors.amber : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // PRZYCISK ODBIERZ (Poprawiony: async/await + rewardTitle)
          ElevatedButton(
            onPressed: canAfford 
              ? () async {
                  final bool success = await ref.read(userProvider.notifier).redeemPoints(
                    reward.cost, 
                    reward.title
                  );

                  if (success && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessScreen(rewardTitle: reward.title),
                      ),
                    );
                  }
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey.shade200,
            ),
            child: const Text("ODBIERZ"),
          ),
        ],
      ),
    );
  }
}