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
  // Exact Hex Colors from Stitch light_mode files
  static const Color background = Color(0xFFFBFBFF); // Lighter background
  static const Color onSurface = Color(0xFF231A06);
  static const Color primary = Color(0xFF00327D);
  static const Color primaryContainer = Color(0xFF0047AB);
  static const Color secondary = Color(0xFF4E5E85);
  static const Color surfaceDim = Color(0xFFEAD8B8);
  static const Color surfaceContainerHighest = Color(0xFFF3E0C0);
  static const Color surfaceContainerHigh = Color(0xFFF9E6C5);
  static const Color surfaceContainer = Color(0xFFFFECCB);
  static const Color surfaceContainerLow = Color(0xFFFFF2DE);
  static const Color surfaceContainerLowest = Color(0xFFFBFBFF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color outlineVariant = Color(0xFFC3C6D5);

  // Static Aliases for missing colors used in the UI
  static const Color voidBlack = Color(0xFFE5D3B3); // Replaced Black with user requested color
  static const Color primaryBlue = primary;
  static const Color crimsonCarrot = error;
  static const Color surfaceLow = surfaceContainerLow;
  static const Color surfaceHighest = surfaceContainerHighest;
  static const Color surfaceLowest = surfaceContainerLowest;

  static ThemeData get lightTheme {
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
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: -3.0,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: -1.0,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: onSurface,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: 2.0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primaryContainer,
        unselectedItemColor: Color(0x66231A06),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get normalTheme => lightTheme;
  static ThemeData get panicTheme => lightTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: error,
      primary: error,
    ),
  );
}
