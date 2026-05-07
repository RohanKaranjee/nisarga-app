class Doctor {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final double rating;
  final int reviews;
  final String location;
  final String photo;
  final String about;
  final String clinic;
  final List<Map<String, String>> availability;
  final List<String> qualifications;
  final List<String> articles;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.photo,
    required this.about,
    required this.clinic,
    required this.availability,
    required this.qualifications,
    required this.articles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'reviews': reviews,
      'location': location,
      'photo': photo,
      'about': about,
      'clinic': clinic,
      'availability': availability,
      'qualifications': qualifications,
      'articles': articles,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews']?.toInt() ?? 0,
      location: map['location'] ?? '',
      photo: map['photo'] ?? '',
      about: map['about'] ?? '',
      clinic: map['clinic'] ?? '',
      availability: List<Map<String, String>>.from(
          map['availability']?.map((x) => Map<String, String>.from(x)) ?? []),
      qualifications: List<String>.from(map['qualifications'] ?? []),
      articles: List<String>.from(map['articles'] ?? []),
    );
  }
}
