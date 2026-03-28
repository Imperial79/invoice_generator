import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';

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
  final bankDetails = TextEditingController();
  final terms = TextEditingController();
  final state = TextEditingController();
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
    bankDetails.text =
        pref.getString("biz_bank") ??
        "BANK DETAILS - SBI BANK, DURGAPUR SEN MARKET - A/C - 8718927918219871, IFSC - AKSLJASKLAAS\nSOUTH INDIAN BANK - ABC ROAD, - A/C - 8718927918219871, IFSC - AKSLJASKLAAS";
    terms.text =
        pref.getString("biz_terms") ??
        "E. & O.E.\n1. Payments via cheque are subject to verification.\n2. No returns or exchanges for sold goods.\n3. 18% interest on overdue payments.\n4. Disputes are under 'West Bengal' jurisdiction.\n5. Report invoice errors within 7 days.";
    state.text = pref.getString("biz_state") ?? "West Bengal (19)";
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
    await pref.setString("biz_bank", bankDetails.text);
    await pref.setString("biz_terms", terms.text);
    await pref.setString("biz_state", state.text);
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            primary: true,
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              children: [
                if (!Responsive.isMobile(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            KField(
                              controller: name,
                              label: "Business Name",
                              prefix: const Icon(
                                LucideIcons.building,
                                size: 16,
                              ),
                            ),
                            height15,
                            Row(
                              spacing: 15,
                              children: [
                                Expanded(
                                  child: KField(
                                    controller: gstin,
                                    label: "GSTIN",
                                    prefix: const Icon(
                                      LucideIcons.hash,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: KField(
                                    controller: state,
                                    label: "State",
                                    prefix: const Icon(
                                      LucideIcons.map,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
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
                              maxLines: 4,
                              prefix: const Icon(LucideIcons.mapPin, size: 16),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            KField(
                              controller: bankDetails,
                              label: "Bank Details",
                              maxLines: 12,
                              prefix: const Icon(
                                LucideIcons.landmark,
                                size: 16,
                              ),
                            ),
                            height15,
                            KField(
                              controller: terms,
                              label: "Terms & Conditions",
                              maxLines: 12,
                              prefix: const Icon(
                                LucideIcons.fileText,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      KField(
                        controller: name,
                        label: "Business Name",
                        prefix: const Icon(LucideIcons.building, size: 16),
                      ),
                      height15,
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            child: KField(
                              controller: gstin,
                              label: "GSTIN",
                              prefix: const Icon(LucideIcons.hash, size: 16),
                            ),
                          ),
                          Expanded(
                            child: KField(
                              controller: state,
                              label: "State",
                              prefix: const Icon(LucideIcons.map, size: 16),
                            ),
                          ),
                        ],
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
                        maxLines: 2,
                        prefix: const Icon(LucideIcons.mapPin, size: 16),
                      ),
                      height15,
                      KField(
                        controller: bankDetails,
                        label: "Bank Details",
                        maxLines: 10,
                        prefix: const Icon(LucideIcons.landmark, size: 16),
                      ),
                      height15,
                      KField(
                        controller: terms,
                        label: "Terms & Conditions",
                        maxLines: 10,
                        prefix: const Icon(LucideIcons.fileText, size: 16),
                      ),
                    ],
                  ),
                height30,
                KButton(onPressed: _saveData, label: "Save Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
