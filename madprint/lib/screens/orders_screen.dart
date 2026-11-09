import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/providers.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final filter = ref.watch(statusFilterProvider);

    return Scaffold(
      floatingActionButton: role == UserRole.admin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Pesanan baru'),
              onPressed: () async {
                final id = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderFormScreen()),
                );
                if (id != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id, role: role)),
                  );
                }
              },
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nomor SPK atau pelanggan',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => ref.read(searchProvider.notifier).state = v,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: filter == null,
                    onSelected: (_) => ref.read(statusFilterProvider.notifier).state = null,
                  ),
                ),
                for (final s in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(s.label),
                      selected: filter == s,
                      onSelected: (_) => ref.read(statusFilterProvider.notifier).state = s,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: orders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Gagal memuat pesanan. Periksa jaringan.'),
                  TextButton(onPressed: () => ref.invalidate(ordersProvider), child: const Text('Coba lagi')),
                ]),
              ),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Belum ada pesanan.'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final o = list[i];
                        return ListTile(
                          title: Text('${o.orderNumber} · ${o.customerName}'),
                          subtitle: Text(
                            '${o.productType} · ${o.quantity} pcs'
                            '${o.deadline != null ? '\nTenggat ${dateFmt.format(o.deadline!)}' : ''}',
                          ),
                          isThreeLine: o.deadline != null,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusChip(o.status),
                              if (o.isLate)
                                const Text('Terlambat', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id, role: role)),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status.label,
            style: TextStyle(color: status.color, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}
