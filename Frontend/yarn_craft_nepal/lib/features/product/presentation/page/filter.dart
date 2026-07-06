import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/viewmodel/product_filter_viewmodel.dart';

/// Opens the filter & sort sheet, wired to [productFilterProvider].
/// [categories] are the real product categories (without the 'All' entry).
Future<void> showFilterSheet(BuildContext context, List<String> categories) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FilterSortSheet(categories: categories),
  );
}

class FilterSortSheet extends ConsumerStatefulWidget {
  final List<String> categories;
  const FilterSortSheet({super.key, required this.categories});

  @override
  ConsumerState<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends ConsumerState<FilterSortSheet> {
  final Map<String, bool> _expanded = {
    'Material': true,
    'Origin': true,
    'Color Family': true,
    'Usage': true,
    'Price Range': true,
  };

  // Selected categories (Material chips). Initialised from the active filter.
  final Set<String> _selMaterials = {};

  final List<String> _origins = ['Nepal', 'India'];
  final Set<String> _selOrigins = {'India'};

  final List<Color> _colorOptions = [
    Colors.white,
    const Color(0xFF1C1C1C),
    const Color(0xFFA0522D),
    const Color(0xFF1B6B61),
    const Color(0xFFDC2626),
    const Color(0xFFF97316),
  ];
  final Set<int> _selColors = {0, 2};

  final List<String> _usages = [
    'Clothing & Apparel',
    'Home Decor',
    'Crafting & Weaving',
  ];
  final Set<String> _selUsage = {'Clothing & Apparel', 'Crafting & Weaving'};

  RangeValues _priceRange = const RangeValues(0, ProductFilter.priceCeil);
  final _minCtrl = TextEditingController(text: '0');
  final _maxCtrl = TextEditingController(text: '20000');

  @override
  void initState() {
    super.initState();
    final f = ref.read(productFilterProvider);
    _selMaterials.addAll(f.categories);
    _priceRange = RangeValues(f.minPrice, f.maxPrice);
    _minCtrl.text = f.minPrice.round().toString();
    _maxCtrl.text = f.maxPrice.round().toString();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selMaterials.clear();
      _selOrigins.clear();
      _selColors.clear();
      _selUsage.clear();
      _priceRange = const RangeValues(0, ProductFilter.priceCeil);
      _minCtrl.text = '0';
      _maxCtrl.text = ProductFilter.priceCeil.round().toString();
    });
  }

  void _apply() {
    ref
        .read(productFilterProvider.notifier)
        .apply(
          categories: {..._selMaterials},
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF1B6B61),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable sections
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Material
                  _Section(
                    title: 'Material',
                    expanded: _expanded['Material']!,
                    onToggle: () => setState(
                      () => _expanded['Material'] = !_expanded['Material']!,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories
                          .map(
                            (m) => _Chip(
                              label: m,
                              selected: _selMaterials.contains(m),
                              onTap: () => setState(
                                () => _selMaterials.contains(m)
                                    ? _selMaterials.remove(m)
                                    : _selMaterials.add(m),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const _Div(),

                  // Origin
                  _Section(
                    title: 'Origin',
                    expanded: _expanded['Origin']!,
                    onToggle: () => setState(
                      () => _expanded['Origin'] = !_expanded['Origin']!,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _origins
                          .map(
                            (o) => _Chip(
                              label: o,
                              selected: _selOrigins.contains(o),
                              onTap: () => setState(
                                () => _selOrigins.contains(o)
                                    ? _selOrigins.remove(o)
                                    : _selOrigins.add(o),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const _Div(),

                  // Color Family
                  _Section(
                    title: 'Color Family',
                    expanded: _expanded['Color Family']!,
                    onToggle: () => setState(
                      () => _expanded['Color Family'] =
                          !_expanded['Color Family']!,
                    ),
                    child: Row(
                      children: List.generate(_colorOptions.length, (i) {
                        final sel = _selColors.contains(i);
                        final isWhite = _colorOptions[i] == Colors.white;
                        return GestureDetector(
                          onTap: () => setState(
                            () =>
                                sel ? _selColors.remove(i) : _selColors.add(i),
                          ),
                          child: Container(
                            width: 42,
                            height: 42,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _colorOptions[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF1B6B61)
                                    : isWhite
                                    ? const Color(0xFFD1D5DB)
                                    : Colors.transparent,
                                width: sel ? 2.5 : 1.5,
                              ),
                            ),
                            child: sel
                                ? Icon(
                                    Icons.check_rounded,
                                    color: isWhite
                                        ? const Color(0xFF1B6B61)
                                        : Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),

                  const _Div(),

                  // Usage
                  _Section(
                    title: 'Usage',
                    expanded: _expanded['Usage']!,
                    onToggle: () => setState(
                      () => _expanded['Usage'] = !_expanded['Usage']!,
                    ),
                    child: Column(
                      children: _usages.map((u) {
                        final sel = _selUsage.contains(u);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(
                              () =>
                                  sel ? _selUsage.remove(u) : _selUsage.add(u),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: sel,
                                    onChanged: (_) => setState(
                                      () => sel
                                          ? _selUsage.remove(u)
                                          : _selUsage.add(u),
                                    ),
                                    activeColor: const Color(0xFF1B6B61),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1.5,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  u,
                                  style: TextStyle(
                                    color: sel
                                        ? const Color(0xFF111827)
                                        : const Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: sel
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const _Div(),

                  // Price Range
                  _Section(
                    title: 'Price Range (NPR)',
                    expanded: _expanded['Price Range']!,
                    onToggle: () => setState(
                      () =>
                          _expanded['Price Range'] = !_expanded['Price Range']!,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Min Price',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _PriceBox(
                                    controller: _minCtrl,
                                    onChanged: (v) {
                                      final n = double.tryParse(v);
                                      if (n != null && n < _priceRange.end) {
                                        setState(
                                          () => _priceRange = RangeValues(
                                            n,
                                            _priceRange.end,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Max Price',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _PriceBox(
                                    controller: _maxCtrl,
                                    onChanged: (v) {
                                      final n = double.tryParse(v);
                                      if (n != null && n > _priceRange.start) {
                                        setState(
                                          () => _priceRange = RangeValues(
                                            _priceRange.start,
                                            n,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF1B6B61),
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                            thumbColor: const Color(0xFF1B6B61),
                            overlayColor: const Color(
                              0xFF1B6B61,
                            ).withOpacity(0.12),
                            trackHeight: 3,
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 20000,
                            divisions: 200,
                            onChanged: (v) => setState(() {
                              _priceRange = v;
                              _minCtrl.text = v.start.round().toString();
                              _maxCtrl.text = v.end.round().toString();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6B61),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section

class _Section extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _Section({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
          if (expanded) ...[const SizedBox(height: 12), child],
        ],
      ),
    );
  }
}

// Toggle chip

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B6B61) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1B6B61) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Divider

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) => const Divider(
    color: Color(0xFFE5E7EB),
    height: 1,
    indent: 20,
    endIndent: 20,
  );
}

// Price input box

class _PriceBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PriceBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1B6B61), width: 1.5),
        ),
      ),
    );
  }
}
