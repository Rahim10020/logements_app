import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de sélection de fourchette de prix
class PriceRangeSelector extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final Function(double?, double?) onChanged;
  final double min;
  final double max;

  const PriceRangeSelector({
    super.key,
    this.minPrice,
    this.maxPrice,
    required this.onChanged,
    this.min = 20000,
    this.max = 1000000,
  });

  @override
  State<PriceRangeSelector> createState() => _PriceRangeSelectorState();
}

class _PriceRangeSelectorState extends State<PriceRangeSelector> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(
      widget.minPrice ?? widget.min,
      widget.maxPrice ?? widget.max,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${formatter.format(_currentRange.start.toInt())} FCFA',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Text(
              '—',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              '${formatter.format(_currentRange.end.toInt())} FCFA',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _currentRange,
          min: widget.min,
          max: widget.max,
          divisions: 50,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha: 0.2),
          labels: RangeLabels(
            formatter.format(_currentRange.start.toInt()),
            formatter.format(_currentRange.end.toInt()),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentRange = values;
            });
          },
          onChangeEnd: (RangeValues values) {
            widget.onChanged(values.start, values.end);
          },
        ),
      ],
    );
  }
}
