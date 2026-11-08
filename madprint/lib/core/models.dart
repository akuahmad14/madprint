import 'package:flutter/material.dart';

enum UserRole { admin, operator, staff }

UserRole roleFromString(String s) =>
    UserRole.values.firstWhere((r) => r.name == s, orElse: () => UserRole.operator);

String roleLabel(UserRole r) => switch (r) {
      UserRole.admin => 'Admin / Kasir',
      UserRole.operator => 'Operator Produksi',
      UserRole.staff => 'Staf Finishing / Pengambilan',
    };

enum OrderStatus {
  diterima('diterima', 'Diterima', Colors.blueGrey),
  antreanProduksi('antrean_produksi', 'Antrean Produksi', Colors.indigo),
  sedangDiproses('sedang_diproses', 'Sedang Diproses', Colors.orange),
  finishing('finishing', 'Finishing', Colors.purple),
  siapDiambil('siap_diambil', 'Siap Diambil', Colors.teal),
  selesai('selesai', 'Selesai', Colors.green),
  tertunda('tertunda', 'Tertunda', Colors.amber),
  dibatalkan('dibatalkan', 'Dibatalkan', Colors.red);

  const OrderStatus(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  static var diKerjakan;

  static OrderStatus parse(String v) =>
      OrderStatus.values.firstWhere((s) => s.value == v, orElse: () => OrderStatus.diterima);

  bool get isFinal => this == selesai || this == dibatalkan;

  /// Status berikutnya yang boleh dipilih oleh [role] dari status ini.
  /// Aturan sebenarnya divalidasi di database (change_order_status);
  /// ini hanya untuk menampilkan tombol yang relevan.
  List<OrderStatus> nextFor(UserRole role) {
    if (isFinal) return [];
    final forward = switch (this) {
      diterima => [antreanProduksi],
      antreanProduksi => [sedangDiproses],
      sedangDiproses => [finishing],
      finishing => [siapDiambil],
      siapDiambil => [selesai],
      tertunda => [antreanProduksi, sedangDiproses, finishing],
      _ => <OrderStatus>[],
    };
    final extra = [tertunda, dibatalkan].where((s) => s != this).toList();
    final all = [...forward, ...extra];
    return all.where((s) {
      switch (role) {
        case UserRole.admin:
          return true;
        case UserRole.operator:
          return [sedangDiproses, finishing, tertunda].contains(s);
        case UserRole.staff:
          return [siapDiambil, selesai].contains(s);
      }
    }).toList();
  }
}

class Profile {
  Profile({required this.id, required this.fullName, required this.role});
  final String id;
  final String fullName;
  final UserRole role;

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        fullName: m['full_name'] as String,
        role: roleFromString(m['role'] as String),
      );
}

class Order {
  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone,
    required this.productType,
    this.specifications,
    required this.quantity,
    required this.price,
    this.deadline,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final String productType;
  final String? specifications;
  final int quantity;
  final double price;
  final DateTime? deadline;
  final String? notes;
  final OrderStatus status;
  final DateTime createdAt;

  bool get isLate =>
      deadline != null && !status.isFinal && status != OrderStatus.siapDiambil && deadline!.isBefore(DateTime.now());

  /// Dipakai dengan select('*, customers(name, phone)').
  factory Order.fromMap(Map<String, dynamic> m) {
    final c = (m['customers'] as Map<String, dynamic>?) ?? {};
    return Order(
      id: m['id'] as String,
      orderNumber: m['order_number'] as String,
      customerName: (c['name'] as String?) ?? '-',
      customerPhone: c['phone'] as String?,
      productType: m['product_type'] as String,
      specifications: m['specifications'] as String?,
      quantity: m['quantity'] as int,
      price: double.parse(m['price'].toString()),
      deadline: m['deadline'] == null ? null : DateTime.parse(m['deadline'] as String).toLocal(),
      notes: m['notes'] as String?,
      status: OrderStatus.parse(m['status'] as String),
      createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
    );
  }
}

class StatusHistory {
  StatusHistory({
    required this.oldStatus,
    required this.newStatus,
    required this.updatedByName,
    this.notes,
    required this.createdAt,
  });

  final OrderStatus? oldStatus;
  final OrderStatus newStatus;
  final String updatedByName;
  final String? notes;
  final DateTime createdAt;

  /// Dipakai dengan select('*, profiles(full_name)').
  factory StatusHistory.fromMap(Map<String, dynamic> m) => StatusHistory(
        oldStatus: m['old_status'] == null ? null : OrderStatus.parse(m['old_status'] as String),
        newStatus: OrderStatus.parse(m['new_status'] as String),
        updatedByName: ((m['profiles'] as Map<String, dynamic>?)?['full_name'] as String?) ?? '-',
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
}
