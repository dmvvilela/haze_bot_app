import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'cubits/robot_face_cubit.dart';
import 'models/robot_config.dart';
import 'widgets/robot_face_widget.dart';
import 'i18n/strings.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale(); // Initialize with device locale
  runApp(TranslationProvider(child: const HazeBotApp()));
}

class HazeBotApp extends StatelessWidget {
  const HazeBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: t.app.title,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocale.values.map((locale) => locale.flutterLocale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocProvider(create: (context) => RobotFaceCubit()..startBlinking(), child: const RobotFaceScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RobotFaceScreen extends StatelessWidget {
  const RobotFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state.config.isDarkTheme ? Colors.black : Colors.white,
          body: Stack(
            children: [
              // Robot face centered on full screen
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (!state.showControls) {
                      context.read<RobotFaceCubit>().toggleControls();
                    } else {
                      context.read<RobotFaceCubit>().onTap();
                    }
                  },
                  child: const RobotFaceWidget(),
                ),
              ),
              // Controls with opacity animation
              AnimatedOpacity(
                opacity: state.showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !state.showControls,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.palette, color: state.config.isDarkTheme ? Colors.white : Colors.black),
                        onPressed: () => _showColorPicker(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.face, color: state.config.isDarkTheme ? Colors.white : Colors.black),
                        onPressed: () => _showFaceTypePicker(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: state.config.isDarkTheme ? Colors.white : Colors.black),
                        onPressed: () => _showSettings(context),
                      ),
                      IconButton(
                        icon: Icon(
                          state.config.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                          color: state.config.isDarkTheme ? Colors.white : Colors.black,
                        ),
                        onPressed: () => context.read<RobotFaceCubit>().toggleTheme(),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility_off, color: state.config.isDarkTheme ? Colors.white : Colors.black),
                        onPressed: () => context.read<RobotFaceCubit>().toggleControls(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: Text(t.ui.choose_colors),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.ui.eye_color),
                  Wrap(
                    children: [Colors.cyan, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.red, Colors.yellow, Colors.pink]
                        .map(
                          (color) => GestureDetector(
                            onTap: () => context.read<RobotFaceCubit>().updateEyeColor(color),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: state.config.eyeColor == color ? Border.all(color: Colors.white, width: 3) : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(t.ui.mouth_color),
                  Wrap(
                    children: [Colors.pink, Colors.red, Colors.orange, Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.cyan]
                        .map(
                          (color) => GestureDetector(
                            onTap: () => context.read<RobotFaceCubit>().updateMouthColor(color),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: state.config.mouthColor == color ? Border.all(color: Colors.white, width: 3) : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }

  void _showFaceTypePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: Text(t.ui.choose_face_type),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: FaceType.values.map((faceType) {
                  return RadioListTile<FaceType>(
                    title: Text(faceType.displayName),
                    subtitle: Text(faceType.description),
                    value: faceType,
                    groupValue: state.config.faceType,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<RobotFaceCubit>().updateFaceType(value);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RobotFaceCubit>(),
        child: AlertDialog(
          title: Text(t.ui.settings),
          content: BlocBuilder<RobotFaceCubit, RobotFaceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(t.ui.language),
                    subtitle: Text(state.config.language == 'en-US' ? 'English' : 'Português'),
                    trailing: DropdownButton<String>(
                      value: state.config.language,
                      items: const [
                        DropdownMenuItem(value: 'en-US', child: Text('English')),
                        DropdownMenuItem(value: 'pt-BR', child: Text('Português')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<RobotFaceCubit>().updateLanguage(value);
                          // Update app locale
                          if (value == 'pt-BR') {
                            LocaleSettings.setLocale(AppLocale.pt);
                          } else {
                            LocaleSettings.setLocale(AppLocale.en);
                          }
                        }
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: Text(t.ui.speech_enabled),
                    subtitle: Text(t.ui.speech_description),
                    value: state.config.speechEnabled,
                    onChanged: (_) => context.read<RobotFaceCubit>().toggleSpeech(),
                  ),
                  if (state.config.speechEnabled) ...[
                    const SizedBox(height: 16),
                    Text('${t.ui.speech_rate}: ${state.config.speechRate.toStringAsFixed(1)}'),
                    Slider(
                      value: state.config.speechRate,
                      min: 0.1,
                      max: 2.0,
                      divisions: 19,
                      onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechRate(value),
                    ),
                    const SizedBox(height: 8),
                    Text('${t.ui.speech_pitch}: ${state.config.speechPitch.toStringAsFixed(1)}'),
                    Slider(
                      value: state.config.speechPitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (value) => context.read<RobotFaceCubit>().updateSpeechPitch(value),
                    ),
                  ],
                ],
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
        ),
      ),
    );
  }
}
