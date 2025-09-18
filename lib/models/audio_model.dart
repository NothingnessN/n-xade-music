class AudioFile {
  final String id;
  final String filename;
  final String uri;
  final double duration;
  final String? artist;
  final String? album;
  final int? size;

  AudioFile({
    required this.id,
    required this.filename,
    required this.uri,
    required this.duration,
    this.artist,
    this.album,
    this.size,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      filename: json['filename'],
      uri: json['uri'],
      duration: json['duration'].toDouble(),
      artist: json['artist'],
      album: json['album'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'uri': uri,
      'duration': duration,
      'artist': artist,
      'album': album,
    };
  }

  String get displayName {
    if (RegExp(r'^\d+$').hasMatch(filename)) {
      return 'Unknown Song';
    }
    return filename;
  }

  String get displayNameWOExt {
    String name = displayName;
    final lastDot = name.lastIndexOf('.');
    if (lastDot != -1) {
      return name.substring(0, lastDot);
    }
    return name;
  }
}