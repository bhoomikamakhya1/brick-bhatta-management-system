import '../models/transaction_model.dart';
import '../models/sale_model.dart';
import '../services/transaction_service.dart';
import '../services/sale_data_service.dart';
import '../services/work_data_service.dart';
import '../data/user_data.dart';

class ReportService {
  // Calculate total sales from SaleDataService
  static double getTotalSales() {
    final sales = SaleDataService.getAllSales();
    return sales.fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }

  // Calculate total expenses from transactions and work entries
  static double getTotalExpenses() {
    // Get expenses from debit transactions
    final transactions = TransactionService.getAllTransactions();
    final transactionExpenses = transactions
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
    
    // Get expenses from work entries (labour payments)
    final workExpenses = WorkDataService.getTotalAmount();
    
    return transactionExpenses + workExpenses;
  }

  // Calculate net profit
  static double getNetProfit() {
    return getTotalSales() - getTotalExpenses();
  }

  // Get count of active parties from UserData
  static int getActivePartiesCount() {
    final allUsers = UserData.getUsers();
    final currentPhone = (UserData.currentUserPhone ?? '').replaceAll(' ', '');
    
    final activeUsers = allUsers.where((user) {
      if (!user.isActive) return false;
      
      // Filter out current user
      if (currentPhone.isNotEmpty) {
        final uPhone = (user.phoneNumber ?? '').replaceAll(' ', '');
        if (uPhone == currentPhone) return false;
      }
      return true;
    }).length;
    
    return activeUsers;
  }

  // Get sales data filtered by date range
  static List<SaleEntry> getSalesInDateRange(DateTime? startDate, DateTime? endDate) {
    final allSales = SaleDataService.getAllSales();
    
    if (startDate == null && endDate == null) {
      return allSales;
    }

    return allSales.where((sale) {
      if (startDate != null && sale.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && sale.date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Get transactions filtered by date range
  static List<TransactionItem> getTransactionsInDateRange(DateTime? startDate, DateTime? endDate) {
    final allTransactions = TransactionService.getAllTransactions();
    
    if (startDate == null && endDate == null) {
      return allTransactions;
    }

    return allTransactions.where((txn) {
      try {
        // Parse date from dd-mm-yyyy format
        final parts = txn.date.split('-');
        if (parts.length == 3) {
          final txnDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
          
          if (startDate != null && txnDate.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && txnDate.isAfter(endDate)) {
            return false;
          }
          return true;
        }
      } catch (e) {
        print('Error parsing date: ${txn.date}');
      }
      return false;
    }).toList();
  }

  // Calculate sales summary
  static Map<String, dynamic> getSalesSummary(List<SaleEntry> sales) {
    double totalAmount = 0.0;
    double totalAdvance = 0.0;
    int totalBricks = 0;

    for (var sale in sales) {
      totalAmount += sale.finalAmount;
      totalAdvance += sale.advancePayment;
      totalBricks += sale.brickEntries.fold(0, (sum, entry) => sum + entry.quantity.toInt());
    }

    return {
      'totalSales': sales.length,
      'totalAmount': totalAmount,
      'totalAdvance': totalAdvance,
      'totalBricks': totalBricks,
      'averageSale': sales.isEmpty ? 0.0 : totalAmount / sales.length,
    };
  }

  // Calculate financial summary
  static Map<String, dynamic> getFinancialSummary(List<TransactionItem> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var txn in transactions) {
      if (txn.type == TransactionType.credit) {
        totalIncome += txn.amount ?? 0.0;
      } else {
        totalExpense += txn.amount ?? 0.0;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netProfit': totalIncome - totalExpense,
      'transactionCount': transactions.length,
    };
  }
}
