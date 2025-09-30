import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @add_song.
  ///
  /// In en, this message translates to:
  /// **'Add Song'**
  String get add_song;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @audio_list.
  ///
  /// In en, this message translates to:
  /// **'Audio List'**
  String get audio_list;

  /// No description provided for @by_nxade_studios.
  ///
  /// In en, this message translates to:
  /// **'By N-Xade Studios'**
  String get by_nxade_studios;

  /// No description provided for @all_audios.
  ///
  /// In en, this message translates to:
  /// **'All Audios'**
  String get all_audios;

  /// No description provided for @add_playlist.
  ///
  /// In en, this message translates to:
  /// **'Add Playlist'**
  String get add_playlist;

  /// No description provided for @new_playlist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get new_playlist;

  /// No description provided for @create_playlist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get create_playlist;

  /// No description provided for @playlist_title.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist_title;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @add_to_playlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get add_to_playlist;

  /// No description provided for @remove_from_playlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get remove_from_playlist;

  /// No description provided for @delete_playlist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get delete_playlist;

  /// No description provided for @no_playlists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get no_playlists;

  /// No description provided for @click_to_create.
  ///
  /// In en, this message translates to:
  /// **'Click the + button to create a new playlist'**
  String get click_to_create;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'songs'**
  String get songs;

  /// No description provided for @choose_theme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get choose_theme;

  /// No description provided for @delete_playlist_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get delete_playlist_title;

  /// No description provided for @delete_playlist_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the playlist {playlistName}?'**
  String delete_playlist_message(Object playlistName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @removed_from_playlist.
  ///
  /// In en, this message translates to:
  /// **'{songName} removed from playlist'**
  String removed_from_playlist(Object songName);

  /// No description provided for @added_to_playlist.
  ///
  /// In en, this message translates to:
  /// **'{songName} added to {playlistName}'**
  String added_to_playlist(Object songName, Object playlistName);

  /// No description provided for @playlist_deleted.
  ///
  /// In en, this message translates to:
  /// **'{playlistName} playlist deleted'**
  String playlist_deleted(Object playlistName);

  /// No description provided for @language_turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get language_turkish;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @free_themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get free_themes;

  /// No description provided for @playing_from.
  ///
  /// In en, this message translates to:
  /// **'Playing from:'**
  String get playing_from;

  /// No description provided for @language_selection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get language_selection;

  /// Message shown when a playlist has no songs
  ///
  /// In en, this message translates to:
  /// **'No songs in this playlist'**
  String get no_songs_in_playlist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
