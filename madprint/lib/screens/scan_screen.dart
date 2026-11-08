import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/providers.dart';
import '../core/repository.dart';
import 'order_detail_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _busy = true;
    try {
      final id = parseQrPayload(raw);
      if (id == null) {
        _msg('QR tidak valid: bukan SPK PrintTrack.');
        return;
      }
      final order = await ref.read(repositoryProvider).fetchOrder(id);
      if (order == null) {
        _msg('SPK tidak ditemukan atau Anda tidak berhak mengaksesnya.');
        return;
      }
      final role = (await ref.read(profileProvider.future)).role;
      if (!mounted) return;
      await _controller.stop();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id, role: role)),
      );
      if (mounted) await _controller.start();
    } catch (_) {
      _msg('Gagal memproses QR. Periksa jaringan lalu coba lagi.');
    } finally {
      // jeda singkat agar QR yang sama tidak langsung terbaca ulang
      await Future<void>.delayed(const Duration(seconds: 1));
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Kamera tidak dapat dibuka (${error.errorCode.name}). '
                'Pastikan izin kamera diberikan di pengaturan.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Text(
            'Arahkan kamera ke QR Code pada SPK',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ),
      ],
    );
  }
}
