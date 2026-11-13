import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  static const configuredKey = String.fromEnvironment('COINGECKO_API_KEY');
  final api = const ApiService();
  final dollarController = TextEditingController(text: '100');
  final keyController = TextEditingController(text: configuredKey);
  List<CryptoQuote> quotes = [];
  bool loading = false;
  String? error;
  DateTime? updated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      final values = await api.crypto(apiKey: keyController.text);
      if (!mounted) return;
      setState(() {
        quotes = values;
        updated = DateTime.now();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = '$e'; loading = false; });
    }
  }

  @override
  void dispose() {
    dollarController.dispose();
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dollars = double.tryParse(dollarController.text.trim().replaceAll(',', '.'));
    final valid = dollars != null && dollars.isFinite && dollars >= 0;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageHeader(
          eyebrow: 'Reto 04 · API CoinGecko',
          title: 'Conversor cripto',
          description: 'Consulta precios de referencia en dólares y calcula equivalencias de forma educativa.',
          icon: Icons.currency_bitcoin_rounded,
          accent: appMint,
        ),
        const SizedBox(height: 20),
        AppPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cantidad en dólares (USD)',
            style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            controller: dollarController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.attach_money),
              hintText: 'Ej. 100',
              errorText: valid ? null : 'Introduce una cantidad válida (0 o mayor).',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          const Text('Clave demo de CoinGecko (opcional; ayuda con los límites)',
            style: TextStyle(fontSize: 13, color: Color(0xFFBCC1DA))),
          const SizedBox(height: 8),
          TextField(
            controller: keyController,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(hintText: 'Clave demo (si tienes una)',
              prefixIcon: Icon(Icons.key_outlined)),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Actualizar cotizaciones',
            onPressed: loading ? null : _load,
            icon: Icons.refresh,
          ),
        ])),
        const SizedBox(height: 20),
        if (loading) const Center(child: Padding(
          padding: EdgeInsets.all(22), child: CircularProgressIndicator(),
        )),
        if (error != null) ErrorNotice(message: error!, onRetry: _load),
        if (!loading && updated != null)
          Padding(padding: const EdgeInsets.only(bottom: 12),
            child: Text('Última consulta: ${updated!.hour.toString().padLeft(2, '0')}:${updated!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Color(0xFFADB1CD), fontSize: 12))),
        for (final quote in quotes) ...[
          _CryptoCard(quote: quote, dollars: valid ? dollars : null),
          const SizedBox(height: 12),
        ],
        const SourceFootnote(
          'Datos: CoinGecko. Los resultados son aproximaciones matemáticas, no ofertas para comprar ni asesoría financiera.'),
      ],
    );
  }
}

class _CryptoCard extends StatelessWidget {
  const _CryptoCard({required this.quote, required this.dollars});
  final CryptoQuote quote;
  final double? dollars;

  @override
  Widget build(BuildContext context) {
    final change = quote.change24h;
    final positive = change != null && change >= 0;
    return AppPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: appMint.withOpacity(0.16),
          child: Text(quote.symbol.substring(0, 1),
            style: const TextStyle(color: appMint, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(quote.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          Text(quote.symbol, style: const TextStyle(color: Color(0xFFADB1CD))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${quote.usdPrice.toStringAsFixed(2)} USD',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          if (change != null) Text(
            '${positive ? '+' : ''}${change.toStringAsFixed(2)}% / 24 h',
            style: TextStyle(color: positive ? appMint : const Color(0xFFFF8D97)),
          ),
        ]),
      ]),
      const Divider(height: 28),
      Text('Equivalencia de tu monto', style: const TextStyle(color: Color(0xFFADB1CD))),
      const SizedBox(height: 6),
      Text(dollars == null
          ? 'Introduce una cantidad válida'
          : '${quote.unitsFor(dollars!).toStringAsFixed(8)} ${quote.symbol}',
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 23, color: appMint)),
    ]));
  }
}
