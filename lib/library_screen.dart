import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'book.dart';
import 'book_tile.dart';

/// The only screen of the app.
///
/// It does three things:
///   1. reads `assets/data/books.json` and decodes it into a list of [Book];
///   2. shows a loading spinner, an error with a Retry button, or the list;
///   3. filters that list with the search box.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  /// Must match the path declared under `flutter: assets:` in pubspec.yaml.
  static const String dataPath = 'assets/data/books.json';

  final TextEditingController _searchController = TextEditingController();

  late Future<List<Book>> _booksFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _booksFuture = _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Reads the asset, decodes the JSON text, and maps every record to a [Book].
  ///
  /// Any failure (missing file, broken JSON, wrong field type) is thrown and
  /// shown by the FutureBuilder below instead of crashing the app.
  Future<List<Book>> _loadBooks() async {
    final String rawJson = await rootBundle.loadString(dataPath);
    final Map<String, dynamic> data =
        jsonDecode(rawJson) as Map<String, dynamic>;
    final List<dynamic> records = data['books'] as List<dynamic>;
    return records
        .map((dynamic record) => Book.fromJson(record as Map<String, dynamic>))
        .toList();
  }

  /// Re-runs the load. Used by the Retry button and by pull-to-refresh.
  void _reload() {
    setState(() {
      _booksFuture = _loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Reload JSON',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _reload, error: snapshot.error);
          }
          return _buildList(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildList(List<Book> books) {
    final List<Book> visible =
        books.where((Book book) => book.matches(_query)).toList();
    final bool available =
        books.where((Book book) => book.isAvailable).isNotEmpty;

    return Center(
      child: ConstrainedBox(
        // Keeps the list readable in landscape and on a wide desktop window.
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _searchController,
                    onChanged: (String value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search title, author or genre',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${books.length} records from $dataPath · '
                    '${available ? 'some on shelf' : 'all borrowed'}'
                    '${_query.isEmpty ? '' : ' · ${visible.length} match'}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF7C756B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: visible.length,
                        separatorBuilder:
                            (BuildContext context, int index) =>
                                const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) =>
                            BookTile(book: visible[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the JSON could not be read or parsed.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded,
                size: 40, color: Color(0xFF9A6A3A)),
            const SizedBox(height: 14),
            const Text(
              'Could not load the library',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF7C756B),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the search matched nothing.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No books match your search.',
          style: TextStyle(fontSize: 13, color: Color(0xFF7C756B)),
        ),
      ),
    );
  }
}
