class Movie {
  const Movie({
    required this.title,
    required this.overview,
    required this.rating,
    required this.posterPath,
  });

  final String title;
  final String overview;
  final double rating;
  final String? posterPath;

  String? get posterUrl =>
      posterPath == null || posterPath!.isEmpty
          ? null
          : 'https://image.tmdb.org/t/p/w500$posterPath';

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawRating = json['vote_average'];
    return Movie(
      title: (json['title'] ?? json['original_title'] ?? 'Sin título').toString(),
      overview: (json['overview'] ?? '').toString(),
      rating: rawRating is num ? rawRating.toDouble() : 0,
      posterPath: json['poster_path'] as String?,
    );
  }
}

class WeatherReport {
  const WeatherReport({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.code,
  });

  final String location;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double wind;
  final int code;

  String get condition {
    if (code == 0) return 'Despejado';
    if (code <= 3) return 'Parcialmente nublado';
    if (code == 45 || code == 48) return 'Con niebla';
    if (code >= 51 && code <= 67) return 'Con lluvia';
    if (code >= 71 && code <= 77) return 'Con nieve';
    if (code >= 80 && code <= 82) return 'Con chubascos';
    if (code >= 95) return 'Con tormenta';
    return 'Condiciones variables';
  }
}

class CryptoQuote {
  const CryptoQuote({
    required this.id,
    required this.name,
    required this.symbol,
    required this.usdPrice,
    this.change24h,
  });

  final String id;
  final String name;
  final String symbol;
  final double usdPrice;
  final double? change24h;

  double unitsFor(double dollars) =>
      usdPrice > 0 && dollars >= 0 ? dollars / usdPrice : 0;
}
