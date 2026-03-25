import 'package:flutter/material.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:invoice_generator/Essentials/kButton.dart';
import 'package:invoice_generator/Essentials/kField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompanyProfileUI extends StatefulWidget {
  const CompanyProfileUI({super.key});

  @override
  State<CompanyProfileUI> createState() => _CompanyProfileUIState();
}

class _CompanyProfileUIState extends State<CompanyProfileUI> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final gstin = TextEditingController();
  final address = TextEditingController();
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    isLoading.value = true;
    final pref = await SharedPreferences.getInstance();
    name.text = pref.getString("biz_name") ?? "Imperial Studio";
    phone.text = pref.getString("biz_phone") ?? "";
    email.text = pref.getString("biz_email") ?? "";
    gstin.text = pref.getString("biz_gst") ?? "19APDPV5128C1ZU";
    address.text =
        pref.getString("biz_address") ?? "Arrah More, Durgapur - 713212";
    isLoading.value = false;
  }

  _saveData() async {
    isLoading.value = true;
    final pref = await SharedPreferences.getInstance();
    await pref.setString("biz_name", name.text);
    await pref.setString("biz_phone", phone.text);
    await pref.setString("biz_email", email.text);
    await pref.setString("biz_gst", gstin.text);
    await pref.setString("biz_address", address.text);
    isLoading.value = false;
    if (mounted) {
      KSnackbar(context, message: "Profile updated successfully!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Company Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          children: [
            KField(
              controller: name,
              label: "Business Name",
              prefix: const Icon(LucideIcons.building, size: 16),
            ),
            height15,
            KField(
              controller: gstin,
              label: "GSTIN",
              prefix: const Icon(LucideIcons.hash, size: 16),
            ),
            height15,
            KField(
              controller: phone,
              label: "Phone",
              prefix: const Icon(LucideIcons.phone, size: 16),
            ),
            height15,
            KField(
              controller: email,
              label: "Email",
              prefix: const Icon(LucideIcons.mail, size: 16),
            ),
            height15,
            KField(
              controller: address,
              label: "Address",
              maxLines: 3,
              prefix: const Icon(LucideIcons.mapPin, size: 16),
            ),
            height30,
            KButton(onPressed: _saveData, label: "Save Profile"),
          ],
        ),
      ),
    );
  }
}
