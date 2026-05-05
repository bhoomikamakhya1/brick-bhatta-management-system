import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../models/sale_model.dart';

class PdfExportUtil {
  // Export sales report to PDF
  static Future<void> exportSalesReport(List<SaleEntry> sales, {String? fileName}) async {
    try {
      final pdf = pw.Document();

      // Calculate totals
      final totalSales = sales.length;
      final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.finalAmount);
      final totalBricks = sales.fold(0, (sum, sale) => 
        sum + sale.brickEntries.fold(0, (s, entry) => s + entry.quantity.toInt()));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Sales Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Total Sales: $totalSales'),
                  pw.Text('Total Bricks: $totalBricks'),
                  pw.Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Sales Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Bricks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Data rows
                ...sales.map((sale) {
                  final totalBricks = sale.brickEntries.fold(0, (sum, entry) => sum + entry.quantity.toInt());
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${sale.date.day}-${sale.date.month}-${sale.date.year}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(sale.customerName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(totalBricks.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Rs.${sale.finalAmount.toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${fileName ?? 'sales_report_${DateTime.now().millisecondsSinceEpoch}'}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // Try to share the file, but don't fail if share plugin isn't available
      try {
        await Share.shareXFiles([XFile(path)], text: 'Sales Report PDF');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }
      
      print('✅ PDF exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting PDF: $e');
      rethrow;
    }
  }

  // Export financial report to PDF
  static Future<void> exportFinancialReport(List<TransactionItem> transactions, {String? fileName}) async {
    try {
      final pdf = pw.Document();

      // Calculate totals
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.credit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      final totalExpense = transactions
          .where((t) => t.type == TransactionType.debit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      final netProfit = totalIncome - totalExpense;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Financial Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Total Income: Rs.${totalIncome.toStringAsFixed(2)}', 
                    style: const pw.TextStyle(color: PdfColors.green)),
                  pw.Text('Total Expense: Rs.${totalExpense.toStringAsFixed(2)}',
                    style: const pw.TextStyle(color: PdfColors.red)),
                  pw.Text('Net Profit: Rs.${netProfit.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Transactions Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Party', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Data rows
                ...transactions.map((txn) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(txn.date),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(txn.englishName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(txn.type == TransactionType.credit ? 'Credit' : 'Debit'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Rs.${txn.amount?.toStringAsFixed(2) ?? '0.00'}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${fileName ?? 'financial_report_${DateTime.now().millisecondsSinceEpoch}'}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // Try to share the file, but don't fail if share plugin isn't available
      try {
        await Share.shareXFiles([XFile(path)], text: 'Financial Report PDF');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }
      
      print('✅ PDF exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting PDF: $e');
      rethrow;
    }
  }
}
