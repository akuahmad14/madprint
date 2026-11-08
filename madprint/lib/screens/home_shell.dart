import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models.dart';
import '../core/providers.dart';
import 'order_detail_screen.dart';
import 'orders_screen.dart';
import 'scan_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// Buka tab Pesanan, opsional dengan filter status (null = semua).
  void _openOrders(OrderStatus? status) {
    ref.read(statusFilterProvider.notifier).state = status;
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E1E1E),
          primary: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      child: profile.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        error: (e, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('Gagal memuat profil.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: const Text('Coba lagi'),
                ),
                TextButton(
                  onPressed: () => Supabase.instance.client.auth.signOut(),
                  child: const Text('Keluar', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
        data: (p) {
          final pages = <Widget>[
            _DashboardPage(profile: p, onOpenOrders: _openOrders),
            OrdersScreen(role: p.role),
            // Kamera hanya menyala saat tab Scan dibuka.
            _index == 2 ? const ScanScreen() : const SizedBox.shrink(),
            _ProfilePage(profile: p),
          ];

          return Scaffold(
            body: SafeArea(child: IndexedStack(index: _index, children: pages)),
            bottomNavigationBar: Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                    _buildNavItem(1, Icons.assignment_outlined, 'Pesanan'),
                    _buildNavItem(2, Icons.qr_code_scanner_rounded, 'Scan'),
                    _buildNavItem(3, Icons.person_outline, 'Profil'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _index == index;
    return InkWell(
      onTap: () => setState(() => _index = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : Colors.white38,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ data home

const _kLate = Color(0xFFE57373);
const _kOk = Color(0xFF81C784);

/// Warna tiap status: dipakai di bar, blok, dan titik agar saling cocok.
const _statusColors = <OrderStatus, Color>{
  OrderStatus.diterima: Color(0xFF90A4AE),
  OrderStatus.antreanProduksi: Color(0xFF7986CB),
  OrderStatus.sedangDiproses: Color(0xFFFFB74D),
  OrderStatus.finishing: Color(0xFFBA68C8),
  OrderStatus.siapDiambil: Color(0xFF4DB6AC),
  OrderStatus.selesai: Color(0xFF81C784),
};

/// Tahap aktif (masuk bar): (status, label).
const _activeStages = <(OrderStatus, String)>[
  (OrderStatus.diterima, 'Diterima'),
  (OrderStatus.antreanProduksi, 'Antrean'),
  (OrderStatus.sedangDiproses, 'Diproses'),
  (OrderStatus.finishing, 'Finishing'),
  (OrderStatus.siapDiambil, 'Siap diambil'),
];

/// Semua blok status (tahap aktif + Selesai).
const _blocks = <(OrderStatus, String)>[
  ..._activeStages,
  (OrderStatus.selesai, 'Selesai'),
];

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Semua angka di Home dihitung dari daftar pesanan (Supabase, realtime).
class _HomeData {
  const _HomeData({
    required this.lateCount,
    required this.dueToday,
    required this.paused,
    required this.counts,
    required this.upcoming,
  });

  final int lateCount;
  final int dueToday;
  final int paused;
  final Map<OrderStatus, int> counts;
  final List<Order> upcoming;

  int get pipelineTotal => _activeStages.fold(0, (sum, s) => sum + (counts[s.$1] ?? 0));

  factory _HomeData.from(List<Order> orders) {
    final now = DateTime.now();
    final active = orders.where((o) => !o.status.isFinal).toList();

    final upcoming = active
        .where((o) => o.status != OrderStatus.siapDiambil && o.deadline != null)
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    return _HomeData(
      lateCount: orders.where((o) => o.isLate).length,
      dueToday: active
          .where((o) =>
              o.status != OrderStatus.siapDiambil &&
              o.deadline != null &&
              !o.isLate &&
              _sameDay(o.deadline!, now))
          .length,
      paused: orders.where((o) => o.status == OrderStatus.tertunda).length,
      counts: {for (final s in _blocks) s.$1: orders.where((o) => o.status == s.$1).length},
      upcoming: upcoming,
    );
  }
}

class _DashboardPage extends ConsumerWidget {
  const _DashboardPage({required this.profile, required this.onOpenOrders});

  final Profile profile;
  final void Function(OrderStatus? status) onOpenOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);

    // Ambil inisial nama
    final nameParts = profile.fullName.trim().split(' ');
    String initials = 'U';
    if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () async => ref.invalidate(allOrdersProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header: logo + nama brand, lalu tanggal, sapaan, dan avatar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 28,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.print_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'MADprint',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now()),
                      style: const TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Halo, ${roleLabel(profile.role)}', // Menggunakan helper roleLabel()
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF2C2C2E),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          orders.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator(color: Colors.white24)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  const Text('Gagal memuat data. Periksa jaringan.', style: TextStyle(color: Colors.white38)),
                  TextButton(
                    onPressed: () => ref.invalidate(allOrdersProvider),
                    child: const Text('Coba lagi', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
            data: (list) => _buildBody(context, _HomeData.from(list)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, _HomeData d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _attentionCard(d),
        const SizedBox(height: 28),

        // Posisi pesanan aktif
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Posisi ${d.pipelineTotal} pesanan aktif',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: _kOk),
                SizedBox(width: 6),
                Text('Langsung', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _pipelineBar(d),
        const SizedBox(height: 16),

        // Blok status (bisa diketuk -> daftar pesanan terfilter)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: [
            for (final s in _blocks) _statusBlock(s.$1, s.$2, d.counts[s.$1] ?? 0),
          ],
        ),

        const SizedBox(height: 32),

        // Tenggat Terdekat Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tenggat terdekat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            TextButton(
              onPressed: () => onOpenOrders(null),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('Lihat semua', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        const Divider(color: Colors.white10, height: 1),
        if (d.upcoming.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Text('Belum ada pesanan dengan tenggat.', style: TextStyle(color: Colors.white54)),
          )
        else
          for (final o in d.upcoming.take(5)) ...[
            _buildOrderItem(context, o),
            const Divider(color: Colors.white10, height: 1),
          ],
        const SizedBox(height: 20),
      ],
    );
  }

  // ---- Perlu perhatian

  Widget _attentionCard(_HomeData d) {
    final hasLate = d.lateCount > 0;
    final tone = hasLate ? _kLate : _kOk;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: tone.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: Icon(hasLate ? Icons.warning_amber_rounded : Icons.check_rounded, color: tone, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                hasLate ? 'Perlu perhatian' : 'Semua terkendali',
                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${d.lateCount}',
                style: TextStyle(
                  fontSize: 56,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  color: hasLate ? tone : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'pesanan lewat tenggat',
                  style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _miniPill(Icons.schedule_rounded, '${d.dueToday}', 'jatuh tempo hari ini')),
              const SizedBox(width: 10),
              Expanded(child: _miniPill(Icons.pause_circle_outline_rounded, '${d.paused}', 'tertunda')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPill(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Bar posisi pesanan aktif (segmen = jumlah pesanan nyata per tahap)

  Widget _pipelineBar(_HomeData d) {
    if (d.pipelineTotal == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)),
      );
    }
    final segments = <Widget>[];
    for (final s in _activeStages) {
      final n = d.counts[s.$1] ?? 0;
      if (n == 0) continue;
      if (segments.isNotEmpty) segments.add(const SizedBox(width: 3));
      segments.add(
        Expanded(
          flex: n,
          child: Tooltip(
            message: '${s.$2}: $n',
            child: GestureDetector(
              onTap: () => onOpenOrders(s.$1),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: _statusColors[s.$1],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: segments);
  }

  // ---- Blok status

  Widget _statusBlock(OrderStatus status, String label, int count) {
    final c = _statusColors[status]!;
    return Material(
      color: c.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onOpenOrders(status),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: c),
                ],
              ),
              Text(
                '$count',
                style: const TextStyle(fontSize: 28, height: 1, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Daftar tenggat

  String _dueText(DateTime due) {
    final now = DateTime.now();
    if (due.isBefore(now)) {
      final diff = now.difference(due);
      return diff.inHours < 24 ? 'Telat ${diff.inHours} jam' : 'Telat ${diff.inDays} hari';
    }
    final jam = DateFormat('HH.mm').format(due);
    if (_sameDay(due, now)) return 'Hari ini $jam';
    if (_sameDay(due, now.add(const Duration(days: 1)))) return 'Besok $jam';
    return '${DateFormat('d MMM', 'id_ID').format(due)} $jam';
  }

  Widget _buildOrderItem(BuildContext context, Order o) {
    final isLate = o.isLate;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id, role: profile.role)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${o.productType} • ${o.quantity} pcs',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.orderNumber,
                    style: const TextStyle(fontSize: 11, color: Colors.white38, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _dueText(o.deadline!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLate ? _kLate : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  o.status.label,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '-';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF2C2C2E),
            child: Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            email,
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            backgroundColor: const Color(0xFF2C2C2E),
            label: Text(roleLabel(profile.role), style: const TextStyle(color: Colors.white70)),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Keluar dari Akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kLate,
              side: const BorderSide(color: Colors.white10),
            ),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Keluar?'),
                  content: const Text('Anda akan keluar dari akun ini.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _kLate),
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (ok == true) await Supabase.instance.client.auth.signOut();
            },
          ),
        ),
      ],
    );
  }
}