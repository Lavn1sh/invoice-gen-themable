import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/invoice_header.dart';
import '../widgets/invoice_metadata.dart';
import '../widgets/invoice_totals.dart';
import '../widgets/invoice_notes.dart';
import '../utils/pdf_generator.dart';
import '../models/invoice_item.dart';

const Map<String, Map<String, String>> colorThemes = {
  'Default': {
    'topSection': '#cfb8a6',
    'bottomSection': '#f1f0ec',
    'text': '#4a4a4a',
    'tableHeader': '#cfb8a6',
  },
  'Blue': {
    'topSection': '#ade8f4', // Light blue for the top section
    'bottomSection': '#F0F8FF', // Alice blue for the bottom section
    'text': '#4682B4', // Steel blue for text
    'tableHeader': '#ade8f4', // Light blue for table headers
  },
  'Green': {
    'topSection': '#a6cfb8',
    'bottomSection': '#eaf8f1',
    'text': '#2a6a4a',
    'tableHeader': '#a6cfb8',
  },
  'Pink': {
    'topSection': '#f8c8d8',
    'bottomSection': '#fceaf1',
    'text': '#6a2a4a',
    'tableHeader': '#f8c8d8',
  },
  'Purple': {
    'topSection': '#d8c8f8',
    'bottomSection': '#f1eafc',
    'text': '#4a2a6a',
    'tableHeader': '#d8c8f8',
  },
  'Orange': {
    'topSection': '#f8d8a6',
    'bottomSection': '#fcefe1',
    'text': '#6a4a2a',
    'tableHeader': '#f8d8a6',
  },
  'Teal': {
    'topSection': '#a6f8d8',
    'bottomSection': '#eafcf1',
    'text': '#2a6a5a',
    'tableHeader': '#a6f8d8',
  },
};

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  InvoiceScreenState createState() => InvoiceScreenState();
}

