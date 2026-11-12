/// One record from `assets/data/books.json`.
///
/// The JSON file stores plain values. This class is the same data with real
/// Dart types, so the UI can write `book.title` instead of `json['title']`.
class Book {
  const Book({
    required this.title,
    required this.author,
    required this.year,
    required this.genre,
    required this.rating,
    required this.pages,
    required this.isAvailable,
    required this.description,
  });

  final String title;
  final String author;
  final int year;
  final String genre;
  final double rating;
  final int pages;
  final bool isAvailable;
  final String description;

  /// Turns one decoded JSON object into a [Book].
  ///
  /// Numbers are read as `num` and converted, so both `2018` and `2018.0`
  /// work instead of throwing a cast error.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      year: (json['year'] as num).toInt(),
      genre: json['genre'] as String,
      rating: (json['rating'] as num).toDouble(),
      pages: (json['pages'] as num).toInt(),
      isAvailable: json['available'] as bool,
      description: json['description'] as String,
    );
  }

  /// Used by the search field: matching the title, author or genre counts.
  bool matches(String query) {
    final String text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    return title.toLowerCase().contains(text) ||
        author.toLowerCase().contains(text) ||
        genre.toLowerCase().contains(text);
  }
}
