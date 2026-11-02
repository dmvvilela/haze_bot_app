import 'package:flutter/material.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import '../models/haze_look.dart';
import '../models/robot_config.dart';
import '../services/haze_plus_controller.dart';
import '../services/robot_voice_service.dart';
import 'haze_face.dart';

class HazePlusScreen extends StatefulWidget {
  final HazePlusController controller;
  final RobotFaceState faceState;
  const HazePlusScreen({
    super.key,
    required this.controller,
    required this.faceState,
  });

  @override
  State<HazePlusScreen> createState() => _HazePlusScreenState();
}

class _HazePlusScreenState extends State<HazePlusScreen> {
  late HazeFaceStyle _style;
  late HazeAccessory _accessory;
  int _expression = 0;
  static const _expressions = [
    RobotExpression.happy,
    RobotExpression.surprised,
    RobotExpression.love,
    RobotExpression.confused,
  ];
  HazePlusController get plus => widget.controller;
  HazeLook get _look => HazeLook(style: _style, accessory: _accessory);

  @override
  void initState() {
    super.initState();
    _style = plus.ownsPlus ? plus.look.style : HazeFaceStyle.orbit;
    _accessory = plus.ownsPlus ? plus.look.accessory : HazeAccessory.headphones;
  }

  Future<void> _apply(HazeLook look) async {
    if (await plus.apply(look) && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.plus.applied)));
      }
    }
  }

  Future<void> _buy() async {
    final look = _look;
    await plus.purchase();
    if (mounted && plus.ownsPlus) await _apply(look);
  }

  String _message(PlusMessage message) => switch (message) {
    PlusMessage.unavailable => t.plus.unavailable,
    PlusMessage.failed => t.plus.failed,
    PlusMessage.pending => t.plus.pending,
    PlusMessage.unlocked => t.plus.unlocked,
    PlusMessage.restored => t.plus.restored,
    PlusMessage.nothingToRestore => t.plus.nothing_to_restore,
    PlusMessage.saveFailed => t.plus.save_failed,
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: plus,
    builder: (context, _) {
      final colors = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(
          title: Text(t.plus.title),
          actions: [
            if (plus.ownsPlus)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(Icons.verified_outlined, color: colors.primary),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.plus.headline,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.plus.description,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF172339),
                              Color(0xFF090F1C),
                              Color(0xFF21192D),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFFFD28A),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      plus.ownsPlus
                                          ? t.plus.owned
                                          : t.plus.forever,
                                      style: const TextStyle(
                                        color: Color(0xFFFFD28A),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Semantics(
                              button: true,
                              label: t.plus.preview_hint,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _expression =
                                      (_expression + 1) % _expressions.length,
                                ),
                                child: SizedBox(
                                  height: 260,
                                  child: HazeFace(
                                    framed: false,
                                    look: _look,
                                    state: widget.faceState.copyWith(
                                      isSpeaking: false,
                                      isLoadingAI: false,
                                      mimicStatus: MimicStatus.idle,
                                      isBlinking: false,
                                      config: widget.faceState.config.copyWith(
                                        expression: _expressions[_expression],
                                        isDarkTheme: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                              child: Text(
                                t.plus.preview_hint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _heading(t.plus.styles_title),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth < 440 ? 2 : 4;
                          final width =
                              (constraints.maxWidth - (columns - 1) * 10) /
                              columns;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final style in HazeFaceStyle.values)
                                SizedBox(
                                  width: width,
                                  child: _styleTile(style),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _heading(t.plus.accessories_title),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final accessory in HazeAccessory.values)
                            ChoiceChip(
                              avatar: Icon(_icon(accessory), size: 18),
                              label: Text(t.plus.accessories[accessory.index]),
                              selected: _accessory == accessory,
                              onSelected: (_) =>
                                  setState(() => _accessory = accessory),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (plus.message != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _message(plus.message!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (plus.ownsPlus || !_look.needsPlus)
                        FilledButton.icon(
                          onPressed: plus.busy ? null : () => _apply(_look),
                          icon: const Icon(Icons.check),
                          label: Text(t.plus.apply),
                        )
                      else
                        FilledButton.icon(
                          onPressed: plus.canPurchase ? _buy : null,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(
                            plus.busy
                                ? t.plus.checking
                                : plus.offer == null
                                ? t.plus.preview
                                : t.plus.buy(price: plus.offer!.localizedPrice),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (!plus.ownsPlus)
                        Text(
                          t.plus.forever,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: plus.canRestore ? plus.restore : null,
                            child: Text(t.plus.restore),
                          ),
                          if (plus.offer == null && !plus.ownsPlus)
                            TextButton(
                              onPressed: plus.busy ? null : plus.refresh,
                              child: Text(t.plus.retry),
                            ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.plus.free_promise,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.plus.free_detail,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: plus.busy
                              ? null
                              : () => _apply(const HazeLook()),
                          child: Text(t.plus.keep_classic),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.plus.restore_detail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _heading(String label) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );

  Widget _styleTile(HazeFaceStyle style) {
    final selected = _style == style;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label:
          '${t.plus.styles[style.index]}, ${style == HazeFaceStyle.classic ? t.plus.free : t.plus.pack}',
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _style = style),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 68,
                    child: HazeFace(
                      framed: false,
                      look: HazeLook(style: style),
                      state: RobotFaceState(
                        config: widget.faceState.config.copyWith(
                          expression: RobotExpression.happy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.plus.styles[style.index],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    style == HazeFaceStyle.classic
                        ? t.plus.free
                        : plus.ownsPlus
                        ? t.plus.included
                        : t.plus.pack,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _icon(HazeAccessory accessory) => switch (accessory) {
    HazeAccessory.none => Icons.block,
    HazeAccessory.glasses => Icons.visibility_outlined,
    HazeAccessory.crown => Icons.workspace_premium_outlined,
    HazeAccessory.headphones => Icons.headphones_outlined,
    HazeAccessory.comet => Icons.auto_awesome_outlined,
  };
}
