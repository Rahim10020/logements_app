import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de sélection de nombre (chambres, SDB, etc.)
class NumberSelector extends StatelessWidget {
  final String label;
  final int? minValue;
  final int? maxValue;
  final Function(int?, int?) onChanged;
  final int min;
  final int max;
  final bool showRange;

  const NumberSelector({
    super.key,
    required this.label,
    this.minValue,
    this.maxValue,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.showRange = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (showRange) _buildRangeSelector() else _buildMinSelector(),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minimum',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: minValue,
                onChanged: (value) => onChanged(value, maxValue),
                hint: 'Min',
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Text('—', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maximum',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: maxValue,
                onChanged: (value) => onChanged(minValue, value),
                hint: 'Max',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinSelector() {
    return _buildDropdown(
      value: minValue,
      onChanged: (value) => onChanged(value, null),
      hint: 'Minimum',
    );
  }

  Widget _buildDropdown({
    required int? value,
    required Function(int?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(hint),
            ),
            ...List.generate(max - min + 1, (index) {
              final num = min + index;
              return DropdownMenuItem<int>(
                value: num,
                child: Text('$num'),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

