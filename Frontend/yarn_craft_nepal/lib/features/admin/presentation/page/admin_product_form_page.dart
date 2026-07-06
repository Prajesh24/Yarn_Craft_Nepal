import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../catalog/domain/entity/product_entity.dart';
import '../viewmodel/admin_product_viewmodel.dart';

class AdminProductFormPage extends ConsumerStatefulWidget {
  final ProductEntity? product; // null = create mode

  const AdminProductFormPage({super.key, this.product});

  @override
  ConsumerState<AdminProductFormPage> createState() =>
      _AdminProductFormPageState();
}

class _AdminProductFormPageState extends ConsumerState<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _colorsCtrl;
  late String _category;

  XFile? _pickedImage;

  static const List<String> _categories = [
    'Hand-spun Yarn',
    'Pashmina',
    'Hemp',
    'Silk',
    'Wool',
    'Other',
  ];

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: '');
    _locationCtrl = TextEditingController(text: p?.location ?? 'Nepal');
    _priceCtrl = TextEditingController(
      text: p != null ? p.priceNPR.toStringAsFixed(0) : '',
    );
    // Available length in meters — prefill the product's current value on edit.
    _qtyCtrl = TextEditingController(text: p != null ? '${p.stock}' : '');
    // Available colours — comma-separated, prefilled on edit.
    _colorsCtrl = TextEditingController(text: p?.colors.join(', ') ?? '');
    _category = _categories.contains(p?.category) ? p!.category : 'Other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _colorsCtrl.dispose();
    super.dispose();
  }

  /// Parse the comma-separated colours field into a clean, de-duplicated list.
  List<String> _parseColors() {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in _colorsCtrl.text.split(',')) {
      final c = raw.trim();
      if (c.isEmpty) continue;
      final key = c.toLowerCase();
      if (seen.add(key)) result.add(c);
    }
    return result;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF1B6B61)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF1B6B61)),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(adminProductProvider.notifier);
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final colors = _parseColors();

    bool ok;
    if (_isEdit) {
      ok = await vm.updateProduct(
        id: widget.product!.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        category: _category,
        price: price,
        quantity: qty,
        colors: colors,
        imagePath: _pickedImage?.path,
      );
    } else {
      ok = await vm.createProduct(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        category: _category,
        price: price,
        quantity: qty,
        colors: colors,
        imagePath: _pickedImage?.path,
      );
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Product updated.' : 'Product created.'),
          backgroundColor: const Color(0xFF1B6B61),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      Navigator.pop(context, true);
    } else {
      final err = ref.read(adminProductProvider).errorMessage ?? 'Failed.';
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(adminProductProvider).status == AdminProductStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        title: Text(
          _isEdit ? 'Edit Product' : 'New Product',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B6B61),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF1B6B61), width: 1.5),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.product?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  widget.product!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _imagePlaceholder(),
                                ),
                              )
                            : _imagePlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tap to ${_pickedImage != null || widget.product?.imageUrl != null ? 'change' : 'add'} image',
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              _field(
                label: 'Product Name',
                controller: _nameCtrl,
                hint: 'e.g. Organic Cotton Skein',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _field(
                label: 'Description',
                controller: _descCtrl,
                hint: 'Short product description',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              _field(
                label: 'Origin / Location',
                controller: _locationCtrl,
                hint: 'e.g. Bhaktapur Weavers, Nepal',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Category dropdown
              _label('Category'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _inputDecoration('Select category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
              const SizedBox(height: 14),

              _field(
                label: 'Price (NPR)',
                controller: _priceCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if ((double.tryParse(v) ?? -1) < 0) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Available length in meters — set/edited by the admin.
              _field(
                label: 'Available Meters (stock)',
                controller: _qtyCtrl,
                hint: 'e.g. 50',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 6),
              const Text(
                'How many meters of this fabric are in stock. Shown to '
                'customers as "In Stock — N meters available".',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              ),
              const SizedBox(height: 16),

              // Available colours (comma-separated)
              _field(
                label: 'Available Colors',
                controller: _colorsCtrl,
                hint: 'e.g. White, Navy, Brown',
              ),
              const SizedBox(height: 6),
              const Text(
                'Separate colours with commas. Common names get a matching '
                'swatch (White, Navy, Brown, Red, Green, Beige, Grey…).',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B61),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _isEdit ? 'Save Changes' : 'Create Product',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_photo_alternate_outlined,
          color: Color(0xFF1B6B61), size: 36),
      SizedBox(height: 6),
      Text('Add Image',
          style: TextStyle(color: Color(0xFF1B6B61), fontSize: 12)),
    ],
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1B6B61), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: _inputDecoration(hint ?? ''),
          ),
        ],
      );
}
