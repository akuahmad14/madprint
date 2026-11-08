import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'repository.dart';

final repositoryProvider = Provider<Repository>((ref) => Repository());

/// Sesi login saat ini (berubah saat login/logout).
final authStateProvider = StreamProvider<AuthState>(
  (ref) => Supabase.instance.client.auth.onAuthStateChange,
);

final profileProvider = FutureProvider<Profile>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(repositoryProvider).fetchMyProfile();
});

final searchProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<OrderStatus?>((ref) => null);

/// Daftar pesanan; dimuat ulang otomatis setiap ada perubahan realtime.
final ordersProvider = StreamProvider.autoDispose<List<Order>>((ref) async* {
  final repo = ref.read(repositoryProvider);
  final search = ref.watch(searchProvider);
  final status = ref.watch(statusFilterProvider);

  yield await repo.fetchOrders(search: search, status: status);
  await for (final _ in repo.orderChanges()) {
    yield await repo.fetchOrders(search: search, status: status);
  }
});

final orderDetailProvider = StreamProvider.autoDispose.family<Order?, String>((ref, id) async* {
  final repo = ref.read(repositoryProvider);
  yield await repo.fetchOrder(id);
  await for (final _ in repo.orderChanges()) {
    yield await repo.fetchOrder(id);
  }
});

final historyProvider = StreamProvider.autoDispose.family<List<StatusHistory>, String>((ref, id) async* {
  final repo = ref.read(repositoryProvider);
  yield await repo.fetchHistory(id);
  await for (final _ in repo.historyChanges(id)) {
    yield await repo.fetchHistory(id);
  }
});

class DashboardStats {
  DashboardStats(this.incoming, this.queue, this.inProgress, this.done, this.late);
  final int incoming, queue, inProgress, done, late;
}

final dashboardProvider = Provider.autoDispose<AsyncValue<DashboardStats>>((ref) {
  final all = ref.watch(allOrdersProvider);
  return all.whenData((orders) {
    int c(bool Function(Order) f) => orders.where(f).length;
    return DashboardStats(
      c((o) => o.status == OrderStatus.diterima),
      c((o) => o.status == OrderStatus.antreanProduksi),
      c((o) => o.status == OrderStatus.sedangDiproses || o.status == OrderStatus.finishing),
      c((o) => o.status == OrderStatus.selesai),
      c((o) => o.isLate),
    );
  });
});

final allOrdersProvider = StreamProvider.autoDispose<List<Order>>((ref) async* {
  final repo = ref.read(repositoryProvider);
  yield await repo.fetchOrders();
  await for (final _ in repo.orderChanges()) {
    yield await repo.fetchOrders();
  }
});