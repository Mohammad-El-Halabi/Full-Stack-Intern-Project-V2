import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/badges.dart';
import 'item_form.dart';

/// View all / search / create / edit / delete items.
///
/// Items are loaded once and filtered **locally as you type** (instant, no
/// network round-trip per keystroke). Mutations update the list immediately.
class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _searchController = TextEditingController();
  List<Item> _all = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await api.getItems(size: 500);
      if (!mounted) return;
      setState(() {
        _all = page.content;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  List<Item> get _visible {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toLowerCase();
    return _all
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            (i.description ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openForm({Item? existing}) async {
    final result = await showItemForm(context, existing: existing);
    if (result == null) return;
    await _load(); // re-fetch authoritative data
    if (mounted) context.showSuccess('Item $result');
  }

  Future<void> _delete(Item item) async {
    final ok = await confirmDelete(context, 'item', item.name);
    if (ok != true) return;

    // Optimistic removal — the row disappears immediately.
    final index = _all.indexWhere((i) => i.id == item.id);
    setState(() => _all.removeWhere((i) => i.id == item.id));
    try {
      await api.deleteItem(item.id!);
      if (mounted) context.showSuccess('Deleted “${item.name}”');
    } on ApiException catch (e) {
      // Roll back on failure and show the clear reason.
      if (mounted) {
        setState(() => _all.insert(index < 0 ? 0 : index, item));
        context.showError(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListScaffold(
      searchController: _searchController,
      searchHint: 'Search items by name…',
      query: _query,
      onQueryChanged: (v) => setState(() => _query = v),
      loading: _loading,
      error: _error,
      onRetry: _load,
      isEmpty: _visible.isEmpty,
      emptyIcon: Icons.inventory_2_outlined,
      emptyMessage: _query.isEmpty
          ? 'No items yet. Tap “New item”.'
          : 'No items match “$_query”.',
      itemCount: _visible.length,
      itemBuilder: (context, i) => _ItemTile(
        item: _visible[i],
        onEdit: () => _openForm(existing: _visible[i]),
        onDelete: () => _delete(_visible[i]),
      ),
      fab: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New item'),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ItemTile(
      {required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  if ((item.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  StockBadge(stock: item.stockQuantity),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PricePill(value: item.price),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.delete_outline, color: scheme.error),
                      tooltip: 'Delete',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
