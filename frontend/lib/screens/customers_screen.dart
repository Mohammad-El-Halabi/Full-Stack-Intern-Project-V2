import 'package:flutter/material.dart';

import '../main.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../widgets/async_list_view.dart';
import 'customer_form.dart';

/// View all / search / create / edit / delete customers.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  late Future<List<Customer>> _future;
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

  Future<List<Customer>> _load() async {
    final page = _query.trim().isEmpty
        ? await api.getCustomers(size: 100)
        : await api.searchCustomers(_query.trim(), size: 100);
    return page.content;
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _openForm({Customer? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerForm(existing: existing),
    );
    if (saved == true) _refresh();
  }

  Future<void> _confirmDelete(Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer'),
        content: Text('Delete "${c.name}"? This cannot be undone.'),
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
      await api.deleteCustomer(c.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Deleted ${c.name}')));
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
                hintText: 'Search customers by name…',
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
            child: AsyncListView<Customer>(
              future: _future,
              onRetry: _refresh,
              emptyMessage: 'No customers found.',
              itemBuilder: (c) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?'),
                  ),
                  title: Text(c.name),
                  subtitle: Text([
                    if (c.email != null && c.email!.isNotEmpty) c.email,
                    if (c.phone != null && c.phone!.isNotEmpty) c.phone,
                    if (c.address != null && c.address!.isNotEmpty) c.address,
                  ].whereType<String>().join('  ·  ')),
                  isThreeLine: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _openForm(existing: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(c),
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
        icon: const Icon(Icons.person_add),
        label: const Text('New customer'),
      ),
    );
  }
}
