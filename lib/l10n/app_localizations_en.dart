// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get playlist => 'Playlist';

  @override
  String get add_song => 'Add Song';

  @override
  String get player => 'Player';

  @override
  String get audio_list => 'Audio List';

  @override
  String get by_nothingnessn => 'By NothingnessN';

  @override
  String get all_audios => 'All Audios';

  @override
  String get add_playlist => 'Add Playlist';

  @override
  String get new_playlist => 'New Playlist';

  @override
  String get create_playlist => 'Create Playlist';

  @override
  String get playlist_title => 'Playlist';

  @override
  String get options => 'Options';

  @override
  String get add_to_playlist => 'Add to Playlist';

  @override
  String get remove_from_playlist => 'Remove from Playlist';

  @override
  String get delete_playlist => 'Delete Playlist';

  @override
  String get no_playlists => 'No playlists yet';

  @override
  String get click_to_create => 'Click the + button to create a new playlist';

  @override
  String get songs => 'songs';

  @override
  String get choose_theme => 'Choose Theme';

  @override
  String get delete_playlist_title => 'Delete Playlist';

  @override
  String delete_playlist_message(Object playlistName) {
    return 'Are you sure you want to delete the playlist $playlistName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String removed_from_playlist(Object songName) {
    return '$songName removed from playlist';
  }

  @override
  String added_to_playlist(Object songName, Object playlistName) {
    return '$songName added to $playlistName';
  }

  @override
  String playlist_deleted(Object playlistName) {
    return '$playlistName playlist deleted';
  }

  @override
  String get language_turkish => 'Turkish';

  @override
  String get language_english => 'English';
}
