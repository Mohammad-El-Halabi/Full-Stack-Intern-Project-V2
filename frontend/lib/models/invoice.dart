/// A single line on an invoice, matching the backend InvoiceLineResponse.
class InvoiceLine {
  final int? id;
  final int itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  InvoiceLine({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) => InvoiceLine(
        id: json['id'] as int?,
        itemId: json['itemId'] as int? ?? 0,
        itemName: json['itemName'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
      );
}

/// A full invoice, matching the backend InvoiceResponse.
class Invoice {
  final int id;
  final int customerId;
  final String customerName;
  final DateTime? invoiceDate;
  final double totalAmount;
  final String status;
  final List<InvoiceLine> items;

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.invoiceDate,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as int? ?? 0,
        customerId: json['customerId'] as int? ?? 0,
        customerName: json['customerName'] as String? ?? '',
        invoiceDate: json['invoiceDate'] != null
            ? DateTime.tryParse(json['invoiceDate'] as String)
            : null,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => InvoiceLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A line the user is composing when creating a new invoice.
class NewInvoiceLine {
  final int itemId;
  final String itemName;
  final double unitPrice;
  int quantity;

  NewInvoiceLine({
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toRequestJson() => {
        'itemId': itemId,
        'quantity': quantity,
      };
}
