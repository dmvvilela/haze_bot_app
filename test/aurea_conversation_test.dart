import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/services/haze_brain.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';
import 'package:haze_bot_app/widgets/robot_face_widget.dart';

void main() {
  testWidgets('conversation connects the Aurea state to the only face', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'haze_ai_consent': 'declined'});
    var generations = 0;
    final robot = RobotFaceCubit(
      brain: HazeBrain(
        generate: (_) async {
          generations++;
          return generations.isOdd
              ? '{"loss":0.8}'
              : '{"say":"I’m here with you."}';
        },
      ),
    );
    robot.sounds.enabled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: robot, child: const RobotFaceWidget()),
      ),
    );
    await tester.runAsync(robot.grantAiConsent);
    await tester.runAsync(robot.getAIResponse);
    await tester.pump();
    expect(generations, 2);
    expect(robot.state.aiMessage, 'I’m here with you.');
    expect(robot.state.isLoadingAI, isFalse);
    expect(robot.companion!.expression.sorrow, greaterThan(.4));
    expect(
      tester.widget<HazeFace>(find.byType(HazeFace)).companion,
      same(robot.companion),
    );
    expect(robot.state.chemistryReaction, isEmpty);
    // Explicit game expressions continue to have ownership of the face.
    robot.mood.pinned = true;
    expect(robot.mood.moodDriven, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(robot.close);
  });
}
