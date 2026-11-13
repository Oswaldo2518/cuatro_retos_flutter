import 'package:flutter_test/flutter_test.dart';
import 'package:cuatro_retos_flutter/models/app_models.dart';
import 'package:cuatro_retos_flutter/services/api_service.dart';

void main() {
  test('Movie convierte JSON de TMDB', () {
    final movie = Movie.fromJson({
      'title': 'Ejemplo',
      'overview': 'Descripción',
      'vote_average': 8.5,
      'poster_path': '/poster.jpg',
    });
    expect(movie.title, 'Ejemplo');
    expect(movie.rating, 8.5);
    expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
  });

  test('La conversión USD a unidades de cripto es correcta', () {
    const quote = CryptoQuote(
      id: 'ejemplo', name: 'Ejemplo', symbol: 'EJ', usdPrice: 250,
    );
    expect(quote.unitsFor(100), 0.4);
    expect(quote.unitsFor(-1), 0);
  });

  test('Cataas codifica la frase sin perder rutas', () {
    final url = const ApiService().catImageUrl(
      caption: 'hola / mundo', filter: 'mono', nonce: 1,
    );
    expect(url.pathSegments.last, 'hola / mundo');
    expect(url.queryParameters['filter'], 'mono');
  });
}
