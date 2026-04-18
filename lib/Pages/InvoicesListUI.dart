import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Helper/date_helper.dart';

import 'package:prime_invoice/Essentials/KFilterBar.dart';
import 'package:prime_invoice/Essentials/KTable.dart';

class InvoicesListUI extends StatefulWidget {
  const InvoicesListUI({super.key});

  @override
  State<InvoicesListUI> createState() => _InvoicesListUIState();
}

class _InvoicesListUIState extends State<InvoicesListUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> allInvoices = [];
  List<InvoiceModel> filteredInvoicesData = [];
  final isLoading = ValueNotifier(false);
  final searchController = TextEditingController();
  DateTimeRange? selectedDateRange;
  String searchQuery = "";
  int currentPage = 0;
  static const int itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    isLoading.value = true;
    try {
      final results = await DatabaseService.instance.getAllInvoices();
      if (mounted) {
        setState(() {
          allInvoices = results;
          _applyFilters();
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    setState(() {
      filteredInvoicesData = allInvoices.where((invoice) {
        final query = searchQuery.toLowerCase().trim();
        final matchesSearch =
            query.isEmpty ||
            invoice.invoiceId.toLowerCase().contains(query) ||
            invoice.customerName.toLowerCase().contains(query) ||
            invoice.customerPhone.toLowerCase().contains(query);

        bool matchesDate = true;
        if (selectedDateRange != null) {
          final date = invoice.invoiceDate ?? DateTime.now();
          matchesDate =
              date.isAfter(
                selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              date.isBefore(
                selectedDateRange!.end.add(const Duration(days: 1)),
              );
        }

        return matchesSearch && matchesDate;
      }).toList();

      if (currentPage >= (filteredInvoicesData.length / itemsPerPage).ceil() &&
          filteredInvoicesData.isNotEmpty) {
        currentPage = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "All Invoices", showBack: false),
      body: Column(
        children: [
          KFilterBar(
            configs: [
              FilterConfig(
                id: "search",
                label: "Search by Name, Phone or ID",
                isSearch: true,
                initialValue: searchQuery,
              ),
              FilterConfig(
                id: "date",
                label: "Date Range",
                custom: (context) => _buildDatePickerButton(context),
              ),
            ],
            selectedFilters: {
              "search": searchQuery,
              "date": selectedDateRange != null
                  ? "${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}"
                  : "",
            },
            onFilterChanged: (id, value) {
              if (id == "search") {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              } else if (id == "date" && value.isEmpty) {
                // Handle clear from tag
                setState(() {
                  selectedDateRange = null;
                  _applyFilters();
                });
              }
            },
            onClearAll: () {
              setState(() {
                searchQuery = "";
                searchController.clear();
                selectedDateRange = null;
                _applyFilters();
              });
            },
          ),
          Expanded(child: _buildMainContent()),
          if (filteredInvoicesData.isNotEmpty && !Responsive.isMobile(context))
            _buildPaginationFooter(),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final range = await DateHelper.pickDateRange(
          context,
          initialDateRange: selectedDateRange,
        );
        if (range != null) {
          setState(() {
            selectedDateRange = range;
            _applyFilters();
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: selectedDateRange != null
              ? kColor(context).primary.withAlpha(20)
              : kColor(context).surfaceContainerLow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedDateRange != null
                ? kColor(context).primary.withAlpha(80)
                : kColor(context).outlineVariant.withAlpha(50),
          ),
        ),
        child: Icon(
          LucideIcons.calendarRange,
          color: selectedDateRange != null
              ? kColor(context).primary
              : kColor(context).onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (filteredInvoicesData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 64,
              color: kColor(context).outlineVariant,
            ),
            const SizedBox(height: 16),
            Label("No Invoices Found", weight: 700).title,
            Label(
              "Try adjusting your search or date range",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      );
    }

    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.all(kPadding),
        itemCount: filteredInvoicesData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildInvoiceCard(filteredInvoicesData[index]),
      );
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage) > filteredInvoicesData.length
        ? filteredInvoicesData.length
        : startIndex + itemsPerPage;
    final pageItems = filteredInvoicesData.sublist(startIndex, endIndex);

    return KTable(
      showCheckboxColumn: false,
      columns: [
        KTableColumn(label: Label("DATE", weight: 800).regular),
        KTableColumn(label: Label("INVOICE ID", weight: 800).regular),
        KTableColumn(label: Label("CUSTOMER", weight: 800).regular),
        KTableColumn(label: Label("TOTAL AMOUNT", weight: 800).regular),
        KTableColumn(label: Label("ACTIONS", weight: 800).regular),
      ],
      rows: pageItems.map((invoice) {
        return KTableRow(
          cells: [
            Label(
              DateFormat(
                'dd MMM yyyy',
              ).format(invoice.invoiceDate ?? DateTime.now()),
            ).regular,
            Label(
              invoice.invoiceId,
              weight: 700,
              color: kColor(context).primary,
            ).regular,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Label(invoice.customerName, weight: 600).regular,
                Label(
                  invoice.customerPhone,
                  fontSize: 11,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
            Label(
              kCurrencyFormat(invoice.grandTotal),
              weight: 900,
              color: kColor(context).primary,
            ).title,
            Row(
              children: [
                _actionIcon(
                  LucideIcons.eye,
                  kColor(context).primary,
                  () async {
                    setState(() => loadingInvoiceIds.add(invoice.invoiceId));
                    try {
                      await PdfHelper.generateInvoice(invoice);
                    } finally {
                      if (mounted) {
                        setState(
                          () => loadingInvoiceIds.remove(invoice.invoiceId),
                        );
                      }
                    }
                  },
                  isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                ),
                const SizedBox(width: 8),
                _actionIcon(
                  LucideIcons.pencil,
                  kColor(context).secondary,
                  () async {
                    final res = await context.push(
                      "/create-invoice",
                      extra: invoice,
                    );
                    if (res == true) _loadInvoices();
                  },
                ),
                const SizedBox(width: 8),
                _actionIcon(
                  LucideIcons.share2,
                  kColor(context).tertiary,
                  () async {
                    setState(() => loadingInvoiceIds.add(invoice.invoiceId));
                    try {
                      await PdfHelper.shareInvoice(invoice);
                    } finally {
                      if (mounted) {
                        setState(
                          () => loadingInvoiceIds.remove(invoice.invoiceId),
                        );
                      }
                    }
                  },
                  isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPaginationFooter() {
    final totalPages = (filteredInvoicesData.length / itemsPerPage).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kPadding, vertical: 16),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border(
          top: BorderSide(color: kColor(context).outlineVariant.withAlpha(50)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Label(
            "Showing ${currentPage * itemsPerPage + 1} to ${((currentPage + 1) * itemsPerPage).clamp(0, filteredInvoicesData.length)} of ${filteredInvoicesData.length} entries",
            fontSize: 12,
          ).regular,
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 0
                    ? () => setState(() => currentPage--)
                    : null,
                icon: const Icon(LucideIcons.chevronLeft),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kColor(context).primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Label(
                  "Page ${currentPage + 1} of $totalPages",
                  weight: 700,
                  color: kColor(context).primary,
                ).regular,
              ),
              IconButton(
                onPressed: (currentPage + 1) < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
                icon: const Icon(LucideIcons.chevronRight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return KCard(
      padding: const EdgeInsets.all(18),
      color: kColor(context).surfaceContainerLow,
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: kColor(context).primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kColor(context).primary.withAlpha(30)),
            ),
            child: Center(
              child: Icon(
                LucideIcons.fileText,
                size: 20,
                color: kColor(context).primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Label(invoice.invoiceId, fontSize: 16, weight: 700).regular,
                const SizedBox(height: 4),
                Label(
                  "${invoice.customerName} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate ?? DateTime.now())}",
                  fontSize: 12,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Label(
                kCurrencyFormat(invoice.grandTotal),
                fontSize: 18,
                weight: 900,
                color: kColor(context).primary,
              ).title,
              const SizedBox(height: 10),
              if (!loadingInvoiceIds.contains(invoice.invoiceId))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionIcon(
                      LucideIcons.eye,
                      kColor(context).primary,
                      () async {
                        setState(
                          () => loadingInvoiceIds.add(invoice.invoiceId),
                        );
                        try {
                          await PdfHelper.generateInvoice(invoice);
                        } finally {
                          if (mounted) {
                            setState(
                              () => loadingInvoiceIds.remove(invoice.invoiceId),
                            );
                          }
                        }
                      },
                      isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                    ),
                    const SizedBox(width: 8),
                    _actionIcon(
                      LucideIcons.pencil,
                      kColor(context).secondary,
                      () async {
                        final res = await context.push(
                          "/create-invoice",
                          extra: invoice,
                        );
                        if (res == true) _loadInvoices();
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionIcon(
                      LucideIcons.share2,
                      kColor(context).tertiary,
                      () async {
                        setState(
                          () => loadingInvoiceIds.add(invoice.invoiceId),
                        );
                        try {
                          await PdfHelper.shareInvoice(invoice);
                        } finally {
                          if (mounted) {
                            setState(
                              () => loadingInvoiceIds.remove(invoice.invoiceId),
                            );
                          }
                        }
                      },
                      isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                    ),
                  ],
                )
              else
                const SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
