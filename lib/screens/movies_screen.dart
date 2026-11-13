import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  static const configuredKey = String.fromEnvironment('TMDB_API_KEY');
  static const categories = <(String, String?)>[
    ('Tendencias', null),
    ('Para reír', '35'),
    ('Aventura', '12'),
    ('Misterio', '9648'),
    ('Animación', '16'),
  ];
  final keyController = TextEditingController(text: configuredKey);
  final api = const ApiService();

  int selected = 0;
  bool loading = false;
  String? error;
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    if (configuredKey.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      final items = await api.movies(
        apiKey: keyController.text,
        genreId: categories[selected].$2,
      );
      if (!mounted) return;
      setState(() { movies = items; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = '$e'; loading = false; movies = []; });
    }
  }

  void _surprise() {
    if (movies.isEmpty) return;
    final item = movies[Random().nextInt(movies.length)];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TU PELÍCULA SORPRESA', style: TextStyle(
            color: appPurple, fontWeight: FontWeight.w800, letterSpacing: 1.5,
          )),
          const SizedBox(height: 12),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('⭐ ${item.rating.toStringAsFixed(1)} / 10'),
          const SizedBox(height: 12),
          Text(item.overview.isEmpty ? 'No hay sinopsis disponible.' : item.overview),
        ]),
      )),
    );
  }

  @override
  void dispose() {
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const PageHeader(
        eyebrow: 'Reto 01 · API TMDB',
        title: '¿Qué vemos hoy?',
        description: 'Explora tendencias, elige un género según tu ánimo o deja que el azar decida.',
        icon: Icons.local_movies_rounded,
      ),
      const SizedBox(height: 20),
      AppPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Configuración de TMDB', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Introduce tu API Key v3 gratuita. No se guarda en el dispositivo.'),
        const SizedBox(height: 12),
        TextField(
          controller: keyController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            hintText: 'Pega tu clave de TMDB',
            prefixIcon: Icon(Icons.key_outlined),
          ),
          onSubmitted: (_) => _load(),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Cargar películas',
          icon: Icons.movie_filter_outlined,
          onPressed: loading ? null : _load,
        ),
      ])),
      const SizedBox(height: 20),
      const Text('Elige tu plan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Wrap(spacing: 9, runSpacing: 8, children: [
        for (var i = 0; i < categories.length; i++)
          ChoiceChip(
            label: Text(categories[i].$1),
            selected: selected == i,
            onSelected: loading ? null : (_) {
              setState(() => selected = i);
              if (keyController.text.trim().isNotEmpty) _load();
            },
          ),
      ]),
      const SizedBox(height: 20),
      Row(children: [
        const Expanded(child: Text('Películas recomendadas', style: TextStyle(
          fontSize: 19, fontWeight: FontWeight.w800,
        ))),
        OutlinedButton.icon(
          onPressed: movies.isNotEmpty ? _surprise : null,
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: const Text('Sorpréndeme'),
        ),
      ]),
      const SizedBox(height: 12),
      if (loading) const Padding(
        padding: EdgeInsets.all(22), child: Center(child: CircularProgressIndicator()),
      ),
      if (error != null) ErrorNotice(message: error!, onRetry: _load),
      if (!loading && error == null && movies.isEmpty)
        const AppPanel(child: Text('Agrega tu clave y toca «Cargar películas» para ver los resultados.')),
      if (!loading)
        for (final item in movies) ...[
          _MovieRow(movie: item),
          const SizedBox(height: 10),
        ],
      const SourceFootnote('Datos y pósteres de TMDB. Esta aplicación no cuenta con el aval de TMDB.'),
    ],
  );
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) => AppPanel(
    padding: const EdgeInsets.all(12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 100,
          height: 145,
          child: movie.posterUrl == null
              ? const ColoredBox(color: Color(0xFF343856), child: Icon(Icons.movie, size: 40))
              : Image.network(
                  movie.posterUrl!, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Color(0xFF343856), child: Icon(Icons.broken_image)),
                ),
        ),
      ),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 6),
        Text('⭐ ${movie.rating.toStringAsFixed(1)} / 10',
          style: const TextStyle(color: appYellow, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(movie.overview.isEmpty ? 'Sin sinopsis disponible.' : movie.overview,
          maxLines: 4, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFC1C4D8), height: 1.35)),
      ])),
    ]),
  );
}
