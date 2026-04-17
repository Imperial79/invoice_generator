import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';
import 'package:prime_invoice/Pages/CustomerDetailUI.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Essentials/KField.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
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
          filteredCustomers = customers;
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = allCustomers.where((c) {
        return c.name.toLowerCase().contains(query) || c.phone.contains(query);
      }).toList();
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
                width: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: kColor(context).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColor(context).primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                customer == null ? LucideIcons.userPlus : LucideIcons.userCheck,
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
                                    customer == null ? "Add New Client" : "Edit Client Details",
                                    fontSize: 20,
                                    weight: 800,
                                  ).title,
                                  Label(
                                    customer == null ? "Register a new business contact" : "Update existing contact information",
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
                                        label: Text("Individual"),
                                        icon: Icon(LucideIcons.user, size: 16),
                                      ),
                                      ButtonSegment(
                                        value: "Company",
                                        label: Text("Business"),
                                        icon: Icon(LucideIcons.building, size: 16),
                                      ),
                                    ],
                                    selected: {clientType},
                                    onSelectionChanged: (val) {
                                      setDialogState(() => clientType = val.first);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _buildSectionHeader("PRIMARY CONTACT"),
                                const SizedBox(height: 20),
                                KField(
                                  controller: nameController,
                                  label: clientType == "Company" ? "Company Legal Name" : "Client Full Name",
                                  hintText: clientType == "Company" ? "e.g. Acme Gems Pvt Ltd" : "Enter legal name",
                                  validator: KValidation.required,
                                  prefix: Icon(
                                    clientType == "Company" ? LucideIcons.building : LucideIcons.user,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                KField(
                                  controller: phoneController,
                                  label: "Contact Number",
                                  hintText: "10-digit mobile number",
                                  keyboardType: TextInputType.phone,
                                  validator: KValidation.phone,
                                  prefix: const Icon(LucideIcons.phone, size: 18),
                                ),
                                const SizedBox(height: 40),
                                _buildSectionHeader("TAX & IDENTITY"),
                                const SizedBox(height: 20),
                                if (clientType == "Company") ...[
                                  KField(
                                    controller: gstController,
                                    label: "GSTIN Number",
                                    hintText: "Optional (e.g. 22AAAAA0000A1Z5)",
                                    textCapitalization: TextCapitalization.characters,
                                    prefix: const Icon(LucideIcons.fingerprint, size: 18),
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
                                        textCapitalization: TextCapitalization.characters,
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
                                  prefix: const Icon(LucideIcons.mapPin, size: 18),
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
                              color: kColor(context).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
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
                                    if (context.mounted) Navigator.pop(context, true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kColor(context).primary,
                                  foregroundColor: kColor(context).onPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Label("Save Client", weight: 700).regular,
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

  int currentPage = 1;
  static const int itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCustomers;
    final totalPages = (filtered.length / itemsPerPage).ceil();
    final paginated = filtered
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Client Management", showBack: false),
      body: Column(
        children: [
          _buildFilterRow(),
          _buildAppliedFilters(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: MediaQuery.of(context).size.width < 900
                          ? ListView.separated(
                              padding: const EdgeInsets.all(kPadding),
                              itemCount: paginated.length,
                              separatorBuilder: (context, index) => height15,
                              itemBuilder: (context, index) =>
                                  _buildCustomerCard(paginated[index]),
                            )
                          : _buildTable(paginated),
                    ),
                  ),
          ),
          if (totalPages > 1) _buildPagination(totalPages),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCustomerSidebar(),
        backgroundColor: kColor(context).primary,
        foregroundColor: kColor(context).onPrimary,
        icon: const Icon(LucideIcons.userPlus),
        label: Label("Add Client").regular,
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => currentPage = 1),
                  decoration: InputDecoration(
                    hintText: "Search by name or phone...",
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    filled: true,
                    fillColor: kColor(context).surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty) ...[
                const SizedBox(width: 10),
                _filterButton(
                  icon: LucideIcons.filterX,
                  color: kColor(context).error,
                  onTap: () => setState(() {
                    _searchController.clear();
                    currentPage = 1;
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedFilters() {
    if (_searchController.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15),
      child: Row(
        children: [
          Label(
            "Applied Filters:",
            fontSize: 12,
            weight: 700,
            color: kColor(context).onSurfaceVariant,
          ).regular,
          const SizedBox(width: 10),
          _filterChip(
            "Search: ${_searchController.text}",
            onDelete: () => setState(() {
              _searchController.clear();
              currentPage = 1;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<CustomerModel> customers) {
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
                  Expanded(flex: 1, child: _headerLabel("TYPE")),
                  Expanded(flex: 3, child: _headerLabel("CLIENT NAME")),
                  Expanded(flex: 2, child: _headerLabel("PHONE")),
                  Expanded(flex: 2, child: _headerLabel("GST/PAN")),
                  Expanded(flex: 1, child: _headerLabel("ACTIONS")),
                ],
              ),
            ),
            // Table Rows
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: kColor(context).outlineVariant.withAlpha(50),
                ),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  final isCompany = customer.clientType == "Company";
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailUI(customer: customer),
                      ),
                    ).then((_) => _loadCustomers()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildClientTypeChip(customer.clientType, isCompany),
                          ),
                          Expanded(
                            flex: 3,
                            child: Label(
                              customer.name,
                              fontSize: 14,
                              weight: 700,
                            ).regular,
                          ),
                          Expanded(
                            flex: 2,
                            child: Label(
                              customer.phone,
                              fontSize: 14,
                              weight: 500,
                            ).regular,
                          ),
                          Expanded(
                            flex: 2,
                            child: Label(
                              isCompany
                                  ? (customer.gst.isNotEmpty
                                      ? "GST: ${customer.gst}"
                                      : "PAN: ${customer.pan}")
                                  : (customer.pan.isNotEmpty
                                      ? "PAN: ${customer.pan}"
                                      : "N/A"),
                              fontSize: 12,
                              color: kColor(context).onSurfaceVariant,
                            ).regular,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
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
                                      builder: (context) => CustomerDetailUI(customer: customer),
                                    ),
                                  ).then((_) => _loadCustomers()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
      fontSize: 11,
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
          Label("Page $currentPage of $totalPages", fontSize: 13, weight: 600).regular,
          const SizedBox(width: 20),
          _pageButton(
            LucideIcons.chevronRight,
            currentPage < totalPages ? () => setState(() => currentPage++) : null,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap == null ? kColor(context).outlineVariant.withAlpha(20) : kColor(context).primary.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTap == null ? kColor(context).outlineVariant.withAlpha(30) : kColor(context).primary.withAlpha(40)),
        ),
        child: Icon(icon, size: 16, color: onTap == null ? kColor(context).onSurfaceVariant.withAlpha(100) : kColor(context).primary),
      ),
    );
  }

  Widget _filterButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        width: 54,
        decoration: BoxDecoration(
          color: kColor(context).surfaceContainerLow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kColor(context).outlineVariant.withAlpha(50)),
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
          Label(text, fontSize: 11, weight: 600, color: kColor(context).primary).regular,
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            child: Icon(LucideIcons.x, size: 12, color: kColor(context).primary),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 60,
            color: kColor(context).onSurfaceVariant.withAlpha(50),
          ),
          height20,
          Label(
            _searchController.text.isEmpty
                ? "No customers yet"
                : "No customers match your search",
            color: kColor(context).onSurfaceVariant,
            fontSize: 16,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    final isCompany = customer.clientType == "Company";
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
              color: isCompany
                  ? kColor(context).secondary.withAlpha(20)
                  : kColor(context).primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompany
                    ? kColor(context).secondary.withAlpha(40)
                    : kColor(context).primary.withAlpha(40),
              ),
            ),
            child: Center(
              child: Icon(
                isCompany ? LucideIcons.building2 : LucideIcons.user,
                color: isCompany
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
                    _buildClientTypeChip(customer.clientType, isCompany),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(LucideIcons.phone, size: 13, color: kColor(context).onSurfaceVariant),
                    const SizedBox(width: 8),
                    Label(customer.phone, fontSize: 13, color: kColor(context).onSurfaceVariant).regular,
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.pencil, size: 18, color: kColor(context).onSurfaceVariant),
            onPressed: () => _showAddEditCustomerSidebar(customer),
            visualDensity: VisualDensity.compact,
          ),
          Icon(LucideIcons.chevronRight, size: 20, color: kColor(context).outlineVariant),
        ],
      ),
    );
  }

  Widget _buildClientTypeChip(String type, bool isCompany) {
    final color = isCompany ? kColor(context).secondary : kColor(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
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

