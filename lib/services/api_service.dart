import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  const ApiService();

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 18));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiException('La API rechazó la clave. Revisa tu configuración.');
      }
      if (response.statusCode == 429) {
        throw const ApiException('Se alcanzó el límite de consultas. Inténtalo más tarde.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('El servidor devolvió el error ${response.statusCode}.');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('El servidor envió un formato inesperado.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('No se pudo interpretar la información recibida.');
    } catch (_) {
      throw const ApiException('Error de conexión. Comprueba tu internet e inténtalo de nuevo.');
    }
  }

  Future<List<Movie>> movies({
    required String apiKey,
    String? genreId,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const ApiException('Introduce una clave API de TMDB para consultar películas.');
    }
    final isTrending = genreId == null;
    final uri = Uri.https(
      'api.themoviedb.org',
      isTrending ? '/3/trending/movie/week' : '/3/discover/movie',
      {
        'api_key': apiKey.trim(),
        'language': 'es-MX',
        if (!isTrending) ...{
          'with_genres': genreId!,
          'sort_by': 'popularity.desc',
          'include_adult': 'false',
        },
      },
    );
    final json = await _getJson(uri);
    final results = json['results'];
    if (results is! List) {
      throw const ApiException('No se encontró la lista de películas.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .where((entry) => entry['adult'] != true)
        .map(Movie.fromJson)
        .toList(growable: false);
  }

  Uri catImageUrl({
    required String caption,
    required String filter,
    required int nonce,
  }) {
    return Uri(
      scheme: 'https',
      host: 'cataas.com',
      pathSegments: caption.trim().isEmpty
          ? const ['cat']
          : ['cat', 'says', caption.trim()],
      queryParameters: {
        'width': '900',
        'height': '680',
        if (filter != 'none') 'filter': filter,
        'v': '$nonce',
      },
    );
  }

  Future<WeatherReport> weather(String city) async {
    if (city.trim().length < 3) {
      throw const ApiException('Escribe una ciudad de al menos 3 letras.');
    }
    final geo = await _getJson(Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': city.trim(), 'count': '1', 'language': 'es', 'format': 'json'},
    ));
    final results = geo['results'];
    if (results is! List || results.isEmpty || results.first is! Map) {
      throw const ApiException('No se encontró esa ciudad. Intenta otro nombre.');
    }
    final place = Map<String, dynamic>.from(results.first as Map);
    final lat = place['latitude'];
    final lon = place['longitude'];
    if (lat is! num || lon is! num) {
      throw const ApiException('No se encontraron coordenadas válidas.');
    }
    final response = await _getJson(Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$lat',
        'longitude': '$lon',
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code',
        'timezone': 'auto',
      },
    ));
    final current = response['current'];
    if (current is! Map) {
      throw const ApiException('No hay datos meteorológicos para esa ciudad.');
    }
    final data = Map<String, dynamic>.from(current);
    final name = (place['name'] ?? city).toString();
    final region = (place['admin1'] ?? '').toString();
    final country = (place['country'] ?? '').toString();
    return WeatherReport(
      location: [name, if (region.isNotEmpty) region, if (country.isNotEmpty) country].join(', '),
      temperature: (data['temperature_2m'] as num).toDouble(),
      feelsLike: (data['apparent_temperature'] as num).toDouble(),
      humidity: (data['relative_humidity_2m'] as num).toInt(),
      wind: (data['wind_speed_10m'] as num).toDouble(),
      code: (data['weather_code'] as num).toInt(),
    );
  }

  Future<List<CryptoQuote>> crypto({String apiKey = ''}) async {
    final response = await _getJson(Uri.https(
      'api.coingecko.com',
      '/api/v3/simple/price',
      {
        'ids': 'bitcoin,ethereum,solana',
        'vs_currencies': 'usd',
        'include_24hr_change': 'true',
        if (apiKey.trim().isNotEmpty) 'x_cg_demo_api_key': apiKey.trim(),
      },
    ));
    const info = [
      ('bitcoin', 'Bitcoin', 'BTC'),
      ('ethereum', 'Ethereum', 'ETH'),
      ('solana', 'Solana', 'SOL'),
    ];
    return info.map((coin) {
      final record = response[coin.$1];
      if (record is! Map || record['usd'] is! num) {
        throw const ApiException('Faltan cotizaciones en la respuesta de CoinGecko.');
      }
      final data = Map<String, dynamic>.from(record);
      final change = data['usd_24h_change'];
      return CryptoQuote(
        id: coin.$1,
        name: coin.$2,
        symbol: coin.$3,
        usdPrice: (data['usd'] as num).toDouble(),
        change24h: change is num ? change.toDouble() : null,
      );
    }).toList(growable: false);
  }
}
