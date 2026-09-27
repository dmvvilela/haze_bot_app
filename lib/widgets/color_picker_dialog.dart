import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});
  static const _colors = [
    Colors.cyan,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.yellow,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final cubit = context.read<RobotFaceCubit>();
        return AlertDialog(
          title: Text(t.ui.choose_colors),
          scrollable: true,
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.home.colorHint,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _palette(
                  context,
                  t.ui.eye_color,
                  state.config.eyeColor,
                  cubit.updateEyeColor,
                ),
                const SizedBox(height: 24),
                _palette(
                  context,
                  t.ui.mouth_color,
                  state.config.mouthColor,
                  cubit.updateMouthColor,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.home.done),
            ),
          ],
        );
      },
    );
  }

  Widget _palette(
    BuildContext context,
    String label,
    Color selected,
    ValueChanged<Color> onSelect,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < _colors.length; i++)
            Semantics(
              label: '$label: ${t.home.colorNames[i]}',
              button: true,
              selected: selected == _colors[i],
              child: Tooltip(
                message: t.home.colorNames[i],
                child: Material(
                  color: _colors[i],
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelect(_colors[i]),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: selected == _colors[i]
                          ? Icon(
                              Icons.check_rounded,
                              color: _colors[i].computeLuminance() > .4
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
