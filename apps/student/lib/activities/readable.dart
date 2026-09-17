import 'package:flutter/material.dart';

/// The family name the app ships a dyslexia-friendly face under. If the asset
/// is absent the platform falls back, but the substitution is still
/// observable (the family name changes), which is what §8.5 asks for beyond
/// the generation-side accessibility work.
const String kReadableFontFamily = 'OpenDyslexic';

bool wantsReadableFont(Iterable<String> specialNeeds) => specialNeeds
    .any((String n) => n.trim().toLowerCase() == 'dyslexia');

/// Returns [base] unchanged unless the student carries the Dyslexia label, in
/// which case the text theme is swapped to the readable family with looser
/// spacing and taller lines.
ThemeData withReadability(ThemeData base, Iterable<String> specialNeeds) {
  if (!wantsReadableFont(specialNeeds)) return base;
  final TextTheme t = base.textTheme.apply(
    fontFamily: kReadableFontFamily,
    fontSizeFactor: 1.05,
  );
  TextStyle? loosen(TextStyle? s) =>
      s?.copyWith(letterSpacing: 0.5, height: 1.5);
  return base.copyWith(
    textTheme: t.copyWith(
      bodySmall: loosen(t.bodySmall),
      bodyMedium: loosen(t.bodyMedium),
      bodyLarge: loosen(t.bodyLarge),
      titleMedium: loosen(t.titleMedium),
    ),
  );
}

/// Wraps [child] in a [Theme] that applies [withReadability].
class ReadableRegion extends StatelessWidget {
  const ReadableRegion({super.key, required this.specialNeeds, required this.child});

  final List<String> specialNeeds;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: withReadability(Theme.of(context), specialNeeds),
      child: child,
    );
  }
}
