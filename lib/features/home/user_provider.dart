import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firebase;
import 'package:koliber_lux/core/auth_provider.dart';
import 'transaction_model.dart'; 

class UserProfile {
  final String id; // Dodajemy ID profilu
  final String name;
  final int points;
  final String tier;

  UserProfile({required this.id, required this.name, required this.points, required this.tier});
}

class UserState {
  final UserProfile profile;
  final List<Transaction> transactions; 

  UserState({required this.profile, required this.transactions});
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(UserState(
    profile: UserProfile(id: '', name: '', points: 0, tier: 'Standard'),
    transactions: [],
  )) {
    _init();
  }

  void _init() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user != null) {
      // 1. SŁUCHANIE PROFILU
      firebase.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          state = UserState(
            profile: UserProfile(
              id: user.uid,
              name: data['name'] ?? '',
              points: data['points'] ?? 0,
              tier: data['tier'] ?? 'Standard',
            ),
            transactions: state.transactions,
          );
        }
      });

      // 2. SŁUCHANIE HISTORII (W TYM NAGRÓD)
      firebase.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        final transList = snapshot.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList();
        
        state = UserState(
          profile: state.profile,
          transactions: transList,
        );
      });
    }
  }

  // ODBIERANIE NAGRODY Z STATUSSEM 'PENDING'
  Future<bool> redeemPoints(int cost, String rewardTitle) async {
    final user = ref.read(authProvider).user;
    if (user == null) return false;

    final db = firebase.FirebaseFirestore.instance; 
    final userRef = db.collection('users').doc(user.uid);
    final historyRef = userRef.collection('history').doc(); 

    try {
      await db.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentPoints = userDoc.data()?['points'] ?? 0;

        if (currentPoints >= cost) {
          transaction.update(userRef, {
            'points': firebase.FieldValue.increment(-cost),
          });

          transaction.set(historyRef, {
            'title': rewardTitle,
            'points': -cost,
            'date': firebase.FieldValue.serverTimestamp(),
            'type': 'reward',
            'status': 'pending', // <--- TO JEST KLUCZOWE
          });
        } else {
          throw Exception("Brak punktów");
        }
      });
      return true;
    } catch (e) {
      print("BŁĄD REDEEM: $e");
      return false;
    }
  }

  Future<void> updateName(String newName) async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      await firebase.FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});