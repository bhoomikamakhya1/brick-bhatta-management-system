import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../services/sale_data_service.dart';
import 'add_transaction_screen.dart';

class SaleLogsScreen extends StatefulWidget {
  const SaleLogsScreen({super.key});

  @override
  State<SaleLogsScreen> createState() => _SaleLogsScreenState();
}

class _SaleLogsScreenState extends State<SaleLogsScreen> {
  List<SaleEntry> _sales = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSales();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSales() {
    setState(() {
      _sales = SaleDataService.getAllSales();
    });
  }

  List<SaleEntry> get _filteredSales {
    if (_searchQuery.isEmpty) return _sales;
    return _sales.where((sale) {
      return sale.customerName.toLowerCase().contains(_searchQuery) ||
             sale.customerNameHindi.toLowerCase().contains(_searchQuery) ||
             sale.otp!.contains(_searchQuery) ?? false;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Sale Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or OTP...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Sales List
          Expanded(
            child: _filteredSales.isEmpty
                ? const Center(
                    child: Text(
                      'No sales found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            sale.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatDate(sale.date)} ${_formatTime(sale.time)} | OTP: ${sale.otp ?? "N/A"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF8B4513)),
                                onPressed: () => _editSale(sale),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSale(sale),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Customer (Hindi)', sale.customerNameHindi),
                                  if (sale.customerAddress != null)
                                    _buildDetailRow('Address', sale.customerAddress!),
                                  if (sale.customerPhone != null)
                                    _buildDetailRow('Phone', sale.customerPhone!),
                                  const Divider(),
                                  const Text(
                                    'Brick Entries:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...sale.brickEntries.map((entry) => Padding(
                                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                                    child: Text(
                                      '${entry.brickType}: ${entry.quantity.toStringAsFixed(0)} pcs @ ₹${entry.price.toStringAsFixed(2)} = ₹${(entry.quantity * entry.price).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )),
                                  const Divider(),
                                  if (sale.freightDetails != null) ...[
                                    const Text(
                                      'Freight Details:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailRow('Type', sale.freightDetails!.type == 'self' ? 'Self' : 'Sending'),
                                    if (sale.freightDetails!.vehicleNumber != null)
                                      _buildDetailRow('Vehicle Number', sale.freightDetails!.vehicleNumber!),
                                    if (sale.freightDetails!.vehicleName != null)
                                      _buildDetailRow('Vehicle Name', sale.freightDetails!.vehicleName!),
                                    if (sale.freightDetails!.driverName != null)
                                      _buildDetailRow('Driver Name', sale.freightDetails!.driverName!),
                                    if (sale.freightDetails!.driverPhone != null)
                                      _buildDetailRow('Driver Phone', sale.freightDetails!.driverPhone!),
                                    _buildDetailRow('Freight Rate', '₹${sale.freightDetails!.ratePer1000.toStringAsFixed(2)} per 1000 bricks'),
                                    const Divider(),
                                  ],
                                  _buildDetailRow('Advance Payment', '₹${sale.advancePayment.toStringAsFixed(2)}'),
                                  _buildDetailRow('Total Amount', '₹${sale.totalAmount.toStringAsFixed(2)}'),
                                  _buildDetailRow('Final Amount', '₹${sale.finalAmount.toStringAsFixed(2)}'),
                                  if (sale.remarks != null && sale.remarks!.isNotEmpty)
                                    _buildDetailRow('Remarks', sale.remarks!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _editSale(SaleEntry sale) {
    // TODO: Navigate to edit screen with sale data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteSale(SaleEntry sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: Text('Are you sure you want to delete sale for ${sale.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SaleDataService.deleteSale(sale.id);
              _loadSales();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sale deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

