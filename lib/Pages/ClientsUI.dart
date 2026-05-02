import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';
import 'package:prime_invoice/Pages/CustomerDetailUI.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Essentials/KFilterBar.dart';
import 'package:prime_invoice/Essentials/KTable.dart';

class ClientsUI extends StatefulWidget {
  const ClientsUI({super.key});

  @override
  State<ClientsUI> createState() => _ClientsUIState();
}

class _ClientsUIState extends State<ClientsUI> {
  List<CustomerModel> allCustomers = [];
  List<CustomerModel> filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  final isLoading = ValueNotifier(false);

  String selectedType = "All";
  final List<String> clientTypes = ["All", "Customer", "Business"];
  int currentPage = 0;
  static const int itemsPerPage = 8;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    isLoading.value = true;
    try {
      final customers = await DatabaseService.instance.getAllCustomers();
      if (mounted) {
        setState(() {
          allCustomers = customers;
          _applyFilter();
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    setState(() {
      filteredCustomers = allCustomers.where((c) {
        final matchesSearch =
            c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.phone.contains(searchQuery);
        final matchesType =
            selectedType == "All" || c.clientType == selectedType;
        return matchesSearch && matchesType;
      }).toList();

      // Reset to first page when filtering
      if (currentPage >= (filteredCustomers.length / itemsPerPage).ceil() &&
          filteredCustomers.isNotEmpty) {
        currentPage = 0;
      }
    });
  }

  Future<void> _handleSaveCustomer({
    CustomerModel? customer,
    required String name,
    required String phone,
    required String address,
    required String gst,
    required String pan,
    required String aadhaar,
    required String clientType,
  }) async {
    try {
      final newCustomer = (customer ?? CustomerModel(name: "", phone: ""))
          .copyWith(
            name: name,
            phone: phone,
            address: address,
            gst: gst,
            pan: pan,
            aadhaar: aadhaar,
            clientType: clientType,
          );
      await DatabaseService.instance.saveCustomer(newCustomer);
      _loadCustomers();
      KSnackbar(context, message: "Client saved successfully");
    } catch (e) {
      log("Save Client: [Error] -> $e");
      KSnackbar(context, message: "Unable to save client", error: true);
    }
  }

  Future<void> _showAddEditCustomerSidebar([CustomerModel? customer]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final addressController = TextEditingController(text: customer?.address);
    final gstController = TextEditingController(text: customer?.gst);
    final panController = TextEditingController(text: customer?.pan);
    final aadhaarController = TextEditingController(text: customer?.aadhaar);
    String clientType = customer?.clientType ?? "Customer";

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width > 600
                    ? 500
                    : MediaQuery.of(context).size.width * 0.9,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: kColor(context).surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 30,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setDialogState) => Column(
                    children: [
                      // Sidebar Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: kColor(
                                context,
                              ).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColor(context).primary.withAlpha(20),
                                borderRadius: kRadius(12),
                              ),
                              child: Icon(
                                customer == null
                                    ? LucideIcons.userPlus
                                    : LucideIcons.userCheck,
                                color: kColor(context).primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Label(
                                    customer == null
                                        ? "Add New Client"
                                        : "Edit Client Details",
                                    fontSize: 20,
                                    weight: 800,
                                  ).title,
                                  Label(
                                    customer == null
                                        ? "Register a new contact"
                                        : "Update existing contact information",
                                    fontSize: 12,
                                    color: kColor(context).onSurfaceVariant,
                                  ).regular,
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(LucideIcons.x),
                            ),
                          ],
                        ),
                      ),

