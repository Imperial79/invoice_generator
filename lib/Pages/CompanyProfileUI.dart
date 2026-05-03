import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Company_Profile_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      setState(() {});
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

  Future<void> _pickAndUpload(TextEditingController controller, String label) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      isLoading.value = true;
      try {
        final url = await DatabaseService.instance.uploadFile(
          File(result.files.single.path!),
          result.files.single.path!,
        );
        controller.text = url;
        setState(() {});
      } catch (e) {
        if (mounted) {
          KSnackbar(
            context,
            message: "Error uploading $label: $e",
            error: true,
          );
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kColor(context).primary.withAlpha(15),
              borderRadius: kRadius(8),
            ),
            child: Icon(icon, size: 16, color: kColor(context).primary),
          ),
          const SizedBox(width: 12),
          Label(title, fontSize: 13, weight: 700, color: kColor(context).primary).regular,
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: kColor(context).primary.withAlpha(40),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(80)),
        borderRadius: kRadius(0),
      ),
      child: child,
    );
  }

  Widget _imageUploadCard({
    required TextEditingController controller,
    required String label,
    required String description,
    required IconData icon,
    required String uploadKey,
    double aspectRatio = 16 / 4,
  }) {
    final hasImage = controller.text.isNotEmpty;
    final isUrl = hasImage && (controller.text.startsWith('http://') || controller.text.startsWith('https://'));
    final isLocalFile = hasImage && !isUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: kColor(context).onSurfaceVariant),
            const SizedBox(width: 8),
            Label(label, fontSize: 13, weight: 600).regular,
            const Spacer(),
            if (hasImage)
              TextButton.icon(
                onPressed: () {
                  controller.clear();
                  setState(() {});
                },
                icon: const Icon(LucideIcons.trash2, size: 13),
                label: const Text("Remove", style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: kColor(context).error,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            FilledButton.icon(
              onPressed: () => _pickAndUpload(controller, label),
              icon: Icon(hasImage ? LucideIcons.refreshCw : LucideIcons.upload, size: 14),
              label: Text(
                hasImage ? "Replace" : "Upload",
                style: const TextStyle(fontSize: 12),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: kRadius(0),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      isLocalFile
                          ? Image.file(
                              File(controller.text),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(description, icon),
                            )
                          : Image.network(
                              controller.text,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: kColor(context).surfaceContainerHighest,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => _imagePlaceholder(description, icon),
                            ),
                      // Bottom overlay strip showing filename/url
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: Colors.black.withAlpha(130),
                          child: Row(
                            children: [
                              Icon(LucideIcons.circleCheck, size: 12, color: Colors.greenAccent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  controller.text.length > 60
                                      ? '...${controller.text.substring(controller.text.length - 50)}'
                                      : controller.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _imagePlaceholder(description, icon),
          ),
        ),
        const SizedBox(height: 6),
        Label(
          description,
          fontSize: 11,
          color: kColor(context).onSurfaceVariant,
        ).regular,
      ],
    );
  }

  Widget _imagePlaceholder(String description, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerHighest.withAlpha(80),
        border: Border.all(
          color: kColor(context).outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: kColor(context).onSurfaceVariant.withAlpha(100)),
          const SizedBox(height: 8),
          Label(
            "No image uploaded",
            fontSize: 12,
            color: kColor(context).onSurfaceVariant.withAlpha(140),
          ).regular,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Company Profile"),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            primary: true,
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Business Identity ──────────────────────────────
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("BUSINESS IDENTITY", LucideIcons.building2),
                      KField(
                        controller: name,
                        label: "Business Name",
                        hintText: "e.g. Shree Jewellers Pvt. Ltd.",
                        textCapitalization: TextCapitalization.words,
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
                              hintText: "22AAAAA0000A1Z5",
                              textCapitalization: TextCapitalization.characters,
                              prefix: const Icon(LucideIcons.hash, size: 16),
                            ),
                          ),
                          Expanded(
                            child: KField(
                              controller: state,
                              label: "State",
                              hintText: "e.g. Maharashtra",
                              textCapitalization: TextCapitalization.words,
                              prefix: const Icon(LucideIcons.map, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Section 2: Contact Details ────────────────────────────────
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("CONTACT DETAILS", LucideIcons.contactRound),
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            child: KField(
                              controller: phone,
                              label: "Phone",
                              hintText: "10-digit mobile number",
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: KValidation.phone,
                              prefix: const Icon(LucideIcons.phone, size: 16),
                            ),
                          ),
                          Expanded(
                            child: KField(
                              controller: email,
                              label: "Email",
                              hintText: "contact@yourbusiness.com",
                              textCapitalization: TextCapitalization.none,
                              prefix: const Icon(LucideIcons.mail, size: 16),
                            ),
                          ),
                        ],
                      ),
                      height15,
                      KField(
                        controller: address,
                        label: "Address",
                        hintText: "Full address with city, pin code",
                        maxLines: 3,
                        textCapitalization: TextCapitalization.words,
                        prefix: const Icon(LucideIcons.mapPin, size: 16),
                      ),
                    ],
                  ),
                ),

                // ── Section 3: Invoice Branding (Images) ──────────────────────
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("INVOICE BRANDING", LucideIcons.imagePlay),
                      _imageUploadCard(
                        controller: bannerPath,
                        label: "Invoice Banner",
                        description:
                            "Displayed at the top of every invoice. Recommended: wide landscape image (e.g. 1600×400 px).",
                        icon: LucideIcons.image,
                        uploadKey: "banner",
                        aspectRatio: 16 / 4,
                      ),
                      const SizedBox(height: 24),
                      _imageUploadCard(
                        controller: watermarkPath,
                        label: "Invoice Watermark",
                        description:
                            "Printed as a transparent background mark on the invoice. Recommended: square logo (e.g. 512×512 px).",
                        icon: LucideIcons.stamp,
                        uploadKey: "watermark",
                        aspectRatio: 16 / 6,
                      ),
                    ],
                  ),
                ),

                // ── Section 4: Financial & Legal Details ─────────────────────
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("FINANCIAL & LEGAL", LucideIcons.landmark),
                      KField(
                        controller: bankDetails,
                        label: "Bank Details",
                        hintText:
                            "Bank Name, Account No., IFSC Code, Branch",
                        maxLines: 6,
                        prefix: const Icon(LucideIcons.landmark, size: 16),
                      ),
                      height15,
                      KField(
                        controller: terms,
                        label: "Terms & Conditions",
                        hintText:
                            "Goods once sold will not be taken back. GST as applicable...",
                        maxLines: 6,
                        prefix: const Icon(LucideIcons.fileText, size: 16),
                      ),
                      height15,
                      KField(
                        controller: declaration,
                        label: "Declaration",
                        hintText:
                            "We declare that this invoice shows the actual price of the goods...",
                        maxLines: 4,
                        prefix: const Icon(LucideIcons.info, size: 16),
                      ),
                    ],
                  ),
                ),

                // ── Save Button ───────────────────────────────────────────────
                KButton(onPressed: _saveData, label: "Save Profile"),
                height20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
