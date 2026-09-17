import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'onboarding_repository.dart';

/// Tracks the two mandatory interrupts so `go_router`'s `redirect` can force
/// them without awaiting the database. An incomplete Pre-admission Test sends
/// every route to `/pre-admission`; an open reflection campaign with no
/// submitted response raises `/year-end-reflection` on next launch (spec
/// §8.1). Pre-admission takes precedence.
///
/// It follows the gateway's claim stream, so it re-points at the right
/// student after a sign-in (the router, and therefore this state, is built
/// once before anyone has signed in).
class OnboardingState extends ChangeNotifier {
  OnboardingState({
    required this.repository,
    required AuthGateway gateway,
  }) {
    _claimsSub = gateway.claimsChanges.listen((SessionClaims? claims) {
      _bindProfile(claims?.userId);
    });
    _bindProfile(gateway.currentClaims?.userId);
    _campaignSub = repository.watchOpenCampaigns().listen((_) => _recomputeReflection());
  }

  final OnboardingRepository repository;

  StreamSubscription<SessionClaims?>? _claimsSub;
  StreamSubscription<Student?>? _studentSub;
  StreamSubscription<List<ReflectionCampaign>>? _campaignSub;
  StreamSubscription<List<YearEndReflection>>? _reflectionSub;

  String? _profileId;
  String? _studentId;
  bool _preAdmissionComplete = true;
  bool _reflectionDue = false;

  /// Null until the student row reaches this device.
  String? get studentId => _studentId;
  bool get preAdmissionComplete => _preAdmissionComplete;
  bool get reflectionDue => _reflectionDue;

  void _bindProfile(String? profileId) {
    if (profileId == _profileId) return;
    _profileId = profileId;
    _studentSub?.cancel();
    _reflectionSub?.cancel();
    _studentId = null;
    _preAdmissionComplete = true;
    _reflectionDue = false;
    if (profileId != null && profileId.isNotEmpty) {
      _studentSub = repository.watchStudent(profileId).listen(_onStudent);
    }
    notifyListeners();
  }

  void _onStudent(Student? student) {
    final String? id = student?.id;
    final bool complete = student?.preAdmissionCompletedAt != null;
    bool changed = false;

    if (id != _studentId) {
      _studentId = id;
      changed = true;
      _reflectionSub?.cancel();
      if (id != null) {
        _reflectionSub =
            repository.watchReflections(id).listen((_) => _recomputeReflection());
      }
    }
    if (complete != _preAdmissionComplete) {
      _preAdmissionComplete = complete;
      changed = true;
    }
    if (changed) notifyListeners();
    _recomputeReflection();
  }

  Future<void> _recomputeReflection() async {
    final String? id = _studentId;
    if (id == null) {
      if (_reflectionDue) {
        _reflectionDue = false;
        notifyListeners();
      }
      return;
    }
    final ReflectionCampaign? due = await repository.openUnansweredCampaign(id);
    final bool next = due != null;
    if (next != _reflectionDue) {
      _reflectionDue = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _claimsSub?.cancel();
    _studentSub?.cancel();
    _campaignSub?.cancel();
    _reflectionSub?.cancel();
    super.dispose();
  }
}
