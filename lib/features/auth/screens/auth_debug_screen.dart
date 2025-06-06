import 'package:flutter/material.dart';
import 'package:afrilingo/features/auth/services/auth_service.dart';

class AuthDebugScreen extends StatefulWidget {
  const AuthDebugScreen({Key? key}) : super(key: key);

  @override
  _AuthDebugScreenState createState() => _AuthDebugScreenState();
}

class _AuthDebugScreenState extends State<AuthDebugScreen> {
  final _authService = AuthService();
  Map<String, dynamic> _diagnostics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDiagnostics();
  }

  Future<void> _fetchDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diagnostics = await _authService.getAuthDiagnostics();
      setState(() {
        _diagnostics = diagnostics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diagnostics = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDiagnostics,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authentication Diagnostics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildDiagnosticItems(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      _fetchDiagnostics();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildDiagnosticItems() {
    final items = <Widget>[];

    _diagnostics.forEach((key, value) {
      Widget valueWidget;

      if (value is Map) {
        valueWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        );
      } else {
        valueWidget = Text(
          value.toString(),
          style: TextStyle(
            color: key.contains('error') ? Colors.red : Colors.black87,
            fontWeight:
                key.contains('error') ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }

      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              valueWidget,
              const Divider(),
            ],
          ),
        ),
      );
    });

    return items;
  }
}
