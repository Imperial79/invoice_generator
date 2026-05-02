import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class UpdateService {
  static const String owner = 'Imperial79';
  static const String repo = 'invoice_generator';

  static Future<void> checkForUpdates(
    BuildContext context, {
    bool showNoUpdate = false,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestTag = data['tag_name'] as String;
        final latestVersion = latestTag.replaceAll('v', '');
        final htmlUrl = data['html_url'] as String;
        final assets = data['assets'] as List;

        if (_isNewerVersion(latestVersion, currentVersion)) {
          String? assetUrl;
          String? fileName;

          if (Platform.isMacOS) {
            final asset = assets.firstWhere(
              (a) =>
                  (a['name'] as String).endsWith('.dmg') ||
                  (a['name'] as String).endsWith('.pkg'),
              orElse: () => null,
            );
            assetUrl = asset?['browser_download_url'];
            fileName = asset?['name'];
          } else if (Platform.isWindows) {
            final asset = assets.firstWhere(
              (a) => (a['name'] as String).endsWith('.exe'),
              orElse: () => null,
            );
            assetUrl = asset?['browser_download_url'];
            fileName = asset?['name'];
          }

          if (context.mounted) {
            _showUpdateDialog(
              context,
              latestVersion,
              htmlUrl,
              assetUrl,
              fileName,
            );
          }
        } else if (showNoUpdate) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You are on the latest version!")),
            );
          }
        }
      }
    } catch (e) {
      log("Error checking for updates: $e");
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (var i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String htmlUrl,
    String? assetUrl,
    String? fileName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A new version ($version) is available."),
            const SizedBox(height: 10),
            const Text(
              "Would you like to download and install it now? The application will need to be restarted after installation.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (assetUrl != null && fileName != null) {
                _downloadAndInstall(context, assetUrl, fileName);
              } else {
                final url = Uri.parse(htmlUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: const Text("Download & Install"),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text("Downloading update... Please wait."),
        duration: Duration(minutes: 5),
      ),
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Download complete! Opening installer..."),
          ),
        );

        await OpenFile.open(file.path);
      } else {
        throw Exception("Failed to download file");
      }
    } catch (e) {
      log("Error downloading update: $e");
      KSnackbar(context, message: "Failed to download update: $e", error: true);
    }
  }
}
