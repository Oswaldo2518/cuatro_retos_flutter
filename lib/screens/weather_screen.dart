import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final cityController = TextEditingController(text: 'Ciudad de México');
  final api = const ApiService();
  WeatherReport? weather;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      final result = await api.weather(cityController.text);
      if (!mounted) return;
      setState(() { weather = result; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = '$e'; loading = false; weather = null; });
    }
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_queue_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.water_drop_rounded;
    }
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    return Icons.cloud_rounded;
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const PageHeader(
        eyebrow: 'Reto 03 · API Open-Meteo',
        title: 'El clima de hoy',
        description: 'Consulta las condiciones meteorológicas de cualquier ciudad sin compartir tu GPS.',
        icon: Icons.cloud_rounded,
        accent: appYellow,
      ),
      const SizedBox(height: 20),
      AppPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('¿En qué ciudad?', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        TextField(
          controller: cityController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Ej. Guanajuato, Guadalajara, Monterrey',
            prefixIcon: Icon(Icons.location_city),
          ),
          onSubmitted: (_) => _load(),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Consultar clima',
          icon: Icons.search,
          onPressed: loading ? null : _load,
        ),
      ])),
      const SizedBox(height: 20),
      if (loading) const Center(child: Padding(
        padding: EdgeInsets.all(22), child: CircularProgressIndicator(),
      )),
      if (error != null) ErrorNotice(message: error!, onRetry: _load),
      if (!loading && weather != null) ...[
        AppPanel(child: Column(children: [
          Icon(_weatherIcon(weather!.code), size: 80, color: appYellow),
          const SizedBox(height: 4),
          Text('${weather!.temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900)),
          Text(weather!.condition, style: const TextStyle(fontSize: 19,
            color: appYellow, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(weather!.location, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFFCCD0E7))),
        ])),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _WeatherMetric(
            icon: Icons.thermostat_outlined, title: 'Sensación',
            value: '${weather!.feelsLike.toStringAsFixed(1)} °C',
          )),
          const SizedBox(width: 10),
          Expanded(child: _WeatherMetric(
            icon: Icons.water_drop_outlined, title: 'Humedad',
            value: '${weather!.humidity} %',
          )),
        ]),
        const SizedBox(height: 10),
        _WeatherMetric(
          icon: Icons.air, title: 'Velocidad del viento',
          value: '${weather!.wind.toStringAsFixed(1)} km/h',
        ),
      ],
      const SourceFootnote('Datos: Open-Meteo. Son estimaciones meteorológicas; pueden cambiar.'),
    ],
  );
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => AppPanel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 24, color: appYellow),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: Color(0xFFADB1CD), fontSize: 13)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    ]),
  );
}
