import '../models/labour_work_model.dart';

class WorkDataService {
  static final List<LabourWork> _workEntries = [];
  static int _nextId = 1;

  /// Add a new work entry
  static void addWorkEntry(LabourWork work) {
    _workEntries.insert(0, work); // Add to beginning of list
    print('✅ WorkDataService: Added work entry for ${work.labourName}');
  }

  /// Get all work entries
  static List<LabourWork> getAllWorkEntries() {
    return List.from(_workEntries);
  }

  /// Get work entries by category
  static List<LabourWork> getWorkEntriesByCategory(String category) {
    return _workEntries.where((work) => work.labourCategory.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get work entries for today
  static List<LabourWork> getTodayWorkEntries() {
    final today = DateTime.now();
    return _workEntries.where((work) => 
      work.date.day == today.day &&
      work.date.month == today.month &&
      work.date.year == today.year
    ).toList();
  }

  /// Get work entries for a specific date range
  static List<LabourWork> getWorkEntriesByDateRange(DateTime startDate, DateTime endDate) {
    return _workEntries.where((work) => 
      work.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      work.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  /// Get total amount for all work entries
  static double getTotalAmount() {
    return _workEntries.fold(0.0, (sum, work) => sum + work.totalAmount);
  }

  /// Get total amount for a specific category
  static double getTotalAmountByCategory(String category) {
    return _workEntries
        .where((work) => work.labourCategory.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, work) => sum + work.totalAmount);
  }

  /// Get work statistics
  static Map<String, dynamic> getWorkStatistics() {
    final totalEntries = _workEntries.length;
    final totalAmount = getTotalAmount();
    final todayEntries = getTodayWorkEntries().length;
    
    final categoryStats = <String, int>{};
    final categoryAmounts = <String, double>{};
    
    for (final work in _workEntries) {
      categoryStats[work.labourCategory] = (categoryStats[work.labourCategory] ?? 0) + 1;
      categoryAmounts[work.labourCategory] = (categoryAmounts[work.labourCategory] ?? 0.0) + work.totalAmount;
    }

    return {
      'totalEntries': totalEntries,
      'totalAmount': totalAmount,
      'todayEntries': todayEntries,
      'categoryStats': categoryStats,
      'categoryAmounts': categoryAmounts,
    };
  }

  /// Generate a unique ID for new work entries
  static String generateId() {
    return (_nextId++).toString();
  }

  /// Clear all work entries (for testing purposes)
  static void clearAllEntries() {
    _workEntries.clear();
    _nextId = 1;
    print('🗑️ WorkDataService: Cleared all work entries');
  }

  /// Get recent work entries (last 10)
  static List<LabourWork> getRecentWorkEntries({int limit = 10}) {
    return _workEntries.take(limit).toList();
  }

  /// Search work entries by labour name
  static List<LabourWork> searchWorkEntriesByName(String name) {
    return _workEntries.where((work) => 
      work.labourName.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }

  /// Update a work entry
  static bool updateWorkEntry(String id, LabourWork updatedWork) {
    final index = _workEntries.indexWhere((work) => work.id == id);
    if (index != -1) {
      _workEntries[index] = updatedWork;
      print('✅ WorkDataService: Updated work entry $id');
      return true;
    }
    print('❌ WorkDataService: Work entry $id not found');
    return false;
  }

  /// Delete a work entry
  static bool deleteWorkEntry(String id) {
    final index = _workEntries.indexWhere((work) => work.id == id);
    if (index != -1) {
      final deletedWork = _workEntries.removeAt(index);
      print('✅ WorkDataService: Deleted work entry ${deletedWork.labourName}');
      return true;
    }
    print('❌ WorkDataService: Work entry $id not found');
    return false;
  }
}
