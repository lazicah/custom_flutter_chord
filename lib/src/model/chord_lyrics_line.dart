import 'package:flutter/material.dart';

class ChordLyricsLine {
  List<Chord> chords;
  String lyrics;
  List<InlineSpan> lyricsContent;

  ChordLyricsLine()
      : chords = [],
        lyrics = '',
        lyricsContent = [];

  ChordLyricsLine.line(this.chords, this.lyrics, this.lyricsContent);

  /// Remove also the keyword
  bool isStartOfChorus() {
    const String startOfChorusAbbreviation = '{soc}';
    const String startOfChorus = '{start_of_chorus}';
    bool out = lyrics.contains(startOfChorus) ||
        lyrics.contains(startOfChorusAbbreviation);
    if (out) {
      lyrics = lyrics.replaceAll(startOfChorus, '');
      lyrics = lyrics.replaceAll(startOfChorusAbbreviation, '');
    }
    return out;
  }

  /// Remove also the keyword
  bool isEndOfChorus() {
    const String endOfChorusAbbreviation = '{eoc}';
    const String endOfChorus = '{end_of_chorus}';
    bool out = lyrics.contains(endOfChorus) ||
        lyrics.contains(endOfChorusAbbreviation);
    if (out) {
      lyrics = lyrics.replaceAll(endOfChorus, '');
      lyrics = lyrics.replaceAll(endOfChorusAbbreviation, '');
    }
    return out;
  }

  /// Remove also the keyword
  bool isComment() {
    const String comment = '{comment:';
    bool out = lyrics.contains(comment);
    if (out) {
      lyrics = lyrics.replaceAll(comment, '');
      lyrics = lyrics.replaceAll('}', '');
    }
    return out;
  }

  @override
  String toString() {
    return 'ChordLyricsLine($chords, lyrics: $lyrics)';
  }
}

class Chord {
  double leadingSpace;
  String chordText;

  Chord(this.leadingSpace, this.chordText);

  @override
  String toString() {
    return 'Chord(leadingSpace: $leadingSpace, chordText: $chordText)';
  }
}
