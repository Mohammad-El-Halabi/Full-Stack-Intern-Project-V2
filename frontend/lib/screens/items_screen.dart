import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../utils/formatting.dart';
import '../widgets/async_list_view.dart';
import 'item_form.dart';

/// View all / search / create / edit / delete items.
class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _searchController = TextEditingController();
  late Future<List<Item>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Item>> _load() async {
    final page = _query.trim().isEmpty
        ? await api.getItems(size: 100)
        : await api.searchItems(_query.trim(), size: 100);
    return page.content;
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _openForm({Item? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ItemForm(existing: existing),
    );
    if (saved == true) _refresh();
  }

  Future<void> _confirmDelete(Item item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await api.deleteItem(item.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Deleted ${item.name}')));
      }
      _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items by name…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                          _refresh();
                        },
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: AsyncListView<Item>(
              future: _future,
              onRetry: _refresh,
              emptyMessage: 'No items found.',
              itemBuilder: (item) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                  title: Text(item.name),
                  subtitle: Text([
                    if (item.description != null && item.description!.isNotEmpty)
                      item.description!,
                    'In stock: ${item.stockQuantity}',
                  ].join('\n')),
                  isThreeLine: item.description != null && item.description!.isNotEmpty,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(money(item.price),
                          style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _openForm(existing: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_box),
        label: const Text('New item'),
      ),
    );
  }
}
