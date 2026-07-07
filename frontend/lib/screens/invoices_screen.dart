import 'package:flutter/material.dart';

import '../main.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatting.dart';
import '../widgets/badges.dart';
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

  List<Invoice> _invoices = [];
  bool _loadingInvoices = false;
  String? _invoicesError;

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
      final page = await api.getCustomers(size: 500);
      if (!mounted) return;
      setState(() {
        _customers = page.content;
        _loadingCustomers = false;
        if (_selected != null) {
          _selected = _customers.firstWhere((c) => c.id == _selected!.id,
              orElse: () => _customers.isNotEmpty ? _customers.first : _selected!);
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCustomers = false;
        _customersError = e.message;
      });
    }
  }

  Future<void> _selectCustomer(Customer? c) async {
    setState(() {
      _selected = c;
      _invoices = [];
      _invoicesError = null;
    });
    if (c != null) await _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    if (_selected == null) return;
    setState(() {
      _loadingInvoices = true;
      _invoicesError = null;
    });
    try {
      final page = await api.getInvoicesByCustomer(_selected!.id!, size: 200);
      if (!mounted) return;
      setState(() {
        _invoices = page.content;
        _loadingInvoices = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingInvoices = false;
        _invoicesError = e.message;
      });
    }
  }

  Future<void> _createInvoice() async {
    if (_selected == null) return;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InvoiceCreateScreen(customer: _selected!)),
    );
    if (created == true) {
      await _loadInvoices();
      if (mounted) context.showSuccess('Invoice created');
    }
  }

  Future<void> _delete(Invoice inv) async {
    final ok = await confirmDelete(context, 'invoice', 'Invoice #${inv.id}');
    if (ok != true) return;
    final index = _invoices.indexWhere((x) => x.id == inv.id);
    setState(() => _invoices.removeWhere((x) => x.id == inv.id));
    try {
      await api.deleteInvoice(inv.id);
      if (mounted) context.showSuccess('Deleted invoice #${inv.id}');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _invoices.insert(index < 0 ? 0 : index, inv));
        context.showError(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCustomerPicker(),
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
          padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    }
    if (_customersError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(_customersError!)),
          TextButton(onPressed: _loadCustomers, child: const Text('Retry')),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: DropdownButtonFormField<Customer>(
        initialValue: _selected,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Customer',
          prefixIcon: Icon(Icons.person_outline),
        ),
        hint: const Text('Select a customer to view their invoices'),
        items: _customers
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text('${c.name}  ·  id ${c.id}',
                      overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: _selectCustomer,
      ),
    );
  }

  Widget _buildInvoiceList() {
    if (_selected == null) {
      return _placeholder(Icons.receipt_long_outlined,
          'Pick a customer above to see their invoices.');
    }
    if (_loadingInvoices) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_invoicesError != null) {
      return _placeholder(Icons.wifi_off_rounded, _invoicesError!,
          retry: _loadInvoices, isError: true);
    }
    if (_invoices.isEmpty) {
      return _placeholder(Icons.receipt_long_outlined,
          '${_selected!.name} has no invoices yet.\nTap “New invoice” to create one.');
    }
    final total = _invoices.fold<double>(0, (s, i) => s + i.totalAmount);
    return Column(
      children: [
        _summaryBar(_invoices.length, total),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadInvoices,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 96),
              itemCount: _invoices.length,
              itemBuilder: (_, i) =>
                  _InvoiceCard(invoice: _invoices[i], onDelete: () => _delete(_invoices[i])),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryBar(int count, double total) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$count invoice${count == 1 ? '' : 's'}',
              style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600)),
          Text('Lifetime total  ${money(total)}',
              style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _placeholder(IconData icon, String message,
      {VoidCallback? retry, bool isError = false}) {
    final scheme = Theme.of(context).colorScheme;
    final color = isError ? scheme.error : scheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            if (retry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;
  const _InvoiceCard({required this.invoice, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.receipt_long, color: scheme.onPrimaryContainer),
        ),
        title: Row(
          children: [
            Text('Invoice #${invoice.id}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            PricePill(value: invoice.totalAmount),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
              '${formatDate(invoice.invoiceDate)}  ·  ${invoice.items.length} item(s)'),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          ...invoice.items.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.itemName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${line.quantity} × ${money(line.unitPrice)}',
                            style: TextStyle(
                                fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(money(line.lineTotal),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
              ),
              Text('Total  ${money(invoice.totalAmount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
