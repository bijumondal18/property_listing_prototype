import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/property_filters.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onReset,
  });

  final PropertyFilters initialFilters;
  final ValueChanged<PropertyFilters> onApply;
  final VoidCallback onReset;

  static Future<void> show(
    BuildContext context, {
    required PropertyFilters initialFilters,
    required ValueChanged<PropertyFilters> onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        initialFilters: initialFilters,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _location;
  late String? _propertyType;
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  late String? _status;
  late int? _bedrooms;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _location = f.location;
    _propertyType = f.propertyType;
    _priceRange = RangeValues(f.minPrice, f.maxPrice);
    _areaRange = RangeValues(f.minArea, f.maxArea);
    _status = f.status;
    _bedrooms = f.bedrooms;
  }

  void _resetLocal() {
    setState(() {
      _location = null;
      _propertyType = null;
      _priceRange = const RangeValues(
        PropertyFilters.defaultMinPrice,
        PropertyFilters.defaultMaxPrice,
      );
      _areaRange = const RangeValues(
        PropertyFilters.defaultMinArea,
        PropertyFilters.defaultMaxArea,
      );
      _status = null;
      _bedrooms = null;
    });
  }

  void _applyAndClose() {
    final filters = PropertyFilters(
      location: _location,
      propertyType: _propertyType,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minArea: _areaRange.start,
      maxArea: _areaRange.end,
      status: _status,
      bedrooms: _bedrooms,
    );
    Navigator.pop(context);
    // Apply after the sheet has closed so the parent Scaffold is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onApply(filters);
    });
  }

  void _resetApplyAndClose() {
    _resetLocal();
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: sheetHeight,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filters',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resetApplyAndClose,
                      child: const Text('Reset Filters'),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Location',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _location,
                      decoration: const InputDecoration(
                        hintText: 'All locations',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...AppConstants.locations.map(
                          (loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _location = value),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Property Type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _propertyType == null,
                          onSelected: (_) =>
                              setState(() => _propertyType = null),
                        ),
                        ...AppConstants.propertyTypes.map(
                          (type) => ChoiceChip(
                            label: Text(type),
                            selected: _propertyType == type,
                            onSelected: (_) =>
                                setState(() => _propertyType = type),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Price Range',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.formatCompactPrice(_priceRange.start)} — ${Formatters.formatCompactPrice(_priceRange.end)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: PropertyFilters.defaultMinPrice,
                      max: PropertyFilters.defaultMaxPrice,
                      divisions: 36,
                      labels: RangeLabels(
                        Formatters.formatCompactPrice(_priceRange.start),
                        Formatters.formatCompactPrice(_priceRange.end),
                      ),
                      onChanged: (values) =>
                          setState(() => _priceRange = values),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Area Range',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_areaRange.start.toInt()} sq.ft — ${_areaRange.end.toInt()} sq.ft',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RangeSlider(
                      values: _areaRange,
                      min: PropertyFilters.defaultMinArea,
                      max: PropertyFilters.defaultMaxArea,
                      divisions: 25,
                      labels: RangeLabels(
                        '${_areaRange.start.toInt()}',
                        '${_areaRange.end.toInt()}',
                      ),
                      onChanged: (values) =>
                          setState(() => _areaRange = values),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _status == null,
                          onSelected: (_) => setState(() => _status = null),
                        ),
                        ...AppConstants.statuses.map(
                          (status) => ChoiceChip(
                            label: Text(status),
                            selected: _status == status,
                            onSelected: (_) =>
                                setState(() => _status = status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Configuration',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Any'),
                          selected: _bedrooms == null,
                          onSelected: (_) => setState(() => _bedrooms = null),
                        ),
                        ...AppConstants.bedroomOptions.map(
                          (beds) => ChoiceChip(
                            label: Text('$beds BHK'),
                            selected: _bedrooms == beds,
                            onSelected: (_) =>
                                setState(() => _bedrooms = beds),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: FilledButton(
                    onPressed: _applyAndClose,
                    child: const Text('Apply Filters'),
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
