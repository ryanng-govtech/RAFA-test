import 'package:flutter/material.dart';

import '../contants.dart';

class SummaryFieldGroup extends StatelessWidget {
  final String label;
  final String field;

  const SummaryFieldGroup({required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: kSummaryLabelWidth,
          child: Text(label, style: kSummaryLabelStyle),
        ),
        Flexible(
          child: Text(field),
        ),
      ],
    );
  }
}
