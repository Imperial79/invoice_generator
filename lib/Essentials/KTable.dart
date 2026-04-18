import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/constants.dart';

class KTableColumn {
  final Widget label;
  final bool numeric;
  final String? tooltip;

  KTableColumn({
    required this.label,
    this.numeric = false,
    this.tooltip,
  });
}

class KTableRow {
  final List<Widget> cells;
  final VoidCallback? onTap;

  KTableRow({
    required this.cells,
    this.onTap,
  });
}

class KTable extends StatelessWidget {
  final List<KTableColumn> columns;
  final List<KTableRow> rows;
  final double? dataRowHeight;
  final double? headingRowHeight;
  final bool showCheckboxColumn;

  const KTable({
    super.key,
    required this.columns,
    required this.rows,
    this.dataRowHeight = 75,
    this.headingRowHeight = 60,
    this.showCheckboxColumn = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: KCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - (kPadding * 2),
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 24,
                        showCheckboxColumn: showCheckboxColumn,
                        headingRowHeight: headingRowHeight,
                        dataRowMinHeight: dataRowHeight,
                        dataRowMaxHeight: dataRowHeight,
                        headingRowColor: WidgetStateProperty.all(
                          kColor(context).surfaceContainerHigh,
                        ),
                        columns: columns
                            .map(
                              (c) => DataColumn(
                                label: c.label,
                                numeric: c.numeric,
                                tooltip: c.tooltip,
                              ),
                            )
                            .toList(),
                        rows: rows
                            .map(
                              (r) => DataRow(
                                cells: r.cells
                                    .map((c) => DataCell(c))
                                    .toList(),
                                onSelectChanged: r.onTap != null 
                                  ? (_) => r.onTap!() 
                                  : null,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
