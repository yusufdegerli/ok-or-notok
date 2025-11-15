import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/film_provider.dart';
import '../widgets/comment_widget.dart';

class FilmDetailScreen extends StatefulWidget {
  final String filmId;

  const FilmDetailScreen({super.key, required this.filmId});

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isWatched = false;
  bool _isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filmProvider = Provider.of<FilmProvider>(context, listen: false);
      filmProvider.loadFilmDetail(widget.filmId);
      filmProvider.loadFilmComments(widget.filmId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    await filmProvider.postFilmComment(
      widget.filmId,
      _commentController.text.trim(),
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Film Details')),
      body: Consumer<FilmProvider>(
        builder: (context, filmProvider, child) {
          if (filmProvider.isLoading && filmProvider.currentFilm == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final film = filmProvider.currentFilm;
          if (film == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('Film not found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      filmProvider.loadFilmDetail(widget.filmId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backdrop Image
                if (film.backdropUrl != null)
                  Image.network(
                    film.backdropUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        film.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (film.originalTitle != null &&
                          film.originalTitle != film.title) ...[
                        const SizedBox(height: 4),
                        Text(
                          film.originalTitle!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                                filmProvider.likeFilm(film.id);
                              },
                              icon: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked ? Colors.red : null,
                              ),
                              label: Text('${film.likesCount}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isWatched = !_isWatched;
                                });
                                filmProvider.watchFilm(film.id);
                              },
                              icon: Icon(
                                _isWatched
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: _isWatched ? Colors.green : null,
                              ),
                              label: const Text('Watched'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isInWatchlist = !_isInWatchlist;
                                });
                                filmProvider.addToWatchlist(film.id);
                              },
                              icon: Icon(
                                _isInWatchlist
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: _isInWatchlist ? Colors.amber : null,
                              ),
                              label: const Text('Watchlist'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info
                      if (film.releaseDate != null) ...[
                        _buildInfoRow(
                          context,
                          Icons.calendar_today,
                          'Release Date',
                          '${film.releaseDate!.day}/${film.releaseDate!.month}/${film.releaseDate!.year}',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (film.duration != null) ...[
                        _buildInfoRow(
                          context,
                          Icons.access_time,
                          'Duration',
                          '${film.duration} minutes',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (film.director != null) ...[
                        _buildInfoRow(
                          context,
                          Icons.person,
                          'Director',
                          film.director!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (film.rating != null) ...[
                        _buildInfoRow(
                          context,
                          Icons.star,
                          'Rating',
                          film.rating!.toStringAsFixed(1),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (film.countries.isNotEmpty) ...[
                        _buildInfoRow(
                          context,
                          Icons.location_on,
                          'Countries',
                          film.countries.join(', '),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (film.genres.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: film.genres.map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Description
                      if (film.description != null) ...[
                        Text(
                          'Description',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          film.description!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Comments Section
                      Text(
                        'Comments',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comment Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _postComment,
                            icon: const Icon(Icons.send),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Comments List
                      if (filmProvider.filmComments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ...filmProvider.filmComments.map(
                          (comment) => CommentWidget(comment: comment),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
