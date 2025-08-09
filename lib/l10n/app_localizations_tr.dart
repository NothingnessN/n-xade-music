// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get hello => 'Merhaba';

  @override
  String get playlist => 'Çalma Listesi';

  @override
  String get add_song => 'Şarkı Ekle';

  @override
  String get player => 'Oynatıcı';

  @override
  String get audio_list => 'Ses Listesi';

  @override
  String get by_nxade_studios => 'N-Xade Studios tarafından';

  @override
  String get all_audios => 'Tüm Sesler';

  @override
  String get add_playlist => 'Çalma Listesi Ekle';

  @override
  String get new_playlist => 'Yeni Çalma Listesi';

  @override
  String get create_playlist => 'Çalma Listesi Oluştur';

  @override
  String get playlist_title => 'Çalma Listesi';

  @override
  String get options => 'Seçenekler';

  @override
  String get add_to_playlist => 'Çalma Listesine Ekle';

  @override
  String get remove_from_playlist => 'Çalma Listesinden Kaldır';

  @override
  String get delete_playlist => 'Çalma Listesini Sil';

  @override
  String get no_playlists => 'Henüz çalma listesi yok';

  @override
  String get click_to_create =>
      'Yeni bir çalma listesi oluşturmak için + düğmesine tıklayın';

  @override
  String get songs => 'şarkı';

  @override
  String get choose_theme => 'Tema Seç';

  @override
  String get delete_playlist_title => 'Çalma Listesini Sil';

  @override
  String delete_playlist_message(Object playlistName) {
    return '$playlistName çalma listesini silmek istediğinizden emin misiniz?';
  }

  @override
  String get cancel => 'İptal';

  @override
  String removed_from_playlist(Object songName) {
    return '$songName çalma listesinden kaldırıldı';
  }

  @override
  String added_to_playlist(Object songName, Object playlistName) {
    return '$songName şarkısı $playlistName çalma listesine eklendi';
  }

  @override
  String playlist_deleted(Object playlistName) {
    return '$playlistName çalma listesi silindi';
  }

  @override
  String get language_turkish => 'Türkçe';

  @override
  String get language_english => 'İngilizce';

  @override
  String get themes => 'Temalar';

  @override
  String get premium_themes => 'Premium Temalar';

  @override
  String get free_themes => 'Ücretsiz Temalar';

  @override
  String get purchase_theme => 'Tema Satın Al';

  @override
  String get theme_purchased => 'Tema satın alındı!';

  @override
  String get purchase_failed => 'Satın alma başarısız!';

  @override
  String get premium_theme_unlocked => 'Premium tema açıldı!';

  @override
  String get playing_from => 'Çalma listesinden:';
}
