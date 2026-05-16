import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding completion state.
///
/// Uses SharedPreferences to persist whether the user has completed
/// the onboarding flow. This ensures onboarding is only shown once.
class OnboardingPrefs {
  static const String _key = 'has_seen_onboarding';

  /// Returns `true` if this is the user's first launch (hasn't completed onboarding).
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  /// Marks onboarding as completed. Subsequent calls to [isFirstLaunch]
  /// will return `false`.
  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Resets the onboarding state (useful for debugging / testing).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
