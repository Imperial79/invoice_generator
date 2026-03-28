import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Helper/responsive.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> recentInvoices = [];
  double totalInvoicedNum = 0;
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final invoices = await DatabaseService.instance.getAllInvoices();
      double total = 0;
      for (var inv in invoices) {
        total += inv.grandTotal;
      }
      if (mounted) {
        setState(() {
          recentInvoices = invoices.take(5).toList();
          totalInvoicedNum = total;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: DatabaseService.hasWriteIssue,
                builder: (context, hasIssue, _) {
                  if (!hasIssue || Responsive.isMobile(context)) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: .3),
                      ),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        Expanded(
                          child: Label(
                            "Drive '${DatabaseService.driveName}' is Read-Only (NTFS). Data is being saved to Local Storage instead.",
                            color: Colors.red,
                            fontSize: 12,
                            weight: 600,
                          ).regular,
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildHeader(),
              if (Responsive.isMobile(context)) ...[
                _buildSummary(),
                _buildActions(),
                _buildRecentInvoicesHeader(),
                _buildRecentInvoicesList(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 30,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [_buildSummary(), _buildActions()],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecentInvoicesHeader(),
                          _buildRecentInvoicesList(),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(
              "Welcome back,",
              fontSize: 14,
              color: kColor(context).onSurfaceVariant,
            ).regular,
            Label(
              "Sujit Verma",
              fontSize: Responsive.isMobile(context) ? 24 : 32,
              weight: 700,
            ).title,
            const SizedBox(height: 5),
            ValueListenableBuilder<String>(
              valueListenable: DatabaseService.storageType,
              builder: (context, type, _) {
                final isPortable = type == "Portable Drive";
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPortable ? Colors.green : Colors.orange)
                        .withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isPortable ? Colors.green : Colors.orange)
                          .withValues(alpha: .3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(
                        isPortable ? LucideIcons.usb : LucideIcons.hardDrive,
                        size: 12,
                        color: isPortable ? Colors.green : Colors.orange,
                      ),
                      Label(
                        type,
                        fontSize: 10,
                        weight: 600,
                        color: isPortable ? Colors.green : Colors.orange,
                      ).regular,
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        KCard(
          onTap: () => context.push("/setup"),
          radius: 50,
          padding: const EdgeInsets.all(10),
          color: kColor(context).primaryContainer,
          child: Icon(
            LucideIcons.user,
            color: kColor(context).onPrimaryContainer,
            size: Responsive.isMobile(context) ? 24 : 30,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return KCard(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      color: kColor(context).primaryContainer.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Label(
            "Total Invoiced",
            fontSize: 12,
            color: kColor(context).primary,
          ).regular,
          Label(
            kCurrencyFormat(totalInvoicedNum),
            fontSize: 18,
            weight: 700,
          ).title,
        ],
      ),
    );
  }

  Widget _buildActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 12,
        children: [
          _actionButton(
            LucideIcons.plus,
            "Create",
            () async {
              final res = await context.push("/create-invoice");
              if (res == true) _loadData();
            },
            bgColor: kColor(context).primary,
            fgColor: kColor(context).onPrimary,
          ),
          _actionButton(
            LucideIcons.users,
            "Clients",
            () => context.push("/clients"),
          ),
          _actionButton(
            LucideIcons.settings,
            "Setup",
            () => context.push("/setup"),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? bgColor,
    Color? fgColor,
  }) {
    return Column(
      spacing: 5,
      children: [
        KCard(
          radius: 12,
          padding: const EdgeInsets.all(12),
          color: bgColor ?? kColor(context).surfaceContainerLow,
          borderWidth: 1,
          borderColor: kColor(context).outlineVariant,
          onTap: onTap,
          child: Icon(
            icon,
            size: 20,
            color: fgColor ?? kColor(context).onSurface,
          ),
        ),
        Label(label, fontSize: 12).regular,
      ],
    );
  }

  Widget _buildRecentInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label("Recent Invoices", fontSize: 18, weight: 600).title,
        TextButton(
          onPressed: () => context.push("/invoices"),
          child: Label(
            "See All",
            color: kColor(context).primary,
            fontSize: 14,
          ).regular,
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesList() {
    if (recentInvoices.isEmpty) {
      return KCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        color: kColor(context).surfaceContainerLow,
        borderWidth: 1,
        borderColor: kColor(context).outlineVariant,
        child: Column(
          spacing: 10,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 40,
              color: kColor(context).onSurfaceVariant,
            ),
            Label(
              "No invoices found",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentInvoices.length,
      separatorBuilder: (context, index) => height15,
      itemBuilder: (context, index) {
        final invoice = recentInvoices[index];
        return KCard(
          padding: const EdgeInsets.all(15),
          borderWidth: 1,
          radius: 15,
          child: Row(
            spacing: 15,
            children: [
              KCard(
                radius: 10,
                height: 50,
                width: 50,
                padding: EdgeInsets.zero,
                color: kColor(context).primaryContainer,
                child: Center(
                  child: Label(
                    "PDF",
                    fontSize: 10,
                    color: kColor(context).onPrimaryContainer,
                  ).title,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Label(invoice.invoiceId, fontSize: 16, weight: 600).regular,
                    Label(
                      "${invoice.customerName} - ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate ?? DateTime.now())}",
                      fontSize: 12,
                      color: kColor(context).onSurfaceVariant,
                    ).regular,
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  Label(
                    kCurrencyFormat(invoice.grandTotal),
                    fontSize: 16,
                    weight: 700,
                  ).title,
                  if (!loadingInvoiceIds.contains(invoice.invoiceId))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
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
                            } catch (e) {
                              KSnackbar(
                                context,
                                message: "Unable to generate PDF!",
                                error: true,
                              );
                            } finally {
                              if (mounted) {
                                setState(
                                  () => loadingInvoiceIds.remove(
                                    invoice.invoiceId,
                                  ),
                                );
                              }
                            }
                          },
                          isLoading: loadingInvoiceIds.contains(
                            invoice.invoiceId,
                          ),
                        ),
                        _actionIcon(
                          LucideIcons.pencil,
                          kColor(context).secondary,
                          () async {
                            final res = await context.push(
                              "/create-invoice",
                              extra: invoice,
                            );
                            if (res == true) _loadData();
                          },
                        ),
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
                                  () => loadingInvoiceIds.remove(
                                    invoice.invoiceId,
                                  ),
                                );
                              }
                            }
                          },
                          isLoading: loadingInvoiceIds.contains(
                            invoice.invoiceId,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(width: 50, child: LinearProgressIndicator()),
                ],
              ),
            ],
          ),
        );
      },
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
          color: color.withValues(alpha: .1),
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
}
