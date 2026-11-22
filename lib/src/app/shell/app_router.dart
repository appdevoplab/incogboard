// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Maps every KoshaRoutes id to a screen. Unknown names go home. Each page is
// keyed `route:<name>` so tests and deep links can find it.
import 'package:material_ui/material_ui.dart';

import '../about/about_screen.dart';
import '../privacy/privacy_center_screen.dart';
import '../routes.dart';
import '../themes/theme_gallery_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../packs/packs_screen.dart';
import '../screens/feel_screen.dart';
import '../screens/home_screen.dart';
import '../screens/languages_screen.dart';
import '../screens/panels_screen.dart';
import '../screens/typing_screen.dart';
import '../screens/voice_screen.dart';
import '../translate/translate_screen.dart';

/// The Voice screen's route (kept for older callers; same as [KoshaRoutes.voice]).
const String voiceRoute = KoshaRoutes.voice;

/// Screen for [route]. Unknown names show home.
Widget screenForRoute(String route) => switch (route) {
  KoshaRoutes.onboarding => const OnboardingScreen(),
  KoshaRoutes.languages => const LanguagesScreen(),
  KoshaRoutes.typing => const TypingScreen(),
  KoshaRoutes.feel => const FeelScreen(),
  KoshaRoutes.panels || KoshaRoutes.clipboard => const PanelsScreen(),
  KoshaRoutes.themes => const ThemeGalleryScreen(),
  KoshaRoutes.privacy => const PrivacyCenterScreen(),
  KoshaRoutes.about => const AboutScreen(),
  KoshaRoutes.voice => const VoiceScreen(),
  KoshaRoutes.translate => const TranslateScreen(),
  KoshaRoutes.packs => const PacksScreen(),
  _ => const HomeScreen(),
};

/// True for names this app can show.
bool isKnownRoute(String route) => KoshaRoutes.all.contains(route);

/// The page route for named navigation (`onGenerateRoute`).
Route<Object?> routeFor(RouteSettings settings) {
  final requested = settings.name ?? KoshaRoutes.home;
  final name = isKnownRoute(requested) ? requested : KoshaRoutes.home;
  return _SpringPageRoute<Object?>(
    name: name,
    child: KeyedSubtree(key: ValueKey<String>('route:$name'), child: screenForRoute(name)),
  );
}

/// A page with a short spring-like slide and fade. Respects "Remove animations".
class _SpringPageRoute<T> extends PageRouteBuilder<T> {
  _SpringPageRoute({required String name, required Widget child})
    : super(
        settings: RouteSettings(name: name),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: _transition,
      );

  static Widget _transition(BuildContext context, Animation<double> animation, Animation<double> _, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final motion = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(motion),
        child: child,
      ),
    );
  }
}
