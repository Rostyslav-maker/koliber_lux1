import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:koliber_lux/core/theme.dart';

class SuccessScreen extends StatefulWidget {
  final String rewardTitle; // Tu musi być rewardTitle
  const SuccessScreen({super.key, required this.rewardTitle});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 120, color: AppTheme.primaryGold),
                  const SizedBox(height: 32),
                  const Text(
                    "GRATULACJE!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Właśnie odebrałeś nagrodę:\n${widget.rewardTitle}", // Tutaj też zmiana na rewardTitle
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("WRÓĆ DO SKLEPU", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [AppTheme.primaryGold, Colors.white, Colors.orange],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }
}