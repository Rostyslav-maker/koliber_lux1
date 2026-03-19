class Promo {
  final String title;
  final String imageUrl;
  final String tag;

  Promo({required this.title, required this.imageUrl, required this.tag});
}

// Przykładowe dane (wymiary 2:1, np. 1200x600 px)
final List<Promo> promoList = [
  Promo(
    title: "Zabieg Kolagenowy -20%",
    tag: "PROMOCJA",
    imageUrl: "https://images.unsplash.com/photo-1570172619382-1104d7159ed2?q=80&w=1200&auto=format&fit=crop",
  ),
  Promo(
    title: "Nowa Linia Zapachów Lux",
    tag: "NOWOŚĆ",
    imageUrl: "https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=1200&auto=format&fit=crop",
  ),
  Promo(
    title: "Wieczór z Szampanem w Gdyni",
    tag: "WYDARZENIE",
    imageUrl: "https://images.unsplash.com/photo-1578911373434-0cb395d2cbfb?q=80&w=1200&auto=format&fit=crop",
  ),
];