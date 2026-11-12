import 'package:flutter/material.dart';

import 'book.dart';

/// One book record displayed as a card.
///
/// Layout: title + availability on top, author and year underneath, then the
/// description, then a footer with the genre, rating and page count.
///
/// Text that can be long (title, description) is clamped with `maxLines` so a
/// card can never overflow its box on a narrow phone.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book});

  final Book book;

  static const Color _ink = Color(0xFF1F1D19);
  static const Color _muted = Color(0xFF7C756B);
  static const Color _line = Color(0xFFE7E2D8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusTag(isAvailable: book.isAvailable),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${book.author} · ${book.year}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: _muted),
          ),
          const SizedBox(height: 12),
          Text(
            book.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF54504A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _GenreTag(genre: book.genre),
              const Spacer(),
              const Icon(
                Icons.star_rounded,
                size: 15,
                color: Color(0xFFC98A2B),
              ),
              const SizedBox(width: 3),
              Text(
                book.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF54504A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${book.pages} pp',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small pill with the genre name.
class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.genre});

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5F5A52),
        ),
      ),
    );
  }
}

/// "On shelf" / "Borrowed" badge, coloured by availability.
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final Color color =
        isAvailable ? const Color(0xFF2F5D50) : const Color(0xFF9A6A3A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'On shelf' : 'Borrowed',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
