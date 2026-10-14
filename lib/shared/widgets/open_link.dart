import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../data/repository.dart';

/// Buka tautan di luar app (WhatsApp, Instagram, email, Maps), atau di
/// browser dalam app untuk halaman bayar ([inApp]).
Future<void> openLink(BuildContext context, String url, {bool inApp = false}) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: inApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak dapat dibuka.')));
  }
}

/// Buka chat WhatsApp admin dengan pesan pembuka. Nomornya dari API bila sudah
/// termuat, selain itu nomor cadangan di [AppStrings].
Future<void> openWhatsApp(BuildContext context, {String message = AppStrings.whatsappGreeting}) {
  final base = context.read<SiteController>().site?.contact.whatsappUrl ?? AppStrings.whatsappUrl;
  return openLink(context, '$base?text=${Uri.encodeComponent(message)}');
}
