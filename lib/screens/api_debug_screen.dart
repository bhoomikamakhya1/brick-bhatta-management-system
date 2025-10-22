import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/name_model.dart';

class ApiDebugScreen extends StatefulWidget {
  const ApiDebugScreen({super.key});

  @override
  State<ApiDebugScreen> createState() => _ApiDebugScreenState();
}

class _ApiDebugScreenState extends State<ApiDebugScreen> {
  String _debugOutput = 'Ready to test API...';
  bool _isLoading = false;

  void _addDebugOutput(String message) {
    setState(() {
      _debugOutput += '\n$message';
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Testing connection...';
    });

    try {
      final success = await ApiService.testConnection();
      _addDebugOutput('Connection test: ${success ? "✅ SUCCESS" : "❌ FAILED"}');
    } catch (e) {
      _addDebugOutput('❌ Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testNamesEndpoint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.testNamesEndpoint();
      _addDebugOutput('Names endpoint test completed');
    } catch (e) {
      _addDebugOutput('❌ Names endpoint error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSendName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final testName = NameModel(
        displayName: 'Test User',
        group: 'Labour',
        phone: '1234567890',
      );
      
      _addDebugOutput('Sending test name: ${testName.toJson()}');
      
      final response = await ApiService.sendName(testName);
      if (response != null) {
        _addDebugOutput('✅ Successfully sent name: $response');
      } else {
        _addDebugOutput('❌ Failed to send name');
      }
    } catch (e) {
      _addDebugOutput('❌ Send name error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFetchNames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final names = await ApiService.fetchNames();
      _addDebugOutput('✅ Fetched ${names.length} names from backend');
      for (var name in names) {
        _addDebugOutput('  - ${name.displayName} (${name.group})');
      }
    } catch (e) {
      _addDebugOutput('❌ Fetch names error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _wakeUpService() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Waking up service...';
    });

    try {
      final success = await ApiService.wakeUpService();
      _addDebugOutput('Service wake-up: ${success ? "✅ SUCCESS" : "❌ FAILED"}');
      if (success) {
        _addDebugOutput('Service is now awake and ready for requests');
      } else {
        _addDebugOutput('Service may still be sleeping or unavailable');
      }
    } catch (e) {
      _addDebugOutput('❌ Wake-up error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Test buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _wakeUpService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🌅 Wake Up Service'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testNamesEndpoint,
                  child: const Text('Test Names Endpoint'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testSendName,
                  child: const Text('Send Test Name'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testFetchNames,
                  child: const Text('Fetch Names'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _debugOutput = 'Ready to test API...';
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Loading indicator
            if (_isLoading)
              const CircularProgressIndicator(),
            
            const SizedBox(height: 16),
            
            // Debug output
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugOutput,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
