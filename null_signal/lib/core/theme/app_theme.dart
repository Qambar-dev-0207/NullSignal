import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class NullSignalColors extends ThemeExtension<NullSignalColors> {
  const NullSignalColors({
    required this.background,
    required this.onSurface,
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.surfaceDim,
    required this.surfaceContainerHighest,
    required this.surfaceContainerHigh,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.error,
    required this.errorContainer,
    required this.outlineVariant,
  });

  final Color background;
  final Color onSurface;
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color surfaceDim;
  final Color surfaceContainerHighest;
  final Color surfaceContainerHigh;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color error;
  final Color errorContainer;
  final Color outlineVariant;

  // Aliases for missing colors used in the UI
  Color get voidBlack => const Color(0xFFE5D3B3);
  Color get primaryBlue => primary;
  Color get crimsonCarrot => error;
  Color get surfaceLow => surfaceContainerLow;
  Color get surfaceHighest => surfaceContainerHighest;
  Color get surfaceLowest => surfaceContainerLowest;
  Color get surface => background;
  Color get warning => Colors.orange;

  @override
  NullSignalColors copyWith({
    Color? background,
    Color? onSurface,
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? surfaceDim,
    Color? surfaceContainerHighest,
    Color? surfaceContainerHigh,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? surfaceContainerLowest,
    Color? error,
    Color? errorContainer,
    Color? outlineVariant,
  }) {
    return NullSignalColors(
      background: background ?? this.background,
      onSurface: onSurface ?? this.onSurface,
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      outlineVariant: outlineVariant ?? this.outlineVariant,
    );
  }

  @override
  NullSignalColors lerp(ThemeExtension<NullSignalColors>? other, double t) {
    if (other is! NullSignalColors) return this;
    return NullSignalColors(
      background: Color.lerp(background, other.background, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
    );
  }
}

class AppTheme {
  // NullSignal Identity: Beige and Red Tactical Aesthetic
  static const Color background = Color(0xFFF5E6D3); // Soft Beige
  static const Color onSurface = Color(0xFF1A1A1A); // Dark Grey/Black
  static const Color primary = Color(0xFFB71C1C); // Tactical Red
  static const Color primaryContainer = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFD7CCC8);
  static const Color surfaceDim = Color(0xFFEFEBE9);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  static const Color surfaceContainerHigh = Color(0xFFECEFF1);
  static const Color surfaceContainer = Color(0xFFF5F5F5);
  static const Color surfaceContainerLow = Color(0xFFFAFAFA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color outlineVariant = Color(0xFFBDBDBD);

  static ThemeData get normalTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      extensions: const <ThemeExtension<dynamic>>[
        NullSignalColors(
          background: background,
          onSurface: onSurface,
          primary: primary,
          primaryContainer: primaryContainer,
          secondary: secondary,
          surfaceDim: surfaceDim,
          surfaceContainerHighest: surfaceContainerHighest,
          surfaceContainerHigh: surfaceContainerHigh,
          surfaceContainer: surfaceContainer,
          surfaceContainerLow: surfaceContainerLow,
          surfaceContainerLowest: surfaceContainerLowest,
          error: error,
          errorContainer: errorContainer,
          outlineVariant: outlineVariant,
        ),
      ],
      textTheme: GoogleFonts.shareTechMonoTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: primary,
            letterSpacing: -1.0,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: primary,
            letterSpacing: 1.0,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: onSurface,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: onSurface.withValues(alpha: 0.7),
          ),
          labelSmall: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: primary,
            letterSpacing: 2.0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
          fontFamily: 'ShareTechMono',
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF424242),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get lightTheme => normalTheme;
  static ThemeData get panicTheme => normalTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: error,
      primary: error,
      brightness: Brightness.dark,
    ),
  );
}
