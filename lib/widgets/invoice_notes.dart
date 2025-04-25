import 'package:flutter/material.dart';

class InvoiceNotes extends StatelessWidget {
  final TextEditingController notesController;
  final TextEditingController termsController;

  const InvoiceNotes({
    required this.notesController,
    required this.termsController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: notesController,
          decoration: InputDecoration(labelText: 'Notes'),
          maxLines: null,
          expands: false,
        ),
        TextField(
          controller: termsController,
          decoration: InputDecoration(labelText: 'Terms & Conditions'),
          maxLines: null,
          expands: false,
        ),
      ],
    );
  }
}
