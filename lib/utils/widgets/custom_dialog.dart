import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? actions;
  final BuildContext parentContext;
  final bool dismissable;

  const CustomAlertDialog({
    super.key,
    this.title,
    this.child,
    this.actions,
    required this.parentContext,
    this.dismissable = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dismissable, // Handle back button
      child: AlertDialog(
        contentTextStyle: const TextStyle(
          fontFamily: 'PanagramMedium',
          fontSize: 16,
          color: Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
        alignment: Alignment.center,
        contentPadding: const EdgeInsets.all(12),

        title: Text(
          title ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: "PanagramMedium",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: SingleChildScrollView(
          child: DefaultTextStyle(
            textAlign: TextAlign.center, // forces text children to center
            style: const TextStyle(
              fontFamily: 'PanagramMedium',
              fontSize: 16,
              color: Colors.black,
            ),
            child: child ?? const SizedBox(),
          ),
        ),

        actionsAlignment: MainAxisAlignment.center,
        // centers actions
        actions: actions,
      ),
    );
  }
}
