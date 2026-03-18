import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final int points;
  final DateTime date;
  final bool isReward;
  final String? status; // 'pending' dla nagród do odbioru, 'claimed' dla wydanych

  Transaction({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    this.isReward = false,
    this.status,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['date'] ?? Timestamp.now();

    return Transaction(
      id: doc.id,
      title: data['title'] ?? 'Transakcja',
      points: data['points'] ?? 0,
      date: timestamp.toDate(),
      status: data['status'], // Pobieramy status z bazy
      isReward: data['type'] == 'reward' || (data['points'] != null && data['points'] < 0),
    );
  }
}