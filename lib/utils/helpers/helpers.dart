

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';



String removeHtmlTags(String htmlString) {
  final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
  return htmlString.replaceAll(exp, '').trim();
}



double parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

final priceFormatter = NumberFormat.currency(
  locale: 'hi_IN',
  symbol: '₹',
  decimalDigits: 0,
);


class PhoneFormatter {
  /// Formats a raw Indian mobile number to "+91-XXXXXXXXXX"
  static String formatToIndian(String rawNumber) {
    if (rawNumber.isEmpty) return '';

    // Remove any leading zeros, spaces, or +
    String sanitized = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Remove leading 91 if present
    if (sanitized.startsWith('91') && sanitized.length > 10) {
      sanitized = sanitized.substring(2);
    } else if (sanitized.length > 10) {
      // Keep last 10 digits
      sanitized = sanitized.substring(sanitized.length - 10);
    }

    // Ensure we have exactly 10 digits
    if (sanitized.length != 10) return rawNumber; // fallback

    return '+91-$sanitized';
  }
}



bool validateMobileNumber(String input) {
  final regex = RegExp(r'^[6-9]\d{9}$');
  return regex.hasMatch(input);
}

Future<void> openWhatsApp({
  required String message,
  String? phoneNumber, // optional
}) async {
  final encodedMessage = Uri.encodeComponent(message);

  final url = phoneNumber != null && phoneNumber.isNotEmpty
      ? 'https://wa.me/$phoneNumber?text=$encodedMessage'
      : 'https://wa.me/?text=$encodedMessage';

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri
    );
  } else {
    createLog('Could not launch WhatsApp');
  }
}

String safeFormatDate(String? raw) {
  if (raw == null || raw.isEmpty) return "";
  try {
    return DateFormat('MMMM d, yyyy  h:mm a').format(DateTime.parse(raw));
  } catch (_) {
    return "";
  }
}


void createLog(dynamic message) {
  if (!kDebugMode) return; // Only show in debug mode

  String output;
  if (message is Map || message is List) {
    // Pretty-print JSON
    output = const JsonEncoder.withIndent('  ').convert(message);
  } else {
    // Convert anything else to a string
    output = message.toString();
  }

  // --- Define a title and line prefix ---
  const String logTitle = "[ App Log]";
  const String linePrefix = "│ "; // Box-drawing character

  // --- Define borders (you can change the length) ---
  final String topBorder = "┌${"─" * 80}";
  final String bottomBorder = "└${"─" * 80}";

  // --- Print the formatted log ---
  if (kDebugMode) {
    // Start with a newline for space
    print("\n$topBorder");
    print("$linePrefix $logTitle"); // Print the title
    print(linePrefix); // Print a blank line inside the box

    // Print each line of the actual message
    output.split('\n').forEach((line) {
      if (kDebugMode) {
        print("$linePrefix $line");
      }
    });

    print("$bottomBorder\n"); // End with a newline
  }

}


Future<void> openDialer(String phoneNumber) async {
  if (phoneNumber.isEmpty) {
    createLog('DialerHelper: phoneNumber is empty');
    return;
  }

  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    createLog('DialerHelper: Could not launch dialer for $phoneNumber');
  }
}






Widget buildImageWithCoverFit(String url, double width, double height) {
  // The image URL in your JSON sometimes includes leading slashes
  // final String fixedUrl = url.startsWith('/') ? url.replaceFirst(RegExp(r'^/'), '') : url;

  return CachedNetworkImage(
    memCacheWidth: 500,
    memCacheHeight: 500,
    imageUrl: url,
    width: width,
    height: height,
    fit: BoxFit.cover,
    placeholder: (context, url) => Image.asset('assets/images/pngicons/ic_img_placehoder.png', width: width, height: height, fit: BoxFit.cover),
    errorWidget: (context, error, url) => Image.asset('assets/images/pngicons/ic_img_placehoder.png', width: width, height: height, fit: BoxFit.cover),
  );
}


bool isNullOrEmptyOrWhitespace(String? s) {
  // Returns true if s is null OR if s.trim() is empty.
  return s == null || s.trim().isEmpty;
}


List<T> rearrangeForTwoRows<T>(List<T> list) {
  int half = (list.length / 2).ceil();
  List<T> firstRow = list.sublist(0, half);
  List<T> secondRow = list.sublist(half);
  List<T> rearranged = [];

  for (int i = 0; i < firstRow.length; i++) {
    rearranged.add(firstRow[i]);
    if (i < secondRow.length) rearranged.add(secondRow[i]);
  }
  return rearranged;
}


extension UrlSegmentEncoder on String {
  String encodeSegments() {
    return split('/').map(Uri.encodeComponent).join('/');
  }
}

void popAndRePushRoute(
    BuildContext context,
    String routeName, {
      Map<String, dynamic>? arguments,
    }) {
  bool found = false;

  // Step 1: Pop until found route OR root
  Navigator.popUntil(context, (route) {
    if (route.settings.name == routeName) {
      found = true; // found target in stack
    }
    return route.isFirst; // stop at root always
  });

  // Step 2: If found, pop one more (remove old instance)
  if (found) {
    Navigator.pop(context);
  }

  // Step 3: Push brand new route
  Navigator.pushNamed(
    context,
    routeName,
    arguments: arguments,
  );
}

