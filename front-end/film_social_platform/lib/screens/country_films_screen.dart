import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/film_provider.dart';
import '../widgets/film_card.dart';
import 'film_detail_screen.dart';

class CountryFilmsScreen extends StatefulWidget {
  final String country;

  const CountryFilmsScreen({super.key, required this.country});

  @override
  State<CountryFilmsScreen> createState() => _CountryFilmsScreenState();
}

class _CountryFilmsScreenState extends State<CountryFilmsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filmProvider = Provider.of<FilmProvider>(context, listen: false);
      filmProvider.loadCountryFilms(widget.country);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Text('Top 100 Films - ${widget.country}')),
      body: Consumer<FilmProvider>(
        builder: (context, filmProvider, child) {
          if (filmProvider.isLoading && filmProvider.countryFilms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (filmProvider.countryFilms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No films found for ${widget.country}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      filmProvider.loadCountryFilms(widget.country);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await filmProvider.loadCountryFilms(widget.country);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWeb ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: filmProvider.countryFilms.length,
              itemBuilder: (context, index) {
                final film = filmProvider.countryFilms[index];
                return FilmCard(
                  film: film,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilmDetailScreen(filmId: film.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
