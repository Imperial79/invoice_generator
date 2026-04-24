import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:file_picker/file_picker.dart';

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
  final declaration = TextEditingController();
  final bannerPath = TextEditingController();
  final watermarkPath = TextEditingController();
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    isLoading.value = true;
    final pref = await SharedPreferences.getInstance();
    name.text = pref.getString("biz_name") ?? "";
    phone.text = pref.getString("biz_phone") ?? "";
    email.text = pref.getString("biz_email") ?? "";
    gstin.text = pref.getString("biz_gst") ?? "";
    address.text = pref.getString("biz_address") ?? "";
    bankDetails.text = pref.getString("biz_bank") ?? "";
    terms.text = pref.getString("biz_terms") ?? "";
    state.text = pref.getString("biz_state") ?? "";
    declaration.text = pref.getString("biz_declaration") ?? "";
    bannerPath.text = pref.getString("biz_banner") ?? "";
    watermarkPath.text = pref.getString("biz_watermark") ?? "";
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
    await pref.setString("biz_declaration", declaration.text);
    await pref.setString("biz_banner", bannerPath.text);
    await pref.setString("biz_watermark", watermarkPath.text);
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
          constraints: const BoxConstraints(maxWidth: 1200),
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
                            height15,
                            Row(
                              spacing: 15,
                              children: [
                                Expanded(
                                  child: KField(
                                    controller: bannerPath,
                                    label: "Banner Image Path",
                                    readOnly: true,
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                            type: FileType.image,
                                          );
                                      if (result != null) {
                                        bannerPath.text =
                                            result.files.single.path ?? "";
                                      }
                                    },
                                    prefix: const Icon(
                                      LucideIcons.image,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: KField(
                                    controller: watermarkPath,
                                    label: "Watermark Image Path",
                                    readOnly: true,
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                            type: FileType.image,
                                          );
                                      if (result != null) {
                                        watermarkPath.text =
                                            result.files.single.path ?? "";
                                      }
                                    },
                                    prefix: const Icon(
                                      LucideIcons.fileImage,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
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
                            height15,
                            KField(
                              controller: declaration,
                              label: "Declaration",
                              maxLines: 12,
                              prefix: const Icon(LucideIcons.info, size: 16),
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
                      height15,
                      KField(
                        controller: declaration,
                        label: "Declaration",
                        maxLines: 4,
                        prefix: const Icon(LucideIcons.info, size: 16),
                      ),
                      height15,
                      KField(
                        controller: bannerPath,
                        label: "Banner Image Path",
                        readOnly: true,
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null) {
                            bannerPath.text = result.files.single.path ?? "";
                          }
                        },
                        prefix: const Icon(LucideIcons.image, size: 16),
                      ),
                      height15,
                      KField(
                        controller: watermarkPath,
                        label: "Watermark Image Path",
                        readOnly: true,
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null) {
                            watermarkPath.text = result.files.single.path ?? "";
                          }
                        },
                        prefix: const Icon(LucideIcons.fileImage, size: 16),
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
