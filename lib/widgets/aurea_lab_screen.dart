import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../aurea/aurea_model.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import 'haze_face.dart';
import '../theme/haze_theme.dart';

/// A self-contained counterfactual lab. It never writes companion chemistry,
/// chat history or personality, and needs no model download or network access.
class AureaLabScreen extends StatefulWidget {
  final RobotFaceState faceState;
  final VoidCallback? onOpenChemistry;
  const AureaLabScreen({
    super.key,
    this.faceState = const RobotFaceState(),
    this.onOpenChemistry,
  });

  @override
  State<AureaLabScreen> createState() => _AureaLabScreenState();
}

class _AureaLabScreenState extends State<AureaLabScreen>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFEBCB8B);
  late final AnimationController _clock;
  late Future<AureaCatalog> _catalog;
  int _selected = 0;
  int _interpretation = 0;
  bool _practiced = false;
  bool _started = false;

  Future<AureaCatalog> _load() async => AureaCatalog.decode(
    await rootBundle.loadString('assets/aurea/prototype.json'),
  );

  @override
  void initState() {
    super.initState();
    _catalog = _load();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  static final _projectUrl = Uri.parse('https://aureasystem.com');

  Future<void> _openProject() async {
    try {
      if (await launchUrl(_projectUrl, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Offer a usable fallback if this platform has no browser available.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.aurea.websiteError),
        action: SnackBarAction(
          label: t.aurea.copyLink,
          onPressed: () =>
              Clipboard.setData(ClipboardData(text: _projectUrl.toString())),
        ),
      ),
    );
  }

  void _reset() {
    _clock.reset();
    _started = false;
  }

  @override
  Widget build(BuildContext context) {
    final language = TranslationProvider.of(context).flutterLocale.languageCode;
    final copy = t.aurea;
    return Theme(
      data: HazeTheme.of(true),
      child: Scaffold(
        appBar: AppBar(
          title: Text(copy.title),
          backgroundColor: const Color(0xFF0A1018),
          actions: [
            IconButton(
              tooltip: copy.reset,
              onPressed: () => setState(() {
                _reset();
                _selected = 0;
                _interpretation = 0;
                _practiced = false;
              }),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder<AureaCatalog>(
            future: _catalog,
            builder: (context, loaded) {
              if (loaded.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(copy.loadingError),
                      TextButton(
                        onPressed: () => setState(() => _catalog = _load()),
                        child: Text(copy.retry),
                      ),
                    ],
                  ),
                );
              }
              if (!loaded.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final catalog = loaded.requireData;
              final scenario = catalog.scenarios[_selected];
              return AnimatedBuilder(
                animation: _clock,
                builder: (context, _) {
                  final snapshot = AureaSimulation(catalog).sample(
                    scenario,
                    progress: _clock.value,
                    interpretation: _interpretation,
                    practiced: _practiced,
                  );
                  final compound = catalog.compound(scenario.id);
                  final compoundName = AureaCatalog.localized(
                    compound['name'],
                    language,
                  );
                  final line = switch (snapshot.phase) {
                    AureaPhase.notice => scenario.text('notice', language),
                    AureaPhase.interpret => scenario.choice(
                      'consider',
                      _interpretation,
                      language,
                    ),
                    AureaPhase.act => scenario.choice(
                      'action',
                      _interpretation,
                      language,
                    ),
                  };
                  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                  final performance = ColoredBox(
                    color: const Color(0xFF0A1018),
                    child: _section(
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _gold.withValues(alpha: .2),
                                ),
                                gradient: const RadialGradient(
                                  radius: .95,
                                  colors: [
                                    Color(0xFF1D3036),
                                    Color(0xFF080F16),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    copy.phases[snapshot.phase.index]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: _gold,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Expanded(
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        -snapshot.expression.approach * 8,
                                      ),
                                      child: HazeFace(
                                        state: RobotFaceState(
                                          config: widget.faceState.config
                                              .copyWith(isDarkTheme: true),
                                        ),
                                        affect: snapshot.expression,
                                        framed: false,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      0,
                                      22,
                                      18,
                                    ),
                                    child: Semantics(
                                      liveRegion: true,
                                      child: Text(
                                        _started ? line : copy.ready,
                                        key: const ValueKey('aurea-dialogue'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Slider(
                            value: _clock.value,
                            label: copy.phases[snapshot.phase.index],
                            semanticFormatterCallback: (_) =>
                                copy.phases[snapshot.phase.index],
                            onChanged: (value) => setState(() {
                              _started = true;
                              _clock.stop();
                              _clock.value = value;
                            }),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => setState(() {
                                _started = true;
                                if (_clock.isAnimating) {
                                  _clock.stop();
                                } else if (_clock.isCompleted) {
                                  _clock.forward(from: 0);
                                } else {
                                  _clock.forward();
                                }
                              }),
                              icon: Icon(
                                _clock.isAnimating
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                _clock.isAnimating
                                    ? copy.pause
                                    : _clock.isCompleted
                                    ? copy.replay
                                    : _clock.value > 0
                                    ? copy.resume
                                    : copy.play,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return CustomScrollView(
                    key: const PageStorageKey('aurea-scroll'),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _section(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                copy.prototype,
                                style: const TextStyle(
                                  color: _gold,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                copy.subtitle,
                                style: const TextStyle(
                                  fontSize: 27,
                                  height: 1.12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                copy.introduction,
                                style: const TextStyle(
                                  color: Color(0xFFB3C0CD),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Semantics(
                                label: copy.choose,
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < catalog.scenarios.length;
                                      i++
                                    )
                                      ChoiceChip(
                                        label: Text(
                                          AureaCatalog.localized(
                                            catalog.compound(
                                              catalog.scenarios[i].id,
                                            )['name'],
                                            language,
                                          ),
                                        ),
                                        selected: _selected == i,
                                        onSelected: (_) => setState(() {
                                          _selected = i;
                                          _interpretation = 0;
                                          _reset();
                                        }),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                scenario.text('title', language),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                scenario.text('event', language),
                                style: const TextStyle(
                                  color: Color(0xFFCFD6DE),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned:
                            MediaQuery.sizeOf(context).height > 650 &&
                            scale < 1.5,
                        delegate: _PerformanceHeader(
                          height: 350 + (scale - 1).clamp(0, 2) * 350,
                          child: performance,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _section(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 22),
                              Text(
                                copy.interpretation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (var i = 0; i < 2; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        foregroundColor: _interpretation == i
                                            ? _gold
                                            : Colors.white70,
                                        side: BorderSide(
                                          color: _interpretation == i
                                              ? _gold
                                              : Colors.white24,
                                        ),
                                      ),
                                      onPressed: () =>
                                          setState(() => _interpretation = i),
                                      icon: Icon(
                                        _interpretation == i
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 19,
                                      ),
                                      label: Text(
                                        scenario.choice(
                                          'interpretations',
                                          i,
                                          language,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Text(
                                copy.sameEvent,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                copy.history,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: Text(copy.firstTime),
                                    selected: !_practiced,
                                    onSelected: (_) =>
                                        setState(() => _practiced = false),
                                  ),
                                  ChoiceChip(
                                    label: Text(copy.practiced),
                                    selected: _practiced,
                                    onSelected: (_) =>
                                        setState(() => _practiced = true),
                                  ),
                                ],
                              ),
                              Text(
                                _practiced
                                    ? scenario.text('practice', language)
                                    : copy.firstEffect,
                                style: const TextStyle(
                                  color: Color(0xFFCFD6DE),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                copy.historyHint,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Material(
                                color: const Color(0xFF17212C),
                                borderRadius: BorderRadius.circular(18),
                                clipBehavior: Clip.antiAlias,
                                child: ExpansionTile(
                                  key: PageStorageKey('why-${scenario.id}'),
                                  title: Text(copy.why),
                                  subtitle: Text(
                                    copy.whyHint,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    18,
                                  ),
                                  children: [
                                    for (final layer in [
                                      'chemistry',
                                      'emotion',
                                      'appraisal',
                                      'value',
                                    ])
                                      if ((compound['ingredients'] as List).any(
                                        (id) =>
                                            catalog.ingredients[id]['layer'] ==
                                            layer,
                                      ))
                                        _layer(
                                          catalog,
                                          compound,
                                          snapshot,
                                          layer,
                                          language,
                                        ),
                                    const Divider(height: 24),
                                    _label(copy.layers[4], compoundName),
                                    const SizedBox(height: 8),
                                    Text(
                                      snapshot.phase != AureaPhase.act
                                          ? copy.forming
                                          : snapshot.strength >= .3
                                          ? copy.emerging
                                          : copy.incomplete,
                                      style: const TextStyle(color: _gold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _interpretation == 1
                                          ? scenario.text('blocked', language)
                                          : _practiced
                                          ? copy.practiceEffect
                                          : copy.firstEffect,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      copy.signalNote,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                copy.modelNote,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                  height: 1.5,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _openProject,
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: Text(copy.website),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                copy.source,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                              if (widget.onOpenChemistry != null)
                                TextButton.icon(
                                  onPressed: widget.onOpenChemistry,
                                  icon: const Icon(
                                    Icons.science_outlined,
                                    size: 18,
                                  ),
                                  label: Text(copy.chemistry),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _section(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: child,
      ),
    ),
  );

  Widget _label(String layer, String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        layer.toUpperCase(),
        style: const TextStyle(color: _gold, fontSize: 10, letterSpacing: 1.3),
      ),
      const SizedBox(height: 6),
      Text(text),
    ],
  );

  Widget _layer(
    AureaCatalog catalog,
    Map<String, dynamic> compound,
    AureaSnapshot snapshot,
    String layer,
    String language,
  ) {
    const layers = ['chemistry', 'emotion', 'appraisal', 'value'];
    final ids = (compound['ingredients'] as List).cast<String>().where(
      (id) => catalog.ingredients[id]['layer'] == layer,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in ids) ...[
            _label(
              t.aurea.layers[layers.indexOf(layer)],
              AureaCatalog.localized(
                catalog.ingredients[id]['label'],
                language,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: snapshot.levels[id] ?? 0,
              color: _gold,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PerformanceHeader extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _PerformanceHeader({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _PerformanceHeader oldDelegate) => true;
}
