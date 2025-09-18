import 'package:flutter/material.dart';

class AudioFile {
  final String id;
  final String filename;
  final String? artist;
  final int duration; // Milisaniye cinsinden
  final String path;

  AudioFile({
    required this.id,
    required this.filename,
    this.artist,
    required this.duration,
    required this.path,
  });
}