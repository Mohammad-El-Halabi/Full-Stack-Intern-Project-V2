import 'package:flutter/material.dart';

import '../main.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';
import '../utils/formatting.dart';
import 'invoice_create_screen.dart';

/// View all invoices for a chosen customer (by id) and create new ones.
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Customer> _customers = [];
  Customer? _selected;
  bool _loadingCustomers = true;
  String? _customersError;

  Future<List<Invoice>>? _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loadingCustomers = true;
      _customersError = null;
    });
    try {
      final page = await api.getCustomers(size: 200);
      setState(() {
        _customers = page.content;
        _loadingCustomers = false;
        // Keep the previously selected customer if still present.
        if (_selected != null) {
          _selected = _customers.firstWhere(
            (c) => c.id == _selected!.id,
            orElse: () => _customers.isNotEmpty ? _customers.first : _selected!,
          );
        }
      });
    } on ApiException catch (e) {
      setState(() {
        _loadingCustomers = false;
        _customersError = e.message;
      });
    }
  }

  void _selectCustomer(Customer? c) {
    setState(() {
      _selected = c;
      _invoicesFuture = c == null ? null : _loadInvoices(c.id!);
    });
  }

  Future<List<Invoice>> _loadInvoices(int customerId) async {
    final page = await api.getInvoicesByCustomer(customerId, size: 100);
    return page.content;
  }

  void _refreshInvoices() {
    if (_selected != null) {
      setState(() => _invoicesFuture = _loadInvoices(_selected!.id!));
    }
  }

  Future<void> _createInvoice() async {
    if (_selected == null) return;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceCreateScreen(customer: _selected!),
      ),
    );
    if (created == true) _refreshInvoices();
  }

  Future<void> _confirmDelete(Invoice inv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete invoice'),
        content: Text('Delete invoice #${inv.id} (${money(inv.totalAmount)})?'),
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
      await api.deleteInvoice(inv.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Deleted invoice #${inv.id}')));
      }
      _refreshInvoices();
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
          _buildCustomerPicker(),
          const Divider(height: 1),
          Expanded(child: _buildInvoiceList()),
        ],
      ),
      floatingActionButton: _selected == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _createInvoice,
              icon: const Icon(Icons.add),
              label: const Text('New invoice'),
            ),
    );
  }

  Widget _buildCustomerPicker() {
    if (_loadingCustomers) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (_customersError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(_customersError!)),
            TextButton(onPressed: _loadCustomers, child: const Text('Retry')),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<Customer>(
        initialValue: _selected,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Customer',
          prefixIcon: Icon(Icons.person),
        ),
        hint: const Text('Select a customer to view their invoices'),
        items: _customers
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text('${c.name}  (id ${c.id})',
                      overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: _selectCustomer,
      ),
    );
  }

  Widget _buildInvoiceList() {
    if (_selected == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pick a customer above to see their invoices.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return FutureBuilder<List<Invoice>>(
      future: _invoicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                    onPressed: _refreshInvoices, child: const Text('Retry')),
              ],
            ),
          );
        }
        final invoices = snapshot.data ?? [];
        if (invoices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text('${_selected!.name} has no invoices yet.'),
                  const SizedBox(height: 8),
                  const Text('Tap "New invoice" to create one.'),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refreshInvoices(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88, top: 4),
            itemCount: invoices.length,
            itemBuilder: (_, i) => _InvoiceCard(
              invoice: invoices[i],
              onDelete: () => _confirmDelete(invoices[i]),
            ),
          ),
        );
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;
  const _InvoiceCard({required this.invoice, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
        title: Text('Invoice #${invoice.id}  ·  ${money(invoice.totalAmount)}'),
        subtitle: Text(
            '${formatDate(invoice.invoiceDate)}  ·  ${invoice.items.length} item(s)  ·  ${invoice.status}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          ...invoice.items.map(
            (line) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(line.itemName),
              subtitle: Text('${line.quantity} × ${money(line.unitPrice)}'),
              trailing: Text(money(line.lineTotal)),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
              Text('Total: ${money(invoice.totalAmount)}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
