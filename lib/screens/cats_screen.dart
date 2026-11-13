import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/ui.dart';

class CatsScreen extends StatefulWidget {
  const CatsScreen({super.key});

  @override
  State<CatsScreen> createState() => _CatsScreenState();
}

class _CatsScreenState extends State<CatsScreen> {
  static const filters = <(String, String)>[
    ('Normal', 'none'),
    ('Blanco y negro', 'mono'),
    ('Desenfoque', 'blur'),
    ('Invertido', 'negate'),
  ];

  final textController = TextEditingController(text: 'Hoy sí terminé mi tarea');
  final api = const ApiService();
  String filter = 'none';
  late Uri imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = api.catImageUrl(
      caption: textController.text,
      filter: filter,
      nonce: DateTime.now().microsecondsSinceEpoch,
    );
  }

  void _makeImage() {
    setState(() {
      imageUrl = api.catImageUrl(
        caption: textController.text,
        filter: filter,
        nonce: DateTime.now().microsecondsSinceEpoch,
      );
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const PageHeader(
        eyebrow: 'Reto 02 · API Cataas',
        title: 'Estudio de memes',
        description: 'Escribe algo divertido, aplica un filtro y genera una foto de gato diferente.',
        icon: Icons.pets_rounded,
        accent: appMint,
      ),
      const SizedBox(height: 20),
      AppPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tu frase', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        TextField(
          controller: textController,
          maxLength: 70,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Escribe una frase para tu meme...',
            prefixIcon: Icon(Icons.text_fields),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Filtro', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 9, runSpacing: 7, children: [
          for (final option in filters)
            ChoiceChip(
              label: Text(option.$1),
              selected: filter == option.$2,
              onSelected: (_) {
                filter = option.$2;
                _makeImage();
              },
            ),
        ]),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Generar otro meme',
          icon: Icons.auto_awesome,
          onPressed: _makeImage,
        ),
      ])),
      const SizedBox(height: 20),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.network(
            imageUrl.toString(),
            key: ValueKey(imageUrl.toString()),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const ColoredBox(
                    color: Color(0xFF262A43),
                    child: Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFF292C45),
              child: Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No se pudo cargar el gato. Revisa tu conexión y vuelve a generar.'),
              )),
            ),
          ),
        ),
      ),
      const SourceFootnote('Imágenes generadas a través de Cataas. Cada consulta solicita un gato aleatorio.'),
    ],
  );
}
