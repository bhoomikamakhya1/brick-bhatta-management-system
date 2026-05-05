import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../models/sale_model.dart';

class CsvExportUtil {
  // Export sales data to CSV
  static Future<void> exportSalesReport(List<SaleEntry> sales, {String? fileName}) async {
    try {
      // Prepare CSV data
      List<List<dynamic>> rows = [];
      
      // Headers
      rows.add([
        'Date',
        'Customer Name',
        'Total Bricks',
        'Total Amount',
        'Freight',
        'Advance Payment',
        'Final Amount',
        'OTP',
      ]);

      // Data rows
      for (var sale in sales) {
        final totalBricks = sale.brickEntries.fold(0, (sum, entry) => sum + entry.quantity.toInt());
        final freightAmount = sale.freightDetails != null 
            ? (totalBricks / 1000) * sale.freightDetails!.ratePer1000
            : 0.0;

        rows.add([
          '${sale.date.day}-${sale.date.month}-${sale.date.year}',
          sale.customerName,
          totalBricks,
          sale.totalAmount.toStringAsFixed(2),
          freightAmount.toStringAsFixed(2),
          sale.advancePayment.toStringAsFixed(2),
          sale.finalAmount.toStringAsFixed(2),
          sale.otp,
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${fileName ?? 'sales_report_${DateTime.now().millisecondsSinceEpoch}'}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      // Try to share the file, but don't fail if share plugin isn't available
      try {
        await Share.shareXFiles([XFile(path)], text: 'Sales Report');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }
      
      print('✅ CSV exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting CSV: $e');
      rethrow;
    }
  }

  // Export financial/transaction data to CSV
  static Future<void> exportFinancialReport(List<TransactionItem> transactions, {String? fileName}) async {
    try {
      // Prepare CSV data
      List<List<dynamic>> rows = [];
      
      // Headers
      rows.add([
        'Date',
        'Party Name',
        'Category',
        'Type',
        'Amount',
        'Description',
      ]);

      // Data rows
      for (var txn in transactions) {
        rows.add([
          txn.date,
          txn.englishName,
          txn.category,
          txn.type == TransactionType.credit ? 'Credit' : 'Debit',
          txn.amount?.toStringAsFixed(2) ?? '0.00',
          txn.description ?? '',
        ]);
      }

      // Add summary
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.credit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      final totalExpense = transactions
          .where((t) => t.type == TransactionType.debit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));

      rows.add([]);
      rows.add(['Summary', '', '', '', '', '']);
      rows.add(['Total Income', '', '', '', totalIncome.toStringAsFixed(2), '']);
      rows.add(['Total Expense', '', '', '', totalExpense.toStringAsFixed(2), '']);
      rows.add(['Net Profit', '', '', '', (totalIncome - totalExpense).toStringAsFixed(2), '']);

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${fileName ?? 'financial_report_${DateTime.now().millisecondsSinceEpoch}'}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      // Try to share the file, but don't fail if share plugin isn't available
      try {
        await Share.shareXFiles([XFile(path)], text: 'Financial Report');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }
      
      print('✅ CSV exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting CSV: $e');
      rethrow;
    }
  }
}
