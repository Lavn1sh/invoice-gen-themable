import 'package:flutter/material.dart';
import '../models/invoice_item.dart';

class InvoiceItems extends StatelessWidget {
  final List<InvoiceItem> items;
  final void Function(String description, int quantity, double price) onAddItem;
  final TextEditingController itemController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  const InvoiceItems({
    required this.items,
    required this.onAddItem,
    required this.itemController,
    required this.quantityController,
    required this.priceController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: itemController,
                decoration: InputDecoration(labelText: 'Item Description'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final description = itemController.text;
                final quantity = int.tryParse(quantityController.text) ?? 1;
                final price = double.tryParse(priceController.text) ?? 0.0;
                onAddItem(description, quantity, price);
                itemController.clear();
                quantityController.clear();
                priceController.clear();
              },
              child: Text('+ Add Item'),
            ),
          ],
        ),
        Column(
          children: items.map((item) {
            return ListTile(
              title: Text(item.description),
              subtitle: Text(
                  'Qty: ${item.quantity} x Rs.${item.price.toStringAsFixed(2)}'),
              trailing: Text('Rs.${item.total.toStringAsFixed(2)}'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
