import 'package:flutter/material.dart';

const appPurple = Color(0xFF806CFF);
const appMint = Color(0xFF46D6BB);
const appYellow = Color(0xFFFFD17A);

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.accent = appPurple,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.28), const Color(0xFF23263D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow.toUpperCase(), style: TextStyle(
              color: accent, fontSize: 12, fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
            )),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, height: 1.1,
            )),
            const SizedBox(height: 10),
            Text(description, style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFCED0E2), height: 1.35,
            )),
          ],
        )),
        const SizedBox(width: 14),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: accent.withOpacity(0.16),
            borderRadius: BorderRadius.circular(22)),
          child: Icon(icon, color: accent, size: 32),
        ),
      ]),
    );
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xFF25283E),
      border: Border.all(color: const Color(0xFF363A55)),
      borderRadius: BorderRadius.circular(22),
    ),
    child: child,
  );
}

class ErrorNotice extends StatelessWidget {
  const ErrorNotice({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppPanel(child: Row(children: [
    const Icon(Icons.info_outline, color: appYellow),
    const SizedBox(width: 12),
    Expanded(child: Text(message)),
    if (onRetry != null)
      IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh), tooltip: 'Reintentar'),
  ]));
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon = Icons.refresh});
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class SourceFootnote extends StatelessWidget {
  const SourceFootnote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 12),
    child: Text(text, style: const TextStyle(
      color: Color(0xFF9FA5C0), fontSize: 12,
    )),
  );
}