class InvoiceScreenState extends State<InvoiceScreen> {
  final List<InvoiceItem> items = [];
  final TextEditingController fromController = TextEditingController();
  final TextEditingController billToController = TextEditingController();
  final TextEditingController shipToController = TextEditingController();
  final TextEditingController invoiceNumberController =
      TextEditingController(text: '1');
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController discountController =
      TextEditingController(text: '0');
  final TextEditingController notesController = TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  File? logoFile;
  String selectedTheme = 'Default';

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    fromController.text = prefs.getString('from') ?? '';
    billToController.text = prefs.getString('billTo') ?? '';
    shipToController.text = prefs.getString('shipTo') ?? '';
    invoiceNumberController.text =
        prefs.getString('invoiceNumber') ?? '1'; // Default to '1' if not set
    dateController.text = prefs.getString('date') ?? '';
    dueDateController.text = prefs.getString('dueDate') ?? '';
    discountController.text = prefs.getString('discount') ?? '0';
    notesController.text = prefs.getString('notes') ?? '';
    termsController.text = prefs.getString('terms') ?? '';
    accountHolderNameController.text =
        prefs.getString('accountHolderName') ?? '';
    accountNumberController.text = prefs.getString('accountNumber') ?? '';
    bankNameController.text = prefs.getString('bankName') ?? '';
    ifscCodeController.text = prefs.getString('ifscCode') ?? '';
    final logoPath = prefs.getString('logoPath');
    if (logoPath != null && logoPath.isNotEmpty) {
      logoFile = File(logoPath);
    }
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('from', fromController.text);
    await prefs.setString('billTo', billToController.text);
    await prefs.setString('shipTo', shipToController.text);
    await prefs.setString(
        'invoiceNumber', invoiceNumberController.text); // Save invoice number
    await prefs.setString('date', dateController.text);
    await prefs.setString('dueDate', dueDateController.text);
    await prefs.setString('discount', discountController.text);
    await prefs.setString('notes', notesController.text);
    await prefs.setString('terms', termsController.text);
    await prefs.setString(
        'accountHolderName', accountHolderNameController.text);
    await prefs.setString('accountNumber', accountNumberController.text);
    await prefs.setString('bankName', bankNameController.text);
    await prefs.setString('ifscCode', ifscCodeController.text);
    if (logoFile != null) {
      await prefs.setString('logoPath', logoFile!.path);
    }
  }

  void _pickLogo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        logoFile = File(result.files.single.path!);
      });
      await _saveFormData();
    }
  }

  void _addItem(String description, int quantity, double price) {
    setState(() {
      items.add(InvoiceItem(
        description: description,
        quantity: quantity,
        price: price,
      ));
    });
  }

  double _calculateTotal() {
    double subtotal =
        items.fold(0, (sum, item) => sum + (item.quantity * item.price));
    double discount =
        subtotal * (double.tryParse(discountController.text) ?? 0) / 100;
    return subtotal - discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InvoiceHeader(
              fromController: fromController,
              logoFile: logoFile,
              onPickLogo: _pickLogo,
            ),
            const SizedBox(height: 10),
            InvoiceMetadata(
              billToController: billToController,
              shipToController: shipToController,
              invoiceNumberController: invoiceNumberController,
              dateController: dateController,
              dueDateController: dueDateController,
              onSelectDate: () => _selectDate(context, dateController),
            ),
            const SizedBox(height: 10),
            InvoiceItems(
              items: items,
              onAddItem: (description, quantity, price) =>
                  _addItem(description, quantity, price),
              itemController: TextEditingController(),
              quantityController: TextEditingController(),
              priceController: TextEditingController(),
            ),
            const SizedBox(height: 10),
            InvoiceTotals(
              items: items, // Pass the List<InvoiceItem> directly
              discountController: discountController,
              calculateTotal: _calculateTotal,
            ),
            const SizedBox(height: 10),
            InvoiceNotes(
              notesController: notesController,
              termsController: termsController,
            ),
            const SizedBox(height: 10),
            _buildBankingDetailsSection(),
            const SizedBox(height: 10),
            _buildThemeSelector(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await generatePDF(
                  items: items,
                  from: fromController.text,
                  billTo: billToController.text,
                  invoiceNumber: invoiceNumberController.text,
                  date: dateController.text,
                  discount: double.tryParse(discountController.text) ?? 0,
                  notes: notesController.text,
                  terms: termsController.text,
                  accountHolderName: accountHolderNameController.text,
                  accountNumber: accountNumberController.text,
                  bankName: bankNameController.text,
                  ifscCode: ifscCodeController.text,
                  logoFile: logoFile,
                  theme: colorThemes[selectedTheme]!, // Pass the selected theme
                );

                // Increment the invoice number in the controller
                setState(() {
                  final currentInvoiceNumber =
                      int.tryParse(invoiceNumberController.text) ?? 0;
                  invoiceNumberController.text =
                      (currentInvoiceNumber + 1).toString();
                });

                // Save the updated invoice number
                await _saveFormData();
              },
              child: const Text('Export to PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Widget _buildBankingDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banking Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: accountHolderNameController,
          decoration: const InputDecoration(labelText: 'Account Holder Name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: accountNumberController,
          decoration: const InputDecoration(labelText: 'Account Number'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: bankNameController,
          decoration: const InputDecoration(labelText: 'Bank Name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: ifscCodeController,
          decoration: const InputDecoration(labelText: 'IFSC Code'),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Invoice Theme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: colorThemes.keys.map((themeName) {
            final isSelected = selectedTheme == themeName;
            return Container(
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(
                        color: Colors.white, width: 3) // Highlight border
                    : null,
                borderRadius: BorderRadius.circular(17),
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedTheme = themeName;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(int.parse(
                      colorThemes[themeName]!['topSection']!
                          .replaceFirst('#', '0xff'))),
                ),
                child: Text(
                  themeName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

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
