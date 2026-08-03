import 'package:flutter/material.dart';

import '../../../../../data/enums/chart_filter_type.dart';

class ChartFilter extends StatelessWidget {
  final ChartFilterType selectedChartFilter;
  final ValueChanged<ChartFilterType> onChanged;

  const ChartFilter({
    super.key,
    required this.selectedChartFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ChartFilterType>(
      segments: const [
        ButtonSegment(
          value: ChartFilterType.expenses,
          icon: Icon(
            Icons.trending_down_rounded,
            color: Colors.red,
            size: 16,
          ),
        ),
        ButtonSegment(
          value: ChartFilterType.revenue,
          icon: Icon(
            Icons.trending_up_rounded,
            color: Colors.green,
            size: 16,
          ),
        ),
        ButtonSegment(
          value: ChartFilterType.comparison,
          icon: Icon(
            Icons.bar_chart_rounded,
            size: 16,
          ),
        ),
      ],
      selected: {
        selectedChartFilter,
      },
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          EdgeInsets.zero,
        ),
        visualDensity: const VisualDensity(
          horizontal: -4,
          vertical: -4,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStateProperty.all(
          const Size(0, 0),
        ),
        fixedSize: WidgetStateProperty.all(
          const Size(40, 36),
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
