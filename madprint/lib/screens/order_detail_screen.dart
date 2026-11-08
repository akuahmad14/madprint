import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/models.dart';
import '../core/providers.dart';
import '../core/repository.dart';
import 'order_form_screen.dart';
import 'orders_screen.dart' show StatusChip, rupiah, dateFmt;

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen(
      {super.key, required this.orderId, required this.role});
  final String orderId;
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));
    final history = ref.watch(historyProvider(orderId));

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E1E1E),
          primary: Colors.white,
          onSurface: Colors.white,
          error: Color(0xFFE57373),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      child: order.when(
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(
              child: CircularProgressIndicator(color: Colors.white)),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Color(0xFFE57373)),
                const SizedBox(height: 12),
                const Text('Gagal memuat pesanan. Periksa jaringan.',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (o) {
          if (o == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('Pesanan tidak ditemukan.',
                    style: TextStyle(color: Colors.white54)),
              ),
            );
          }
          final next = o.status.nextFor(role);
          return Scaffold(
            appBar: AppBar(
              title: Text(o.orderNumber),
              actions: [
                if (role == UserRole.admin && !o.status.isFinal)
                  IconButton(
                    tooltip: 'Ubah',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrderFormScreen(order: o)),
                    ),
                  ),
                IconButton(
                  tooltip: 'Tampilkan QR',
                  icon: const Icon(Icons.qr_code_2_rounded),
                  onPressed: () => _showQr(context, o),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Card Pelanggan & Status Utama
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              o.customerName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          StatusChip(o.status),
                        ],
                      ),
                      if (o.isLate) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE57373).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 14, color: Color(0xFFE57373)),
                              SizedBox(width: 6),
                              Text(
                                'Melewati tenggat',
                                style: TextStyle(
                                  color: Color(0xFFE57373),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Detail Informasi Pesanan
                const Text(
                  'Rincian Pesanan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _row('Telepon', o.customerPhone ?? '-'),
                      const Divider(color: Colors.white10, height: 16),
                      _row('Jenis cetakan', o.productType),
                      const Divider(color: Colors.white10, height: 16),
                      _row('Spesifikasi', o.specifications ?? '-'),
                      const Divider(color: Colors.white10, height: 16),
                      _row('Jumlah', '${o.quantity}'),
                      if (role == UserRole.admin) ...[
                        const Divider(color: Colors.white10, height: 16),
                        _row('Harga', rupiah.format(o.price)),
                      ],
                      const Divider(color: Colors.white10, height: 16),
                      _row(
                          'Tenggat',
                          o.deadline == null
                              ? '-'
                              : dateFmt.format(o.deadline!)),
                      const Divider(color: Colors.white10, height: 16),
                      _row('Catatan', o.notes ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Perbarui Status Aksi
                if (next.isNotEmpty) ...[
                  const Text(
                    'Perbarui Status',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final s in next)
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onPressed: () => _changeStatus(context, ref, o, s),
                          child: Text(s.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Riwayat Pengerjaan Timeline
                const Text(
                  'Riwayat Pengerjaan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                history.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    ),
                  ),
                  error: (e, _) => const Text('Gagal memuat riwayat.',
                      style: TextStyle(color: Colors.white38)),
                  data: (list) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < list.length; i++) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: hStatusColor(list[i].newStatus)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.circle,
                                size: 10,
                                color: hStatusColor(list[i].newStatus),
                              ),
                            ),
                            title: Text(
                              list[i].oldStatus == null
                                  ? list[i].newStatus.label
                                  : '${list[i].oldStatus!.label} → ${list[i].newStatus.label}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '${list[i].updatedByName} · ${dateFmt.format(list[i].createdAt)}'
                              '${(list[i].notes ?? '').isNotEmpty ? '\n${list[i].notes}' : ''}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  height: 1.4),
                            ),
                          ),
                          if (i < list.length - 1)
                            const Divider(color: Colors.white10, height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Warna Status Riwayat untuk Dark Mode
  Color hStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.selesai:
        return const Color(0xFF81C784);
      case OrderStatus.dibatalkan:
      case OrderStatus.tertunda:
        return const Color(0xFFE57373);
      case OrderStatus.sedangDiproses:
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFFFFB74D);
    }
  }

  Widget _row(String k, String v) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );

  void _showQr(BuildContext context, Order o) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('QR ${o.orderNumber}',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 220,
                height: 220,
                child: QrImageView(
                  data: qrPayloadFor(o.id),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(
      BuildContext context, WidgetRef ref, Order o, OrderStatus s) async {
    final notesCtl = TextEditingController();
    final needsNote = s == OrderStatus.tertunda || s == OrderStatus.dibatalkan;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubah ke "${s.label}"?',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: notesCtl,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: needsNote ? 'Catatan (wajib)' : 'Catatan (opsional)',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (needsNote && notesCtl.text.trim().isEmpty) return;
              Navigator.pop(c, true);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(repositoryProvider).changeStatus(
            o.id,
            s,
            notes: notesCtl.text.trim().isEmpty ? null : notesCtl.text.trim(),
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE57373),
            content: Text('Ditolak: $e',
                style: const TextStyle(color: Colors.black)),
          ),
        );
      }
    }
  }
}
