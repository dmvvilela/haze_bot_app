import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'cubits/robot_face_cubit.dart';
import 'widgets/robot_face_widget.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/face_type_picker_dialog.dart';
import 'widgets/settings_dialog.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
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
        return Theme(
          data: state.config.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            backgroundColor: state.config.isDarkTheme ? Colors.black : Colors.grey[100],
            appBar: AppBar(
              backgroundColor: state.config.isDarkTheme ? Colors.black : Colors.grey[100],
              elevation: 0,
              toolbarHeight: kToolbarHeight,
              actions: [
                AnimatedOpacity(
                  opacity: state.showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !state.showControls,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.palette), onPressed: () => _showColorPicker(context)),
                        IconButton(icon: Icon(Icons.face), onPressed: () => _showFaceTypePicker(context)),
                        IconButton(icon: Icon(Icons.settings), onPressed: () => _showSettings(context)),
                        IconButton(
                          icon: Icon(state.config.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () => context.read<RobotFaceCubit>().toggleTheme(),
                        ),
                        IconButton(icon: Icon(Icons.visibility_off), onPressed: () => context.read<RobotFaceCubit>().toggleControls()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Robot face always centered
                Padding(
                  padding: EdgeInsets.only(bottom: AppBar().preferredSize.height),
                  child: Center(child: const RobotFaceWidget()),
                ),
                // Full screen gesture detector only when controls are hidden
                if (!state.showControls)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        context.read<RobotFaceCubit>().toggleControls();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(value: context.read<RobotFaceCubit>(), child: const ColorPickerDialog()),
    );
  }

  void _showFaceTypePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(value: context.read<RobotFaceCubit>(), child: const FaceTypePickerDialog()),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(value: context.read<RobotFaceCubit>(), child: const SettingsDialog()),
    );
  }
}
