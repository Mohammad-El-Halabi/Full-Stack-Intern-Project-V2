import 'package:flutter/material.dart';

import '../main.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../utils/formatting.dart';

/// Compose and submit a new invoice for [customer]: pick items, set
/// quantities, review the running total, then create.
class InvoiceCreateScreen extends StatefulWidget {
  final Customer customer;
  const InvoiceCreateScreen({super.key, required this.customer});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _searchController = TextEditingController();

  List<Item> _allItems = [];
  bool _loadingItems = true;
  String? _itemsError;
  String _query = '';

  /// itemId -> line being composed.
  final Map<int, NewInvoiceLine> _lines = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loadingItems = true;
      _itemsError = null;
    });
    try {
      final page = await api.getItems(size: 200);
      setState(() {
        _allItems = page.content;
        _loadingItems = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _loadingItems = false;
        _itemsError = e.message;
      });
    }
  }

  List<Item> get _visibleItems {
    if (_query.trim().isEmpty) return _allItems;
    final q = _query.trim().toLowerCase();
    return _allItems.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  double get _total =>
      _lines.values.fold(0.0, (sum, l) => sum + l.lineTotal);

  void _addItem(Item item) {
    if (item.id == null) return;
    setState(() {
      final existing = _lines[item.id];
      if (existing != null) {
        existing.quantity += 1;
      } else {
        _lines[item.id!] = NewInvoiceLine(
          itemId: item.id!,
          itemName: item.name,
          unitPrice: item.price,
        );
      }
    });
  }

  void _changeQty(int itemId, int delta) {
    setState(() {
      final line = _lines[itemId];
      if (line == null) return;
      final next = line.quantity + delta;
      if (next <= 0) {
        _lines.remove(itemId);
      } else {
        line.quantity = next;
      }
    });
  }

  Future<void> _submit() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to the invoice.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final invoice =
          await api.createInvoice(widget.customer.id!, _lines.values.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Created invoice #${invoice.id}')),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New invoice · ${widget.customer.name}')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: catalog of items to add.
                Expanded(child: _buildCatalog()),
                const VerticalDivider(width: 1),
                // Right: the invoice being composed.
                Expanded(child: _buildCart()),
              ],
            ),
          ),
          _buildTotalBar(),
        ],
      ),
    );
  }

  Widget _buildCatalog() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search items…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: _loadingItems
              ? const Center(child: CircularProgressIndicator())
              : _itemsError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_itemsError!, textAlign: TextAlign.center),
                          TextButton(
                              onPressed: _loadItems, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _visibleItems.isEmpty
                      ? const Center(child: Text('No items.'))
                      : ListView.builder(
                          itemCount: _visibleItems.length,
                          itemBuilder: (_, i) {
                            final item = _visibleItems[i];
                            final inCart = _lines[item.id]?.quantity ?? 0;
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                  '${money(item.price)}  ·  stock ${item.stockQuantity}'),
                              trailing: inCart > 0
                                  ? Chip(label: Text('×$inCart'))
                                  : const Icon(Icons.add_circle_outline),
                              onTap: () => _addItem(item),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildCart() {
    if (_lines.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Tap items on the left to add them to this invoice.',
              textAlign: TextAlign.center),
        ),
      );
    }
    final lines = _lines.values.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: lines.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final line = lines[i];
        return ListTile(
          title: Text(line.itemName),
          subtitle: Text('${money(line.unitPrice)} each  =  ${money(line.lineTotal)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _changeQty(line.itemId, -1),
              ),
              Text('${line.quantity}',
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _changeQty(line.itemId, 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalBar() {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${_lines.length} line(s)',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('Total: ${money(_total)}',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Create invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
