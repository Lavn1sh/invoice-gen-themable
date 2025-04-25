import 'package:flutter/material.dart';
import 'dart:io';

class InvoiceHeader extends StatelessWidget {
  final TextEditingController fromController;
  final File? logoFile;
  final VoidCallback onPickLogo;

  const InvoiceHeader({
    super.key,
    required this.fromController,
    required this.logoFile,
    required this.onPickLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onPickLogo,
          child: Container(
            width: 120,
            height: 120,
            color: Colors.grey[800],
            child: logoFile != null
                ? Image.file(logoFile!, fit: BoxFit.cover)
                : Center(child: Text('+ Add Your Logo')),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: fromController,
            decoration: InputDecoration(labelText: 'Who is this from?'),
          ),
        ),
      ],
    );
  }
}
