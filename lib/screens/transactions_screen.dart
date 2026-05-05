import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'transaction_type_selection_screen.dart';
import 'transaction_detail_screen.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  
  String _selectedParty = 'All Parties';
  String _selectedCategory = 'All Categories';
  String _selectedDate = 'dd-mm-yyyy';
  String _selectedType = 'All Types';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<String> _parties = [
    'All Parties',
    'Raj Brick Kiln',
    'Sharma Construction',
    'Gupta Transport',
    'Patel Builders',
    'Singh Enterprises',
  ];

  final List<String> _categories = [
    'All Categories',
    'Sales',
    'Purchase',
    'Labor Payment',
    'Transport',
    'Fuel',
    'Maintenance',
  ];

  final List<String> _types = [
    'All Types',
    'Credit',
    'Debit',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionItem> get _filteredTransactions {
    return _transactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!transaction.englishName.toLowerCase().contains(query) &&
            !transaction.hindiName.toLowerCase().contains(query) &&
            !transaction.category.toLowerCase().contains(query) &&
            !transaction.amount.toString().contains(query)) {
          return false;
        }
      }

      // Filter by party
      if (_selectedParty != 'All Parties') {
        if (!transaction.englishName.toLowerCase().contains(_selectedParty.toLowerCase())) {
          return false;
        }
      }

      // Filter by type
      if (_selectedType != 'All Types') {
        final transactionTypeString = transaction.type == TransactionType.credit ? 'Credit' : 'Debit';
        if (transactionTypeString != _selectedType) {
          return false;
        }
      }

      // Filter by date (if date is selected and not default)
      if (_selectedDate != 'dd-mm-yyyy') {
        // Extract day from selected date and check if transaction date contains it
        final selectedDay = _selectedDate.split('-')[0];
        if (!transaction.date.contains(selectedDay)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'All Categories') {
        if (transaction.category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txns = await TransactionService.fetchTransactions();
    if (mounted) {
      setState(() {
        _transactions = txns;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearching,
      onPopInvoked: (didPop) {
        if (!didPop && _isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _searchController.clear();
          });
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : const Text(
              'Transactions / लेन-देन',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // First row of filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Party / पार्टी',
                        value: _selectedParty,
                        items: _parties,
                        onChanged: (value) {
                          setState(() {
                            _selectedParty = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Category / श्रेणी',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Second row of filters
                Row(
                  children: [
                    Expanded(
                      child: _buildDateFilter(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Type / प्रकार',
                        value: _selectedType,
                        items: _types,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
                : _filteredTransactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_transaction_fab",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionTypeSelectionScreen(),
            ),
          );
          
          // If a new transaction was added, add it to the backend
          // Note: TransactionService.addTransaction already adds it to the local list
          if (result is TransactionItem) {
            final createdTransaction = await TransactionService.addTransaction(result);
            if (createdTransaction != null) {
              // Refresh the list from the service (it's already added there, so no need to insert again)
              setState(() {
                _transactions = TransactionService.getAllTransactions();
              });
            }
          }
        },
        backgroundColor: const Color(0xFFFF6F00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date / तारीख',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionItem transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction.hindiName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              transaction.englishName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${transaction.amount?.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: transaction.type == TransactionType.credit
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.type == TransactionType.credit ? 'Credit' : 'Debit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              transaction.date,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }
}

