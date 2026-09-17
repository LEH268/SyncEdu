import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A placeholder destination for the tool routes Phase 9 fills in --
/// flashcards, story, notes, progress. Reachable by button and by voice today;
/// real behind the same route tomorrow.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$title is coming soon.'),
            if (detail != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(detail!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('coming-soon-home'),
              onPressed: () => context.go('/home'),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
