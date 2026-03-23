// Add this new widget class, for example at the bottom of product_detail_page_widgets.dart

import 'package:flutter/material.dart';

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({
    super.key,
    required this.child,
  });

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // This is crucial for the mixin to work.
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true; // This tells Flutter to keep the state.
}