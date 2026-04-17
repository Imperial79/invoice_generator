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
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Helper/date_helper.dart';
import 'package:prime_invoice/Essentials/kField.dart';

class InvoicesListUI extends StatefulWidget {
  const InvoicesListUI({super.key});

  @override
  State<InvoicesListUI> createState() => _InvoicesListUIState();
}

class _InvoicesListUIState extends State<InvoicesListUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> invoices = [];
  final isLoading = ValueNotifier(false);
  final searchQuery = TextEditingController();
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    isLoading.value = true;
    final results = await DatabaseService.instance.getAllInvoices();
    setState(() {
      invoices = results;
    });
    isLoading.value = false;
  }

  List<InvoiceModel> get filteredInvoices {
    return invoices.where((invoice) {
      final query = searchQuery.text.toLowerCase().trim();
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
            date.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  int currentPage = 1;
  static const int itemsPerPage = 8;

  @override
  Widget build(BuildContext context) {
    final filtered = filteredInvoices;
    final totalPages = (filtered.length / itemsPerPage).ceil();
    final paginatedInvoices = filtered
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(
        context,
        title: "All Invoices",
        showBack: false,
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kPadding,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: KField(
                    controller: searchQuery,
                    hintText: "Search by Name, Phone or ID",
                    prefix: const Icon(LucideIcons.search, size: 18),
                    onChanged: (v) => setState(() => currentPage = 1),
                  ),
                ),
                const SizedBox(width: 10),
                _filterButton(
                  icon: LucideIcons.calendarRange,
                  color: selectedDateRange != null
                      ? kColor(context).primary
                      : kColor(context).onSurfaceVariant,
                  isActive: selectedDateRange != null,
                  onTap: () async {
                    final range = await DateHelper.pickDateRange(
                      context,
                      initialDateRange: selectedDateRange,
                    );
                    if (range != null) {
                      setState(() {
                        selectedDateRange = range;
                        currentPage = 1;
                      });
                    }
                  },
                ),
                if (selectedDateRange != null || searchQuery.text.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  _filterButton(
                    icon: LucideIcons.filterX,
                    color: kColor(context).error,
                    onTap: () => setState(() {
                      searchQuery.clear();
                      selectedDateRange = null;
                      currentPage = 1;
                    }),
                  ),
                ],
              ],
            ),
          ),

          // Applied Filters Summary
          if (selectedDateRange != null || searchQuery.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: kPadding,
                right: kPadding,
                bottom: 15,
              ),
              child: Row(
                children: [
                  Label(
                    "Applied Filters:",
                    fontSize: 12,
                    weight: 700,
                    color: kColor(context).onSurfaceVariant,
                  ).regular,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (searchQuery.text.isNotEmpty)
                          _filterChip(
                            "Search: ${searchQuery.text}",
                            onDelete: () => setState(() {
                              searchQuery.clear();
                              currentPage = 1;
                            }),
                          ),
                        if (selectedDateRange != null)
                          _filterChip(
                            "${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}",
                            onDelete: () => setState(() {
                              selectedDateRange = null;
                              currentPage = 1;
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 40,
                          color: kColor(context).onSurfaceVariant,
                        ),
                        height10,
                        Label(
                          "No invoices found",
                          color: kColor(context).onSurfaceVariant,
                        ).regular,
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Responsive.isMobile(context)
                          ? ListView.separated(
                              primary: true,
                              padding: const EdgeInsets.all(kPadding),
                              itemCount: paginatedInvoices.length,
                              separatorBuilder: (context, index) => height15,
                              itemBuilder: (context, index) =>
                                  _buildInvoiceCard(paginatedInvoices[index]),
                            )
                          : _buildTable(paginatedInvoices),
                    ),
                  ),
          ),
          // Pagination Footer
          if (totalPages > 1) _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildTable(List<InvoiceModel> invoices) {
    return Container(
      margin: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(50)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: kColor(context).surfaceContainerHigh,
                border: Border(
                  bottom: BorderSide(
                    color: kColor(context).outlineVariant.withAlpha(50),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _headerLabel("DATE")),
                  Expanded(flex: 2, child: _headerLabel("INVOICE ID")),
                  Expanded(flex: 4, child: _headerLabel("CUSTOMER")),
                  Expanded(flex: 2, child: _headerLabel("TOTAL AMOUNT")),
                  Expanded(flex: 2, child: _headerLabel("ACTIONS")),
                ],
              ),
            ),
            // Table Rows
            Expanded(
              child: ListView.separated(
                itemCount: invoices.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: kColor(context).outlineVariant.withAlpha(50),
                ),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Label(
                            DateFormat('dd MMM yyyy')
                                .format(invoice.invoiceDate ?? DateTime.now()),
                            fontSize: 14,
                            weight: 500,
                          ).regular,
                        ),
                        Expanded(
                          flex: 2,
                          child: Label(
                            invoice.invoiceId,
                            fontSize: 14,
                            weight: 700,
                            color: kColor(context).primary,
                          ).regular,
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Label(
                                invoice.customerName,
                                fontSize: 14,
                                weight: 600,
                              ).regular,
                              Label(
                                invoice.customerPhone,
                                fontSize: 11,
                                color: kColor(context).onSurfaceVariant,
                              ).regular,
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Label(
                            kCurrencyFormat(invoice.grandTotal),
                            fontSize: 16,
                            weight: 900,
                            color: kColor(context).primary,
                          ).title,
                        ),
                        Expanded(
                          flex: 2,
                          child: Wrap(
                            spacing: 8,
                            children: [
                              _actionIcon(
                                LucideIcons.eye,
                                kColor(context).primary,
                                () async {
                                  setState(() =>
                                      loadingInvoiceIds.add(invoice.invoiceId));
                                  try {
                                    await PdfHelper.generateInvoice(invoice);
                                  } finally {
                                    if (mounted) {
                                      setState(() => loadingInvoiceIds
                                          .remove(invoice.invoiceId));
                                    }
                                  }
                                },
                                isLoading: loadingInvoiceIds
                                    .contains(invoice.invoiceId),
                              ),
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
                              _actionIcon(
                                LucideIcons.share2,
                                kColor(context).tertiary,
                                () async {
                                  setState(() =>
                                      loadingInvoiceIds.add(invoice.invoiceId));
                                  try {
                                    await PdfHelper.shareInvoice(invoice);
                                  } finally {
                                    if (mounted) {
                                      setState(() => loadingInvoiceIds
                                          .remove(invoice.invoiceId));
                                    }
                                  }
                                },
                                isLoading: loadingInvoiceIds
                                    .contains(invoice.invoiceId),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerLabel(String text) {
    return Label(
      text,
      fontSize: 12,
      weight: 800,
      color: kColor(context).onSurfaceVariant,
    ).regular;
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageButton(
            LucideIcons.chevronLeft,
            currentPage > 1 ? () => setState(() => currentPage--) : null,
          ),
          const SizedBox(width: 20),
          Label(
            "Page $currentPage of $totalPages",
            fontSize: 14,
            weight: 600,
          ).regular,
          const SizedBox(width: 20),
          _pageButton(
            LucideIcons.chevronRight,
            currentPage < totalPages
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _pageButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: onTap == null
              ? kColor(context).outlineVariant.withAlpha(20)
              : kColor(context).primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap == null
                ? kColor(context).outlineVariant.withAlpha(30)
                : kColor(context).primary.withAlpha(40),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? kColor(context).onSurfaceVariant.withAlpha(100)
              : kColor(context).primary,
        ),
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
                        setState(() => loadingInvoiceIds.add(invoice.invoiceId));
                        try {
                          await PdfHelper.generateInvoice(invoice);
                        } finally {
                          if (mounted) {
                            setState(() => loadingInvoiceIds
                                .remove(invoice.invoiceId));
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
                        final res = await context.push("/create-invoice",
                            extra: invoice);
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
                            setState(() => loadingInvoiceIds
                                .remove(invoice.invoiceId));
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

  Widget _filterButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54, // Match KField height
        width: 54,
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha(25) : kColor(context).surfaceContainerLow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? color.withAlpha(80) : kColor(context).outlineVariant.withAlpha(50),
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _filterChip(String text, {required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: kColor(context).primary.withAlpha(15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kColor(context).primary.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(
            text,
            fontSize: 11,
            weight: 600,
            color: kColor(context).primary,
          ).regular,
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: kColor(context).primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.x,
                size: 10,
                color: kColor(context).primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

