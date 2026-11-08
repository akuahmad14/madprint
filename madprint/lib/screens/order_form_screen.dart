import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/providers.dart';
import 'orders_screen.dart' show dateFmt;

/// Form tambah (order == null) atau ubah pesanan. Pop mengembalikan id pesanan.
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key, this.order});
  final Order? order;

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.order?.customerName);
  late final _phone = TextEditingController(text: widget.order?.customerPhone);
  late final _product = TextEditingController(text: widget.order?.productType);
  late final _specs = TextEditingController(text: widget.order?.specifications);
  late final _qty = TextEditingController(text: widget.order?.quantity.toString());
  late final _price = TextEditingController(text: widget.order?.price.toStringAsFixed(0));
  late final _notes = TextEditingController(text: widget.order?.notes);
  DateTime? _deadline;
  bool _saving = false;

  bool get _editing => widget.order != null;

  @override
  void initState() {
    super.initState();
    _deadline = widget.order?.deadline;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _product, _specs, _qty, _price, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1E1E1E),
              primary: Colors.white,
              onPrimary: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1E1E1E),
              primary: Colors.white,
              onPrimary: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (t == null) return;
    setState(() => _deadline = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    try {
      final qty = int.parse(_qty.text.trim());
      final price = double.parse(_price.text.trim());
      final specs = _specs.text.trim().isEmpty ? null : _specs.text.trim();
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      String id;
      if (_editing) {
        id = widget.order!.id;
        await repo.updateOrder(
          id,
          productType: _product.text.trim(),
          specifications: specs,
          quantity: qty,
          price: price,
          deadline: _deadline,
          notes: notes,
        );
      } else {
        id = await repo.createOrder(
          customerName: _name.text.trim(),
          customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          productType: _product.text.trim(),
          specifications: specs,
          quantity: qty,
          price: price,
          deadline: _deadline,
          notes: notes,
        );
      }
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE57373),
            content: Text('Gagal menyimpan: $e', style: const TextStyle(color: Colors.black)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(_editing ? 'Ubah Pesanan' : 'Pesanan Baru')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _name,
                enabled: !_editing,
                style: TextStyle(color: !_editing ? Colors.white : Colors.white38),
                decoration: _inputDecoration('Nama pelanggan'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                enabled: !_editing,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: !_editing ? Colors.white : Colors.white38),
                decoration: _inputDecoration('Nomor telepon'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _product,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Jenis cetakan (mis. Spanduk, Brosur)'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _specs,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Spesifikasi (ukuran, bahan, warna, finishing)'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qty,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Jumlah'),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        return (n == null || n <= 0) ? 'Harus > 0' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Harga (Rp)'),
                      validator: (v) {
                        final n = double.tryParse(v?.trim() ?? '');
                        return (n == null || n < 0) ? 'Tidak valid' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_note_rounded, color: Colors.white54, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _deadline == null ? 'Tenggat belum diatur' : dateFmt.format(_deadline!),
                          style: TextStyle(
                            color: _deadline == null ? Colors.white38 : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _pickDeadline,
                      child: const Text('Atur', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Catatan'),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          _editing ? 'Simpan perubahan' : 'Buat pesanan & SPK',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}