                      // Sidebar Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(
                                        value: "Customer",
                                        label: Text("Customer"),
                                        icon: Icon(LucideIcons.user, size: 16),
                                      ),
                                      ButtonSegment(
                                        value: "Business",
                                        label: Text("Business"),
                                        icon: Icon(
                                          LucideIcons.building,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                    selected: {clientType},
                                    onSelectionChanged: (val) {
                                      setDialogState(
                                        () => clientType = val.first,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _buildSectionHeader("PRIMARY CONTACT"),
                                const SizedBox(height: 20),
                                KField(
                                  controller: nameController,
                                  autoFocus: true,
                                  label: clientType == "Business"
                                      ? "Business Legal Name"
                                      : "Customer Full Name",
                                  hintText: clientType == "Business"
                                      ? "e.g. Acme Gems Pvt Ltd"
                                      : "Enter legal name",
                                  validator: KValidation.required,
                                  prefix: Icon(
                                    clientType == "Business"
                                        ? LucideIcons.building
                                        : LucideIcons.user,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                KField(
                                  controller: phoneController,
                                  label: "Contact Number",
                                  hintText: "10-digit mobile number",
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  validator: KValidation.phone,
                                  prefix: const Icon(
                                    LucideIcons.phone,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _buildSectionHeader("TAX & IDENTITY"),
                                const SizedBox(height: 20),
                                if (clientType == "Business") ...[
                                  KField(
                                    controller: gstController,
                                    label: "GSTIN Number",
                                    hintText: "Optional (e.g. 22AAAAA0000A1Z5)",
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    prefix: const Icon(
                                      LucideIcons.fingerprint,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Row(
                                  children: [
                                    Expanded(
                                      child: KField(
                                        controller: panController,
                                        label: "PAN Card",
                                        hintText: "Optional",
                                        textCapitalization:
                                            TextCapitalization.characters,
                                      ),
                                    ),
                                    if (clientType == "Customer") ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: KField(
                                          controller: aadhaarController,
                                          label: "Aadhaar",
                                          hintText: "Optional",
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 40),
                                _buildSectionHeader("INVOICING ADDRESS"),
                                const SizedBox(height: 20),
                                KField(
                                  controller: addressController,
                                  label: "Billing Address",
                                  hintText: "Complete address for tax invoices",
                                  maxLines: 4,
                                  prefix: const Icon(
                                    LucideIcons.mapPin,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Sidebar Footer
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: kColor(context).surfaceContainerLow,
                          border: Border(
                            top: BorderSide(
                              color: kColor(
                                context,
                              ).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: kRadius(15),
                                  ),
                                ),
                                child: Label("Cancel", weight: 700).regular,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await _handleSaveCustomer(
                                      customer: customer,
                                      name: nameController.text,
                                      phone: phoneController.text,
                                      address: addressController.text,
                                      gst: gstController.text,
                                      pan: panController.text,
                                      aadhaar: aadhaarController.text,
                                      clientType: clientType,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kColor(context).primary,
                                  foregroundColor: kColor(context).onPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: kRadius(15),
                                  ),
                                ),
                                child: Label(
                                  "Save Client",
                                  weight: 700,
                                ).regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(
          title,
          fontSize: 13,
          weight: 700,
          color: kColor(context).primary,
        ).regular,
        const SizedBox(height: 4),
        Divider(
          color: kColor(context).outlineVariant.withAlpha(100),
          thickness: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Client Management", showBack: false),
      body: Column(
        children: [
          KFilterBar(
            configs: [
              FilterConfig(
                id: "search",
                label: "Search by name or phone...",
                isSearch: true,
                initialValue: searchQuery,
              ),
              FilterConfig(
                id: "type",
                label: "Client Type",
                options: clientTypes,
                initialValue: selectedType,
              ),
            ],
            selectedFilters: {"search": searchQuery, "type": selectedType},
            onFilterChanged: (id, value) {
              setState(() {
                if (id == "search") {
                  searchQuery = value;
                  _searchController.text = value;
                } else {
                  selectedType = value;
                }
                _applyFilter();
              });
            },
            onClearAll: () {
              setState(() {
                searchQuery = "";
                _searchController.clear();
                selectedType = "All";
                _applyFilter();
              });
            },
            action: ElevatedButton.icon(
              onPressed: () => _showAddEditCustomerSidebar(),
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: Label("Add Client", weight: 700).regular,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                backgroundColor: kColor(context).primary,
                foregroundColor: kColor(context).onPrimary,
                shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
              ),
            ),
          ),
          Expanded(child: _buildMainContent()),
          if (filteredCustomers.isNotEmpty && !Responsive.isMobile(context))
            _buildPaginationFooter(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 64,
              color: kColor(context).outlineVariant,
            ),
            const SizedBox(height: 16),
            Label("No Clients Found", weight: 700).title,
            Label(
              "Try adjusting your search or filters",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      );
    }

    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.all(kPadding),
        itemCount: filteredCustomers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildCustomerCard(filteredCustomers[index]),
      );
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage) > filteredCustomers.length
        ? filteredCustomers.length
        : startIndex + itemsPerPage;
    final pageItems = filteredCustomers.sublist(startIndex, endIndex);

    return KTable(
      showCheckboxColumn: false,
      columns: [
        KTableColumn(label: Label("SL", weight: 800).regular),
        KTableColumn(label: Label("TYPE", weight: 800).regular),
        KTableColumn(label: Label("CLIENT NAME", weight: 800).regular),
        KTableColumn(label: Label("PHONE", weight: 800).regular),
        KTableColumn(label: Label("TAX / ID DETAILS", weight: 800).regular),
        KTableColumn(label: Label("ACTIONS", weight: 800).regular),
      ],
      rows: pageItems.map((customer) {
        final index =
            (currentPage * itemsPerPage) + pageItems.indexOf(customer) + 1;
        final isBusiness = customer.clientType == "Business";
        return KTableRow(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailUI(customer: customer),
            ),
          ).then((_) => _loadCustomers()),
          cells: [
            Label(index.toString().padLeft(2, '0')).regular,
            _buildClientTypeChip(customer.clientType, isBusiness),
            Label(customer.name, weight: 700).regular,
            Label(customer.phone, weight: 500).regular,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isBusiness && customer.gst.isNotEmpty)
                  Label("GST: ${customer.gst}", fontSize: 11).regular,
                if (customer.pan.isNotEmpty)
                  Label("PAN: ${customer.pan}", fontSize: 11).regular,
                if (!isBusiness && customer.aadhaar.isNotEmpty)
                  Label("AADHAAR: ${customer.aadhaar}", fontSize: 11).regular,
                if (customer.gst.isEmpty &&
                    customer.pan.isEmpty &&
                    customer.aadhaar.isEmpty)
                  Label(
                    "Not Provided",
                    fontSize: 11,
                    color: kColor(context).onSurfaceVariant,
                  ).regular,
              ],
            ),
            Row(
              children: [
                _actionIconButton(
                  LucideIcons.pencil,
                  kColor(context).secondary,
                  () => _showAddEditCustomerSidebar(customer),
                ),
                const SizedBox(width: 8),
                _actionIconButton(
                  LucideIcons.chevronRight,
                  kColor(context).primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailUI(customer: customer),
                    ),
                  ).then((_) => _loadCustomers()),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPaginationFooter() {
    final totalPages = (filteredCustomers.length / itemsPerPage).ceil();
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
            "Showing ${currentPage * itemsPerPage + 1} to ${((currentPage + 1) * itemsPerPage).clamp(0, filteredCustomers.length)} of ${filteredCustomers.length} entries",
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
                  borderRadius: kRadius(8),
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

  Widget _actionIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: kRadius(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    final isBusiness = customer.clientType == "Business";
    return KCard(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailUI(customer: customer),
          ),
        );
        _loadCustomers();
      },
      padding: const EdgeInsets.all(18),
      color: kColor(context).surfaceContainerLow,
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: isBusiness
                  ? kColor(context).secondary.withAlpha(20)
                  : kColor(context).primary.withAlpha(20),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: isBusiness
                    ? kColor(context).secondary.withAlpha(40)
                    : kColor(context).primary.withAlpha(40),
              ),
            ),
            child: Center(
              child: Icon(
                isBusiness ? LucideIcons.building2 : LucideIcons.user,
                color: isBusiness
                    ? kColor(context).secondary
                    : kColor(context).primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Label(
                        customer.name,
                        fontSize: 16,
                        weight: 700,
                      ).regular,
                    ),
                    const SizedBox(width: 8),
                    _buildClientTypeChip(customer.clientType, isBusiness),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.phone,
                      size: 13,
                      color: kColor(context).onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Label(
                      customer.phone,
                      fontSize: 13,
                      color: kColor(context).onSurfaceVariant,
                    ).regular,
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.pencil,
              size: 18,
              color: kColor(context).onSurfaceVariant,
            ),
            onPressed: () => _showAddEditCustomerSidebar(customer),
            visualDensity: VisualDensity.compact,
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: kColor(context).outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildClientTypeChip(String type, bool isBusiness) {
    final color = isBusiness
        ? kColor(context).secondary
        : kColor(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: kRadius(6),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Label(
        type.toUpperCase(),
        fontSize: 9,
        weight: 800,
        color: color,
      ).regular,
    );
  }
}
