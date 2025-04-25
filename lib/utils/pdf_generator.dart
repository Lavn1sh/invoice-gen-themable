import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import '../models/invoice_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> generatePDF({
  required List<InvoiceItem> items,
  required String from,
  required String billTo,
  required String invoiceNumber,
  required String date,
  required double discount,
  required String notes,
  required String terms,
  required String accountHolderName,
  required String accountNumber,
  required String bankName,
  required String ifscCode,
  required Map<String, String> theme, // Add theme parameter
  File? logoFile,
}) async {
  final pdf = pw.Document();

  // Load the logo image if available
  pw.ImageProvider? logoImage;
  if (logoFile != null) {
    final logoBytes = await logoFile.readAsBytes();
    logoImage = pw.MemoryImage(logoBytes);
  }

  final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
  final discountAmount = subtotal * discount / 100;
  final total = subtotal - discountAmount;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin:
          pw.EdgeInsets.zero, // Keep margins removed for full-page background
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Background Design
            pw.Positioned.fill(
              child: pw.Column(
                children: [
                  // Top Section with theme color
                  pw.Container(
                    height: 200,
                    color: PdfColor.fromHex(theme['topSection']!),
                  ),
                  // Bottom Section with theme color
                  pw.Expanded(
                    child: pw.Container(
                      color: PdfColor.fromHex(theme['bottomSection']!),
                    ),
                  ),
                ],
              ),
            ),

            // Foreground Content with Padding
            pw.Padding(
              padding: const pw.EdgeInsets.all(40), // Add padding here
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      if (logoImage != null)
                        pw.Image(logoImage, width: 100, height: 100),
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex(theme['text']!),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Invoice Details Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bill To: $billTo',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex(theme['text']!),
                            ),
                          ),
                          pw.Text(
                            'Bill From: $from',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex(theme['text']!),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Invoice No: $invoiceNumber',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex(theme['text']!),
                            ),
                          ),
                          pw.Text(
                            'Date: $date',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex(theme['text']!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Middle Section with White Background
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    color: PdfColors.white, // White background for the table
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Items Table
                        pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColor.fromHex(theme['text']!),
                          ),
                          children: [
                            // Table Header
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex(theme['tableHeader']!),
                              ),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'DESCRIPTION',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex(theme['text']!),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'SUBTOTAL',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex(theme['text']!),
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            // Table Rows
                            ...items.map((item) {
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      item.description,
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        color: PdfColor.fromHex(theme['text']!),
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      'Rs.${item.total.toStringAsFixed(2)}',
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        color: PdfColor.fromHex(theme['text']!),
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                        pw.SizedBox(height: 10),

                        // Subtotal, Discount, and Total
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Subtotal:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                            pw.Text(
                              'Rs.${subtotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Discount (${discount.toStringAsFixed(0)}%):',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                            pw.Text(
                              '- Rs.${discountAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total:',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                            pw.Text(
                              'Rs.${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex(theme['text']!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Banking Details Section
                  pw.Text(
                    'PAYMENT DETAILS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex(theme['text']!),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Account Holder Name: $accountHolderName',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex(theme['text']!),
                    ),
                  ),
                  pw.Text(
                    'Account Number: $accountNumber',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex(theme['text']!),
                    ),
                  ),
                  pw.Text(
                    'Bank Name: $bankName',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex(theme['text']!),
                    ),
                  ),
                  pw.Text(
                    'IFSC Code: $ifscCode',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex(theme['text']!),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Footer Section
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    color: PdfColor.fromHex(theme['tableHeader']!),
                    child: pw.Center(
                      child: pw.Text(
                        'Thank you for your business!',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex(theme['text']!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  // Save or print the PDF
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());

  // Increment the invoice number
  final prefs = await SharedPreferences.getInstance();
  final currentInvoiceNumber = int.tryParse(invoiceNumber) ?? 0;
  final nextInvoiceNumber = currentInvoiceNumber + 1;
  await prefs.setString('invoiceNumber', nextInvoiceNumber.toString());
}
