import 'package:flutter/material.dart';
import 'screens/invoice_screen.dart';

void main() {
  runApp(InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: InvoiceScreen(),
    );
  }
}
