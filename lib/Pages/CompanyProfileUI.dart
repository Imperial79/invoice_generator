import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Company_Profile_Model.dart';
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

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    gstin.dispose();
    address.dispose();
    bankDetails.dispose();
    terms.dispose();
    state.dispose();
    declaration.dispose();
    bannerPath.dispose();
    watermarkPath.dispose();
    isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final profile = await DatabaseService.instance.getCompanyProfile();
      name.text = profile.name;
      phone.text = profile.phone;
      email.text = profile.email;
      gstin.text = profile.gst;
      address.text = profile.address;
      bankDetails.text = profile.bankDetails;
      terms.text = profile.terms;
      state.text = profile.state;
      declaration.text = profile.declaration;
      bannerPath.text = profile.bannerPath;
      watermarkPath.text = profile.watermarkPath;
    } catch (e) {
      debugPrint("Error loading company profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveData() async {
    isLoading.value = true;
    try {
      final profile = CompanyProfileModel(
        name: name.text,
        phone: phone.text,
        email: email.text,
        gst: gstin.text,
        address: address.text,
        bankDetails: bankDetails.text,
        terms: terms.text,
        state: state.text,
        declaration: declaration.text,
        bannerPath: bannerPath.text,
        watermarkPath: watermarkPath.text,
      );
      await DatabaseService.instance.saveCompanyProfile(profile);
      if (mounted) {
        KSnackbar(context, message: "Profile updated successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        KSnackbar(context, message: "Error saving profile: $e", error: true);
      }
    } finally {
      isLoading.value = false;
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
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: KValidation.phone,
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
                                    label: "Banner Image URL",
                                    readOnly: true,
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                            type: FileType.image,
                                          );
                                      if (result != null &&
                                          result.files.single.path != null) {
                                        isLoading.value = true;
                                        try {
                                          final url = await DatabaseService
                                              .instance
                                              .uploadFile(
                                                File(result.files.single.path!),
                                                result.files.single.path!,
                                              );
                                          bannerPath.text = url;
                                        } catch (e) {
                                          if (mounted) {
                                            KSnackbar(
                                              context,
                                              message:
                                                  "Error uploading banner: $e",
                                              error: true,
                                            );
                                          }
                                        } finally {
                                          isLoading.value = false;
                                        }
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
                                    label: "Watermark Image URL",
                                    readOnly: true,
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                            type: FileType.image,
                                          );
                                      if (result != null &&
                                          result.files.single.path != null) {
                                        isLoading.value = true;
                                        try {
                                          final url = await DatabaseService
                                              .instance
                                              .uploadFile(
                                                File(result.files.single.path!),
                                                result.files.single.path!,
                                              );
                                          watermarkPath.text = url;
                                        } catch (e) {
                                          if (mounted) {
                                            KSnackbar(
                                              context,
                                              message:
                                                  "Error uploading watermark: $e",
                                              error: true,
                                            );
                                          }
                                        } finally {
                                          isLoading.value = false;
                                        }
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
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: KValidation.phone,
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
                        label: "Banner Image URL",
                        readOnly: true,
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null &&
                              result.files.single.path != null) {
                            isLoading.value = true;
                            try {
                              final url = await DatabaseService.instance
                                  .uploadFile(
                                    File(result.files.single.path!),
                                    result.files.single.path!,
                                  );
                              bannerPath.text = url;
                            } catch (e) {
                              if (mounted) {
                                KSnackbar(
                                  context,
                                  message: "Error uploading banner: $e",
                                  error: true,
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          }
                        },
                        prefix: const Icon(LucideIcons.image, size: 16),
                      ),
                      height15,
                      KField(
                        controller: watermarkPath,
                        label: "Watermark Image URL",
                        readOnly: true,
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null &&
                              result.files.single.path != null) {
                            isLoading.value = true;
                            try {
                              final url = await DatabaseService.instance
                                  .uploadFile(
                                    File(result.files.single.path!),
                                    result.files.single.path!,
                                  );
                              watermarkPath.text = url;
                            } catch (e) {
                              if (mounted) {
                                KSnackbar(
                                  context,
                                  message: "Error uploading watermark: $e",
                                  error: true,
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
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
