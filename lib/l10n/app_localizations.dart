import 'package:flutter/material.dart';
import 'app_es.dart';
import 'app_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es', ''),
    Locale('en', ''),
  ];

  bool get _isSpanish => locale.languageCode == 'es';

  // General
  String get appName => _isSpanish ? AppLocalizationsEs.appName : AppLocalizationsEn.appName;
  String get welcome => _isSpanish ? AppLocalizationsEs.welcome : AppLocalizationsEn.welcome;
  String get user => _isSpanish ? AppLocalizationsEs.user : AppLocalizationsEn.user;
  String get save => _isSpanish ? AppLocalizationsEs.save : AppLocalizationsEn.save;
  String get cancel => _isSpanish ? AppLocalizationsEs.cancel : AppLocalizationsEn.cancel;
  String get accept => _isSpanish ? AppLocalizationsEs.accept : AppLocalizationsEn.accept;
  String get delete => _isSpanish ? AppLocalizationsEs.delete : AppLocalizationsEn.delete;
  String get edit => _isSpanish ? AppLocalizationsEs.edit : AppLocalizationsEn.edit;
  String get add => _isSpanish ? AppLocalizationsEs.add : AppLocalizationsEn.add;

  // Bottom Navigation
  String get navHome => _isSpanish ? AppLocalizationsEs.navHome : AppLocalizationsEn.navHome;
  String get navMap => _isSpanish ? AppLocalizationsEs.navMap : AppLocalizationsEn.navMap;
  String get navData => _isSpanish ? AppLocalizationsEs.navData : AppLocalizationsEn.navData;
  String get navSettings => _isSpanish ? AppLocalizationsEs.navSettings : AppLocalizationsEn.navSettings;

  // Home Page
  String get newsTitle => _isSpanish ? AppLocalizationsEs.newsTitle : AppLocalizationsEn.newsTitle;
  String get summary => _isSpanish ? AppLocalizationsEs.summary : AppLocalizationsEn.summary;
  String get zones => _isSpanish ? AppLocalizationsEs.zones : AppLocalizationsEn.zones;
  String get news1Title => _isSpanish ? AppLocalizationsEs.news1Title : AppLocalizationsEn.news1Title;
  String get news1Desc => _isSpanish ? AppLocalizationsEs.news1Desc : AppLocalizationsEn.news1Desc;
  String get news2Title => _isSpanish ? AppLocalizationsEs.news2Title : AppLocalizationsEn.news2Title;
  String get news2Desc => _isSpanish ? AppLocalizationsEs.news2Desc : AppLocalizationsEn.news2Desc;
  String get news3Title => _isSpanish ? AppLocalizationsEs.news3Title : AppLocalizationsEn.news3Title;
  String get news3Desc => _isSpanish ? AppLocalizationsEs.news3Desc : AppLocalizationsEn.news3Desc;

  // Map Page
  String get lowRisk => _isSpanish ? AppLocalizationsEs.lowRisk : AppLocalizationsEn.lowRisk;
  String get mediumRisk => _isSpanish ? AppLocalizationsEs.mediumRisk : AppLocalizationsEn.mediumRisk;
  String get highRisk => _isSpanish ? AppLocalizationsEs.highRisk : AppLocalizationsEn.highRisk;
  String get addExperience => _isSpanish ? AppLocalizationsEs.addExperience : AppLocalizationsEn.addExperience;
  String get editMarker => _isSpanish ? AppLocalizationsEs.editMarker : AppLocalizationsEn.editMarker;
  String get experienceType => _isSpanish ? AppLocalizationsEs.experienceType : AppLocalizationsEn.experienceType;
  String get good => _isSpanish ? AppLocalizationsEs.good : AppLocalizationsEn.good;
  String get regular => _isSpanish ? AppLocalizationsEs.regular : AppLocalizationsEn.regular;
  String get bad => _isSpanish ? AppLocalizationsEs.bad : AppLocalizationsEn.bad;
  String get incidentType => _isSpanish ? AppLocalizationsEs.incidentType : AppLocalizationsEn.incidentType;
  String get noIncident => _isSpanish ? AppLocalizationsEs.noIncident : AppLocalizationsEn.noIncident;
  String get robbery => _isSpanish ? AppLocalizationsEs.robbery : AppLocalizationsEn.robbery;
  String get accident => _isSpanish ? AppLocalizationsEs.accident : AppLocalizationsEn.accident;
  String get darkStreet => _isSpanish ? AppLocalizationsEs.darkStreet : AppLocalizationsEn.darkStreet;
  String get other => _isSpanish ? AppLocalizationsEs.other : AppLocalizationsEn.other;
  String get writeExperience => _isSpanish ? AppLocalizationsEs.writeExperience : AppLocalizationsEn.writeExperience;
  String get description => _isSpanish ? AppLocalizationsEs.description : AppLocalizationsEn.description;
  String get addDetails => _isSpanish ? AppLocalizationsEs.addDetails : AppLocalizationsEn.addDetails;
  String get addPhoto => _isSpanish ? AppLocalizationsEs.addPhoto : AppLocalizationsEn.addPhoto;

  // Data Analysis
  String get analysisTitle => _isSpanish ? AppLocalizationsEs.analysisTitle : AppLocalizationsEn.analysisTitle;
  String get securitySummary => _isSpanish ? AppLocalizationsEs.securitySummary : AppLocalizationsEn.securitySummary;
  String get safeZones => _isSpanish ? AppLocalizationsEs.safeZones : AppLocalizationsEn.safeZones;
  String get mediumRiskZones => _isSpanish ? AppLocalizationsEs.mediumRiskZones : AppLocalizationsEn.mediumRiskZones;
  String get criticalZones => _isSpanish ? AppLocalizationsEs.criticalZones : AppLocalizationsEn.criticalZones;
  String get aiInsights => _isSpanish ? AppLocalizationsEs.aiInsights : AppLocalizationsEn.aiInsights;
  String get insight1 => _isSpanish ? AppLocalizationsEs.insight1 : AppLocalizationsEn.insight1;
  String get insight2 => _isSpanish ? AppLocalizationsEs.insight2 : AppLocalizationsEn.insight2;

  // Settings
  String get settings => _isSpanish ? AppLocalizationsEs.settings : AppLocalizationsEn.settings;
  String get alertRadius => _isSpanish ? AppLocalizationsEs.alertRadius : AppLocalizationsEn.alertRadius;
  String get meters => _isSpanish ? AppLocalizationsEs.meters : AppLocalizationsEn.meters;
  String get notifications => _isSpanish ? AppLocalizationsEs.notifications : AppLocalizationsEn.notifications;
  String get enableNotifications => _isSpanish ? AppLocalizationsEs.enableNotifications : AppLocalizationsEn.enableNotifications;
  String get darkMode => _isSpanish ? AppLocalizationsEs.darkMode : AppLocalizationsEn.darkMode;
  String get enableDarkMode => _isSpanish ? AppLocalizationsEs.enableDarkMode : AppLocalizationsEn.enableDarkMode;
  String get language => _isSpanish ? AppLocalizationsEs.language : AppLocalizationsEn.language;
  String get selectLanguage => _isSpanish ? AppLocalizationsEs.selectLanguage : AppLocalizationsEn.selectLanguage;
  String get spanish => _isSpanish ? AppLocalizationsEs.spanish : AppLocalizationsEn.spanish;
  String get english => _isSpanish ? AppLocalizationsEs.english : AppLocalizationsEn.english;
  String get saveChanges => _isSpanish ? AppLocalizationsEs.saveChanges : AppLocalizationsEn.saveChanges;
  String get logout => _isSpanish ? AppLocalizationsEs.logout : AppLocalizationsEn.logout;
  String get logoutConfirm => _isSpanish ? AppLocalizationsEs.logoutConfirm : AppLocalizationsEn.logoutConfirm;
  String get logoutSuccess => _isSpanish ? AppLocalizationsEs.logoutSuccess : AppLocalizationsEn.logoutSuccess;
  String get settingsSaved => _isSpanish ? AppLocalizationsEs.settingsSaved : AppLocalizationsEn.settingsSaved;
  String get notificationsEnabled => _isSpanish ? AppLocalizationsEs.notificationsEnabled : AppLocalizationsEn.notificationsEnabled;
  String get notificationsDisabled => _isSpanish ? AppLocalizationsEs.notificationsDisabled : AppLocalizationsEn.notificationsDisabled;
  String get userEmail => _isSpanish ? AppLocalizationsEs.userEmail : AppLocalizationsEn.userEmail;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
