import 'package:flutter/material.dart';

import '../utils/formatting.dart';

/// A coloured pill showing an item's price.
class PricePill extends StatelessWidget {
  final double value;
  const PricePill({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        money(value),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// A stock indicator: red when out, amber when low, green otherwise.
class StockBadge extends StatelessWidget {
  final int stock;
  const StockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (stock) {
      0 => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C), 'Out of stock'),
      < 20 => (const Color(0xFFFEF3C7), const Color(0xFF92400E), 'Low: $stock'),
      _ => (const Color(0xFFDCFCE7), const Color(0xFF166534), 'In stock: $stock'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: fg),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

/// A small chip for a piece of contact info (email/phone/address).
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Shared delete confirmation dialog. Returns true if the user confirms.
Future<bool?> confirmDelete(BuildContext context, String kind, String name) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded,
          color: Theme.of(ctx).colorScheme.error),
      title: Text('Delete $kind?'),
      content: Text('“$name” will be permanently removed. This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
