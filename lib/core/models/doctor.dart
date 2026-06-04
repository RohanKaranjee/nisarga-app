class Doctor {
  final String id;
  final String userId;
  final String name;
  final String specialization;
  final int experience;
  final double rating;
  final int reviews;
  final String location;
  final String photo;
  final String photoUrl;
  final String about;
  final String clinic;
  final String fee;
  final String status;
  final List<Map<String, String>> availability;
  final List<String> qualifications;
  final List<String> articles;
  final bool active;

  Doctor({
    required this.id,
    this.userId = '',
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.photo,
    this.photoUrl = '',
    required this.about,
    required this.clinic,
    this.fee = '',
    this.status = 'pending',
    required this.availability,
    required this.qualifications,
    required this.articles,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'reviews': reviews,
      'location': location,
      'photo': photo,
      'photoUrl': photoUrl,
      'about': about,
      'clinic': clinic,
      'fee': fee,
      'status': status,
      'availability': availability,
      'qualifications': qualifications,
      'articles': articles,
      'active': active,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews']?.toInt() ?? 0,
      location: map['location'] ?? '',
      photo: map['photo'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      about: map['about'] ?? '',
      clinic: map['clinic'] ?? '',
      fee: map['fee'] ?? '',
      status: map['status'] ?? 'pending',
      availability: List<Map<String, String>>.from(
          map['availability']?.map((x) => Map<String, String>.from(x)) ?? []),
      qualifications: List<String>.from(map['qualifications'] ?? []),
      articles: List<String>.from(map['articles'] ?? []),
      active: map['active'] ?? true,
    );
  }
}
