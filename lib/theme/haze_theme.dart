import 'package:flutter/material.dart';

/// Shared app chrome. Haze's customizable face colors remain independent.
abstract final class HazeTheme {
  static const gold = Color(0xFFEBCB8B);
  static const ink = Color(0xFF0A1018);
  static const paper = Color(0xFFF6F2E9);

  static ThemeData of(bool dark) {
    final surface = dark ? const Color(0xFF17212C) : const Color(0xFFFFFCF5);
    final foreground = dark ? const Color(0xFFF1EADD) : const Color(0xFF26313B);
    final primary = dark ? gold : const Color(0xFF765821);
    final colors = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: surface,
      primary: primary,
      onPrimary: dark ? const Color(0xFF30260F) : Colors.white,
      onSurface: foreground,
      outline: dark ? const Color(0xFF65707B) : const Color(0xFF8B8478),
      outlineVariant: dark ? const Color(0xFF303E49) : const Color(0xFFDDD5C7),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: dark ? ink : paper,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? ink : paper,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 21,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.outlineVariant),
        ),
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colors.outlineVariant),
        selectedColor: primary.withValues(alpha: dark ? .22 : .12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? ink.withValues(alpha: .55) : paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
      ),
    );
  }
}

class HazePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const HazePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
