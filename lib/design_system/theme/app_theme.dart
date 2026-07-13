import 'package:portfolio/design_system/foundation/spacing/app_spacing.dart';
import 'package:portfolio/design_system/foundation/spacing/desktop_spacing.dart';
import 'package:portfolio/design_system/foundation/spacing/mobile_spacing.dart';
import 'package:portfolio/design_system/foundation/spacing/tablet_spacing.dart';

class AppTheme {
  final AppSpacing appSpacing;

  const AppTheme({required this.appSpacing});
}

const mobileTheme = AppTheme(appSpacing: MobileSpacing());

const desktopTheme = AppTheme(appSpacing: DesktopSpacing());

const tabletTheme = AppTheme(appSpacing: TabletSpacing());