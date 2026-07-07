import 'package:flutter/material.dart';

/// Reusable page layout for the Customers and Items screens: a sticky search
/// field on top, then either a loading spinner, an error panel, an empty state,
/// or the list of items — plus a floating action button.
class ListScaffold extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final String query;
  final ValueChanged<String> onQueryChanged;

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyMessage;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget fab;

  const ListScaffold({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.query,
    required this.onQueryChanged,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
    required this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear',
                        onPressed: () {
                          searchController.clear();
                          onQueryChanged('');
                        },
                      ),
              ),
              onChanged: onQueryChanged, // instant, local filtering
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
      floatingActionButton: fab,
    );
  }

  Widget _body(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return _Centered(
        icon: Icons.wifi_off_rounded,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Something went wrong',
        message: error!,
        onRetry: onRetry,
      );
    }
    if (isEmpty) {
      return _Centered(
        icon: emptyIcon,
        title: 'Nothing here',
        message: emptyMessage,
        onRetry: onRetry,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final VoidCallback onRetry;
  const _Centered({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (iconColor ?? scheme.primary).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor ?? scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
