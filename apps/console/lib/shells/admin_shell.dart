import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import '../admin/management/class_editor.dart';
import '../admin/management/csv_import.dart';
import '../admin/management/teacher_editor.dart';
import '../admin/reflection/reflection_campaign_panel.dart';
import '../admin/overview/difficulty_ranking.dart';
import '../admin/overview/kpi_cards.dart';
import '../admin/risk/at_risk_table.dart';
import '../admin/risk/recommendation_panel.dart';

/// The navigation shell for a signed-in administrator: overview, risk and
/// management, each a nested `GoRoute` under `/admin`.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.gateway,
    required this.navigationShell,
  });

  final AuthGateway gateway;
  final StatefulNavigationShell navigationShell;

  static const List<String> _labels = <String>[
    'Overview',
    'Risk',
    'Management',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.dashboard,
    Icons.warning_amber,
    Icons.admin_panel_settings,
  ];

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 720;
    final Widget body = navigationShell;

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SyncEdu — Administrator'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => gateway.signOut(),
            ),
          ],
        ),
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) =>
                  navigationShell.goBranch(index),
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                for (int i = 0; i < _labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncEdu — Administrator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => gateway.signOut(),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(index),
        destinations: <NavigationDestination>[
          for (int i = 0; i < _labels.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
        ],
      ),
    );
  }
}

/// Zeroed KPIs -- placeholder until a future task streams real school-wide
/// figures in; enough to prove the overview tab renders and is reachable.
const SchoolKpis _zeroKpis = SchoolKpis(
  totalStudents: 0,
  totalTeachers: 0,
  studentsAtRisk: 0,
  averageMastery: 0,
);

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key, required this.db});

  // Unused until a future task streams live KPI/difficulty figures through
  // this tab; kept as a constructor parameter now so the router's signature
  // does not need to change again when that wiring lands.
  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        KpiCards(kpis: _zeroKpis),
        SizedBox(height: 24),
        DifficultyRanking(ranked: <DifficultyRank>[]),
      ],
    );
  }
}

class AdminRiskTab extends StatelessWidget {
  const AdminRiskTab({super.key, required this.db});

  // Unused until a future task streams live at-risk/recommendation figures
  // through this tab; see [AdminOverviewTab.db].
  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const AtRiskTable(rows: <RiskRow>[]),
        const SizedBox(height: 24),
        RecommendationPanel(
          recommendations: const <ResourceRecommendation>[],
          thresholds: const AnalyticsThresholds.standard(),
        ),
      ],
    );
  }
}

class AdminManagementTab extends StatefulWidget {
  const AdminManagementTab({super.key, required this.db});

  final SyncEduDatabase db;

  @override
  State<AdminManagementTab> createState() => _AdminManagementTabState();
}

class _AdminManagementTabState extends State<AdminManagementTab> {
  int _selected = 0;

  static const List<String> _labels = <String>[
    'Classes',
    'Teachers',
    'Roster import',
    'Placement & reflection',
  ];

  @override
  Widget build(BuildContext context) {
    final ManagementRepository repository = ManagementRepository(
      widget.db,
      OutboxWriter(widget.db),
    );
    // ClassEditor lays out an internal Expanded (its class list fills
    // whatever height it is given), so it needs the bounded height a plain
    // scrolling list of full-page widgets does not provide. Rendering only
    // the selected section directly (rather than an `IndexedStack`, whose
    // non-selected children are treated as offstage and so are invisible to
    // widget-test finders even though they are mounted, or a `TabBarView`,
    // which only builds pages within its viewport cache) gives the active
    // editor the full available height while keeping every section equally
    // reachable and testable.
    final Widget section = switch (_selected) {
      0 => ClassEditor(repository: repository, schoolId: 'school'),
      1 => TeacherEditor(repository: repository, schoolId: 'school'),
      2 => CsvImport(repository: repository, schoolId: 'school'),
      _ => ReflectionCampaignPanel(
          repository: ReflectionCampaignRepository(widget.db),
          schoolId: 'school',
        ),
    };

    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < _labels.length; i++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ChoiceChip(
                    label: Text(_labels[i]),
                    selected: _selected == i,
                    onSelected: (_) => setState(() => _selected = i),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: section),
      ],
    );
  }
}
