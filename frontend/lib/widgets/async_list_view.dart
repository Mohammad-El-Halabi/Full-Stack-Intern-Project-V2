import 'package:flutter/material.dart';

/// Renders a [Future] that resolves to a list, handling the loading, error and
/// empty states uniformly so each screen does not repeat the boilerplate.
class AsyncListView<T> extends StatelessWidget {
  final Future<List<T>> future;
  final Widget Function(T item) itemBuilder;
  final VoidCallback onRetry;
  final String emptyMessage;

  const AsyncListView({
    super.key,
    required this.future,
    required this.itemBuilder,
    required this.onRetry,
    this.emptyMessage = 'Nothing here yet.',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Message(
            icon: Icons.error_outline,
            color: Colors.red,
            text: '${snapshot.error}',
            onRetry: onRetry,
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _Message(
            icon: Icons.inbox_outlined,
            text: emptyMessage,
            onRetry: onRetry,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => onRetry(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88, top: 4),
            itemCount: items.length,
            itemBuilder: (_, i) => itemBuilder(items[i]),
          ),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback onRetry;

  const _Message({
    required this.icon,
    required this.text,
    required this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color ?? Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
