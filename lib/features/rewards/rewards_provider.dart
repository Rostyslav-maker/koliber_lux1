import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reward_model.dart';

final rewardsProvider = Provider<List<Reward>>((ref) {
  return [
    Reward(
      id: '1',
      title: 'Złoty Naszyjnik Koliber',
      cost: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=300&auto=format&fit=crop',
      category: RewardCategory.jewelry,
    ),
    Reward(
      id: '2',
      title: 'Serum Rozświetlające Lux',
      cost: 1200,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=300&auto=format&fit=crop',
      category: RewardCategory.cosmetics,
    ),
    Reward(
      id: '3',
      title: 'Kolczyki z Topazem',
      cost: 3500,
      imageUrl: 'https://images.unsplash.com/photo-1635767798638-3e25273a8236?q=80&w=300&auto=format&fit=crop',
      category: RewardCategory.jewelry,
    ),
    Reward(
      id: '4',
      title: 'Pomadka Velvet Rose',
      cost: 800,
      imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?q=80&w=300&auto=format&fit=crop',
      category: RewardCategory.cosmetics,
    ),
  ];
});