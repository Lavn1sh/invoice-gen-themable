import 'package:flutter/material.dart';

class InvoiceMetadata extends StatelessWidget {
  final TextEditingController billToController;
  final TextEditingController shipToController;
  final TextEditingController invoiceNumberController;
  final TextEditingController dateController;
  final TextEditingController dueDateController;
  final VoidCallback onSelectDate;

  const InvoiceMetadata({
    required this.billToController,
    required this.shipToController,
    required this.invoiceNumberController,
    required this.dateController,
    required this.dueDateController,
    required this.onSelectDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: billToController,
                decoration: InputDecoration(labelText: 'Bill To'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: shipToController,
                decoration: InputDecoration(labelText: 'Ship To (Optional)'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: invoiceNumberController,
                decoration: InputDecoration(labelText: 'Invoice #'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onSelectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onSelectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(labelText: 'Due Date'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
