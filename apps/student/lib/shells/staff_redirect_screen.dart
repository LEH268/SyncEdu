import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

class StaffRedirectScreen extends StatelessWidget {
  const StaffRedirectScreen({super.key, required this.gateway});

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
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Teacher and administrator accounts use the SyncEdu web console.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
