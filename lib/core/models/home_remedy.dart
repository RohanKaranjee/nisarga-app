class HomeRemedy {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> ingredients;
  final String preparation;
  final String benefits;
  final String precautions;
  final bool active;

  const HomeRemedy({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.ingredients = const [],
    this.preparation = '',
    this.benefits = '',
    this.precautions = '',
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'preparation': preparation,
      'benefits': benefits,
      'precautions': precautions,
      'active': active,
    };
  }

  factory HomeRemedy.fromMap(Map<String, dynamic> map) {
    return HomeRemedy(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      preparation: map['preparation'] ?? '',
      benefits: map['benefits'] ?? '',
      precautions: map['precautions'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
