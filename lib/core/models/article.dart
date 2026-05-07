class Article {
  final String id;
  final String title;
  final String author;
  final String readTime;
  final String category;
  final String excerpt;
  final String date;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.readTime,
    required this.category,
    required this.excerpt,
    required this.date,
    this.content = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'readTime': readTime,
      'category': category,
      'excerpt': excerpt,
      'date': date,
      'content': content,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      readTime: map['readTime'] ?? '',
      category: map['category'] ?? '',
      excerpt: map['excerpt'] ?? '',
      date: map['date'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
