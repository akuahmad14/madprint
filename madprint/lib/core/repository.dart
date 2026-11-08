import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

SupabaseClient get _db => Supabase.instance.client;

/// Prefix QR agar scanner bisa menolak QR dari aplikasi lain.
const qrPrefix = 'printtrack:order:';
String qrPayloadFor(String orderId) => '$qrPrefix$orderId';

String? parseQrPayload(String raw) {
  if (!raw.startsWith(qrPrefix)) return null;
  final id = raw.substring(qrPrefix.length).trim();
  final uuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  return uuid.hasMatch(id) ? id : null;
}

const _orderSelect = '*, customers(name, phone)';

class Repository {
  Future<Profile> fetchMyProfile() async {
    final uid = _db.auth.currentUser!.id;
    final m = await _db.from('profiles').select().eq('id', uid).single();
    return Profile.fromMap(m);
  }

  Future<List<Order>> fetchOrders({String? search, OrderStatus? status}) async {
    var q = _db.from('orders').select(_orderSelect);
    if (status != null) q = q.eq('status', status.value);
    final rows = await q.order('created_at', ascending: false).limit(200);
    var list = rows.map<Order>((m) => Order.fromMap(m)).toList();
    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim().toLowerCase();
      list = list
          .where((o) => o.orderNumber.toLowerCase().contains(s) || o.customerName.toLowerCase().contains(s))
          .toList();
    }
    return list;
  }

  Future<Order?> fetchOrder(String id) async {
    final m = await _db.from('orders').select(_orderSelect).eq('id', id).maybeSingle();
    return m == null ? null : Order.fromMap(m);
  }

  Future<List<StatusHistory>> fetchHistory(String orderId) async {
    final rows = await _db
        .from('order_status_history')
        .select('*, profiles(full_name)')
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    return rows.map<StatusHistory>((m) => StatusHistory.fromMap(m)).toList();
  }

  /// Membuat pelanggan lalu pesanan. Untuk MVP pelanggan selalu baru.
  Future<String> createOrder({
    required String customerName,
    String? customerPhone,
    required String productType,
    String? specifications,
    required int quantity,
    required double price,
    DateTime? deadline,
    String? notes,
  }) async {
    final c = await _db
        .from('customers')
        .insert({'name': customerName, 'phone': customerPhone})
        .select('id')
        .single();
    final o = await _db
        .from('orders')
        .insert({
          'customer_id': c['id'],
          'product_type': productType,
          'specifications': specifications,
          'quantity': quantity,
          'price': price,
          'deadline': deadline?.toUtc().toIso8601String(),
          'notes': notes,
        })
        .select('id')
        .single();
    return o['id'] as String;
  }

  Future<void> updateOrder(
    String id, {
    required String productType,
    String? specifications,
    required int quantity,
    required double price,
    DateTime? deadline,
    String? notes,
  }) async {
    await _db.from('orders').update({
      'product_type': productType,
      'specifications': specifications,
      'quantity': quantity,
      'price': price,
      'deadline': deadline?.toUtc().toIso8601String(),
      'notes': notes,
    }).eq('id', id);
  }

  /// Perubahan status selalu lewat RPC agar divalidasi di database.
  Future<void> changeStatus(String orderId, OrderStatus next, {String? notes}) async {
    await _db.rpc('change_order_status', params: {
      'p_order_id': orderId,
      'p_new_status': next.value,
      'p_notes': notes,
    });
  }

  /// Stream realtime untuk satu pesanan / seluruh daftar pesanan.
  Stream<List<Map<String, dynamic>>> orderChanges() =>
      _db.from('orders').stream(primaryKey: ['id']);

  Stream<List<Map<String, dynamic>>> historyChanges(String orderId) => _db
      .from('order_status_history')
      .stream(primaryKey: ['id']).eq('order_id', orderId);
}
