import 'package:flutter/material.dart';

import '../main.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/badges.dart';
import '../widgets/list_scaffold.dart';
import 'customer_form.dart';

/// View all / search / create / edit / delete customers.
///
/// Loaded once and filtered locally as you type; mutations update immediately.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  List<Customer> _all = [];
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
      final page = await api.getCustomers(size: 500);
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

  List<Customer> get _visible {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toLowerCase();
    return _all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q) ||
            (c.phone ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openForm({Customer? existing}) async {
    final result = await showCustomerForm(context, existing: existing);
    if (result == null) return;
    await _load();
    if (mounted) context.showSuccess('Customer $result');
  }

  Future<void> _delete(Customer c) async {
    final ok = await confirmDelete(context, 'customer', c.name);
    if (ok != true) return;

    final index = _all.indexWhere((x) => x.id == c.id);
    setState(() => _all.removeWhere((x) => x.id == c.id));
    try {
      await api.deleteCustomer(c.id!);
      if (mounted) context.showSuccess('Deleted “${c.name}”');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _all.insert(index < 0 ? 0 : index, c));
        context.showError(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListScaffold(
      searchController: _searchController,
      searchHint: 'Search customers by name…',
      query: _query,
      onQueryChanged: (v) => setState(() => _query = v),
      loading: _loading,
      error: _error,
      onRetry: _load,
      isEmpty: _visible.isEmpty,
      emptyIcon: Icons.people_outline,
      emptyMessage: _query.isEmpty
          ? 'No customers yet. Tap “New customer”.'
          : 'No customers match “$_query”.',
      itemCount: _visible.length,
      itemBuilder: (context, i) => _CustomerTile(
        customer: _visible[i],
        onEdit: () => _openForm(existing: _visible[i]),
        onDelete: () => _delete(_visible[i]),
      ),
      fab: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New customer'),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CustomerTile(
      {required this.customer, required this.onEdit, required this.onDelete});

  String get _initials {
    final parts = customer.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = <Widget>[
      if ((customer.email ?? '').isNotEmpty)
        InfoChip(icon: Icons.mail_outline, text: customer.email!),
      if ((customer.phone ?? '').isNotEmpty)
        InfoChip(icon: Icons.phone_outlined, text: customer.phone!),
      if ((customer.address ?? '').isNotEmpty)
        InfoChip(icon: Icons.place_outlined, text: customer.address!),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: scheme.primary,
              child: Text(_initials,
                  style: TextStyle(
                      color: scheme.onPrimary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(customer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: chips),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
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
      ),
    );
  }
}
