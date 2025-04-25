import 'package:flutter/material.dart';
import '../models/invoice_item.dart';

class InvoiceTotals extends StatelessWidget {
  final List<InvoiceItem> items;
  final TextEditingController discountController;
  final double Function() calculateTotal;

  const InvoiceTotals({
    required this.items,
    required this.discountController,
    required this.calculateTotal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.quantity * item.price),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Subtotal: Rs.${subtotal.toStringAsFixed(2)}'),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                controller: discountController,
                decoration: InputDecoration(labelText: 'Discount %'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Text('Total: Rs.${calculateTotal().toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }
}
