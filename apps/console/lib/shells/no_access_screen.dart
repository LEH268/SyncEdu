import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key, required this.gateway});

  final AuthGateway gateway;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => gateway.signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('The console is not available for student accounts.'),
      ),
    );
  }
}
