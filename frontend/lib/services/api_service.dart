import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/item.dart';
import '../models/page_response.dart';

/// Thrown when the API returns a non-success status. Carries a human-readable
/// message extracted from the backend's ApiError body when available.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thin client over the Spring Boot REST API.
class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final qp = query
        ?.map((k, v) => MapEntry(k, v?.toString()))
        .cast<String, String>();
    return Uri.parse('${ApiConfig.apiUrl}$path')
        .replace(queryParameters: qp?.isEmpty ?? true ? null : qp);
  }

  Never _throw(http.Response res) {
    String message = 'Request failed (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['message'] != null) {
        message = body['message'] as String;
      }
      final fieldErrors = body['fieldErrors'] as Map<String, dynamic>?;
      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        message +=
            ': ${fieldErrors.entries.map((e) => '${e.key} ${e.value}').join(', ')}';
      }
    } catch (_) {
      // Body was not JSON; keep the default message.
    }
    throw ApiException(message, statusCode: res.statusCode);
  }

  Future<T> _wrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Could not reach the server. Is the API running at ${ApiConfig.baseUrl}?\n($e)');
    }
  }

  // =================================================================
  //  Customers
  // =================================================================
  Future<PageResponse<Customer>> getCustomers({int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/customers', {'page': page, 'size': size, 'sort': 'name,asc'}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Customer.fromJson);
      });

  Future<PageResponse<Customer>> searchCustomers(String name,
          {int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/customers/search',
                {'name': name, 'page': page, 'size': size}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Customer.fromJson);
      });

  Future<Customer> createCustomer(Customer c) => _wrap(() async {
        final res = await _client
            .post(_uri('/customers'),
                headers: _jsonHeaders, body: jsonEncode(c.toRequestJson()))
            .timeout(_timeout);
        if (res.statusCode != 201) _throw(res);
        return Customer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });

  Future<Customer> updateCustomer(int id, Customer c) => _wrap(() async {
        final res = await _client
            .put(_uri('/customers/$id'),
                headers: _jsonHeaders, body: jsonEncode(c.toRequestJson()))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return Customer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });

  Future<void> deleteCustomer(int id) => _wrap(() async {
        final res =
            await _client.delete(_uri('/customers/$id')).timeout(_timeout);
        if (res.statusCode != 204) _throw(res);
      });

  // =================================================================
  //  Items
  // =================================================================
  Future<PageResponse<Item>> getItems({int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/items', {'page': page, 'size': size, 'sort': 'name,asc'}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Item.fromJson);
      });

  Future<PageResponse<Item>> searchItems(String name,
          {int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/items/search', {'name': name, 'page': page, 'size': size}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Item.fromJson);
      });

  Future<Item> createItem(Item i) => _wrap(() async {
        final res = await _client
            .post(_uri('/items'),
                headers: _jsonHeaders, body: jsonEncode(i.toRequestJson()))
            .timeout(_timeout);
        if (res.statusCode != 201) _throw(res);
        return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });

  Future<Item> updateItem(int id, Item i) => _wrap(() async {
        final res = await _client
            .put(_uri('/items/$id'),
                headers: _jsonHeaders, body: jsonEncode(i.toRequestJson()))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });

  Future<void> deleteItem(int id) => _wrap(() async {
        final res = await _client.delete(_uri('/items/$id')).timeout(_timeout);
        if (res.statusCode != 204) _throw(res);
      });

  // =================================================================
  //  Invoices
  // =================================================================
  Future<PageResponse<Invoice>> getInvoicesByCustomer(int customerId,
          {int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/invoices/by-customer/$customerId',
                {'page': page, 'size': size, 'sort': 'invoiceDate,desc'}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Invoice.fromJson);
      });

  Future<PageResponse<Invoice>> searchInvoicesByCustomerName(String name,
          {int page = 0, int size = 20}) =>
      _wrap(() async {
        final res = await _client
            .get(_uri('/invoices/search',
                {'customerName': name, 'page': page, 'size': size}))
            .timeout(_timeout);
        if (res.statusCode != 200) _throw(res);
        return PageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>, Invoice.fromJson);
      });

  Future<Invoice> createInvoice(int customerId, List<NewInvoiceLine> lines) =>
      _wrap(() async {
        final body = {
          'customerId': customerId,
          'items': lines.map((l) => l.toRequestJson()).toList(),
        };
        final res = await _client
            .post(_uri('/invoices'),
                headers: _jsonHeaders, body: jsonEncode(body))
            .timeout(_timeout);
        if (res.statusCode != 201) _throw(res);
        return Invoice.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      });

  Future<void> deleteInvoice(int id) => _wrap(() async {
        final res =
            await _client.delete(_uri('/invoices/$id')).timeout(_timeout);
        if (res.statusCode != 204) _throw(res);
      });
}
