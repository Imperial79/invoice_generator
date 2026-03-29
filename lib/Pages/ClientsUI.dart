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
          );
      await DatabaseService.instance.saveCustomer(newCustomer);
      _loadCustomers();
      KSnackbar(context, message: "Customer saved successfully");
    } catch (e) {
      log("Save Customer: [Error] -> $e");
      KSnackbar(context, message: "Unable to save customer", error: true);
    }
  }

  Future<void> _showAddEditCustomerDialog([CustomerModel? customer]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final addressController = TextEditingController(text: customer?.address);
    final gstController = TextEditingController(text: customer?.gst);
    final panController = TextEditingController(text: customer?.pan);
    final aadhaarController = TextEditingController(text: customer?.aadhaar);

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints(maxWidth: 600),
        title: Label(
          customer == null ? "Add Customer" : "Edit Customer",
          fontSize: 20,
          weight: 700,
        ).title,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              KField(
                controller: nameController,
                label: "Customer Name",
                hintText: "Enter full name",
                validator: KValidation.required,
                prefix: const Icon(LucideIcons.user, size: 18),
              ),
              KField(
                controller: phoneController,
                label: "Phone Number",
                hintText: "10-digit mobile number",
                keyboardType: TextInputType.phone,
                validator: KValidation.phone,
                prefix: const Icon(LucideIcons.phone, size: 18),
              ),
              KField(
                controller: addressController,
                label: "Address",
                hintText: "Optional shop/home address",
                maxLines: 2,
                prefix: const Icon(LucideIcons.mapPin, size: 18),
              ),
              KField(prefix: const Icon(LucideIcons.fingerprint, size: 18)),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: KField(
                      controller: panController,
                      label: "PAN",
                      hintText: "Optional",
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  Expanded(
                    child: KField(
                      controller: aadhaarController,
                      label: "Aadhaar",
                      hintText: "Optional",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Label(
              "Cancel",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ),
          ElevatedButton(
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
                );
                if (context.mounted) Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kColor(context).primary,
              foregroundColor: kColor(context).onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Label("Save Customer").regular,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Customer Management", showBack: false),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: filteredCustomers.isEmpty
                ? _buildEmptyState()
                : _buildCustomerList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCustomerDialog(),
        backgroundColor: kColor(context).primary,
        foregroundColor: kColor(context).onPrimary,
        icon: const Icon(LucideIcons.userPlus),
        label: Label("Add Customer").regular,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by name or phone...",
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: kColor(context).surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
        ),
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

  Widget _buildCustomerList() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: MediaQuery.of(context).size.width < 900
            ? ListView.separated(
                padding: const EdgeInsets.all(kPadding),
                itemCount: filteredCustomers.length,
                separatorBuilder: (context, index) => height15,
                itemBuilder: (context, index) =>
                    _buildCustomerCard(filteredCustomers[index]),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(kPadding),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450,
                  mainAxisExtent: 110,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) =>
                    _buildCustomerCard(filteredCustomers[index]),
              ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
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
      padding: const EdgeInsets.all(16),
      radius: 15,
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: kColor(context).primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                LucideIcons.user,
                color: kColor(context).onPrimaryContainer,
                size: 24,
              ),
            ),
          ),
          width15,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Label(customer.name, fontSize: 16, weight: 700).regular,
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.phone,
                      size: 12,
                      color: kColor(context).onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
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
            icon: const Icon(LucideIcons.pencil, size: 18),
            onPressed: () => _showAddEditCustomerDialog(customer),
          ),
          const Icon(LucideIcons.chevronRight, size: 20),
        ],
      ),
    );
  }
}
