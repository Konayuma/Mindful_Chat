import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Debug screen to test API connectivity
/// Access from chat screen or add a debug button
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _healthStatus = 'Not checked';
  String _apiInfoStatus = 'Not checked';
  String _queryStatus = 'Not checked';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  Future<void> _runAllTests() async {
    setState(() => _isLoading = true);
    
    // Test 1: Health Check
    await _testHealth();
    await Future.delayed(const Duration(seconds: 1));
    
    // Test 2: API Info
    await _testApiInfo();
    await Future.delayed(const Duration(seconds: 1));
    
    // Test 3: Sample Query
    await _testQuery();
    
    setState(() => _isLoading = false);
  }

  Future<void> _testHealth() async {
    try {
      final health = await ApiService.checkHealth();
      setState(() {
        _healthStatus = '✅ Connected!\n${health.toString()}';
      });
    } catch (e) {
      setState(() {
        _healthStatus = '❌ Failed: $e';
      });
    }
  }

  Future<void> _testApiInfo() async {
    try {
      final info = await ApiService.getApiInfo();
      setState(() {
        _apiInfoStatus = '✅ Success!\n${info.toString()}';
      });
    } catch (e) {
      setState(() {
        _apiInfoStatus = '❌ Failed: $e';
      });
    }
  }

  Future<void> _testQuery() async {
    try {
      final response = await ApiService.queryFaq('What is anxiety?');
      
      if (response.results.isNotEmpty) {
        final bestResult = response.results.first;
        final otherResults = response.results.skip(1).take(2).map((r) => 
          '  • ${r.question} (${(r.score * 100).toStringAsFixed(1)}%)'
        ).join('\n');
        
        setState(() {
          _queryStatus = '✅ Query Success!\n'
              'Success: ${response.success}\n'
              'Total Results: ${response.totalResults}\n\n'
              '🏆 Best Match (Used in Chat):\n'
              'Q: ${bestResult.question}\n'
              'Score: ${(bestResult.score * 100).toStringAsFixed(1)}%\n'
              'Category: ${bestResult.category}\n'
              'Answer: ${bestResult.answer.substring(0, 100)}...\n\n'
              'Other Results (Not Shown):\n$otherResults\n\n'
              'Note: Chat shows only the best answer';
        });
      } else {
        setState(() {
          _queryStatus = '✅ Query Success!\nNo results found';
        });
      }
    } catch (e) {
      setState(() {
        _queryStatus = '❌ Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runAllTests,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Testing connection to:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'https://slmchatcore.onrender.com',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Running tests...\nFirst request may take 30-60 seconds'),
                  ],
                ),
              )
            else ...[
              _buildTestResult('Health Check', _healthStatus),
              const SizedBox(height: 16),
              _buildTestResult('API Info', _apiInfoStatus),
              const SizedBox(height: 16),
              _buildTestResult('Sample Query', _queryStatus),
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text(
              '💡 Tips:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• First request may take 30-60 seconds (cold start)'),
            const Text('• Subsequent requests should be fast (<2 seconds)'),
            const Text('• If all tests pass, the app is properly configured'),
            const Text('• If tests fail, check your internet connection'),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runAllTests,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Tests Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String title, String result) {
    final isSuccess = result.startsWith('✅');
    final isNotChecked = result == 'Not checked';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNotChecked
            ? Colors.grey[100]
            : (isSuccess ? Colors.green[50] : Colors.red[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNotChecked
              ? Colors.grey
              : (isSuccess ? Colors.green : Colors.red),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result,
            style: TextStyle(
              fontSize: 14,
              color: isNotChecked ? Colors.grey[600] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
