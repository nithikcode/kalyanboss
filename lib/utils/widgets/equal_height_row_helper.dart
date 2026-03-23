import 'package:flutter/material.dart';

class EqualHeightRow extends StatelessWidget {
  final Widget first;
  final Widget? second;
  final double verticalPadding;

  const EqualHeightRow({
    required this.first,
    this.second,
    this.verticalPadding = 8.0, // default padding
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 4),
          Expanded(child: second ?? const SizedBox()),
        ],
      ),
    );
  }
}