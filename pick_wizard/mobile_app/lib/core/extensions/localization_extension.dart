import 'package:flutter/material.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';

/// BuildContext Extension for easy localization access
/// 
/// 2026-01-16 EST - 다국어 지원: context.l10n 단축키
/// 
/// Usage:
/// ```dart
/// Text(context.l10n.appTitle)  // locale별 PickWizard 표기
/// Text(context.l10n.drawNumber(1205))  // "제 1205회" or "Draw #1205"
/// ```
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
