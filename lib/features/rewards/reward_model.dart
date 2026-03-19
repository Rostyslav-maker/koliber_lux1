enum RewardCategory { jewelry, cosmetics }

class Reward {
  final String id;
  final String title;
  final int cost;
  final String imageUrl;
  final RewardCategory category;

  Reward({
    required this.id,
    required this.title,
    required this.cost,
    required this.imageUrl,
    required this.category,
  });
}