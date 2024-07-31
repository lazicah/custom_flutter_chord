import 'package:chord_transposer/chord_transposer.dart';
import 'package:custom_flutter_chord/custom_flutter_chord.dart';
import 'package:flutter/material.dart';

class LyricsController extends ChangeNotifier {
  final ScrollController controller = ScrollController();
  final transposer = ChordTransposer();
  late ChordProcessor chordProcessor;

  ChordLyricsDocument? _chordLyricsDocument;
  ChordLyricsDocument? get chordLyricsDocument => _chordLyricsDocument;

  late String _lyrics;
  TextStyle? textStyle;
  TextStyle? chordStyle;
  bool minorScale = false;

  /// To help stop overflow, this should be the sum of left & right padding
  int widgetPadding = 0;

  /// Auto Scroll Speed,
  /// default value is 0, which means no auto scroll is applied
  int scrollSpeed = 5;

  /// Scale factor of chords and lyrics
  double scaleFactor = 1.0;

  /// If not defined it will be the bold version of [textStyle]
  TextStyle? chorusStyle;

  /// If not defined it will be the italic version of [textStyle]
  TextStyle? capoStyle;

  /// If not defined it will be the italic version of [textStyle]
  TextStyle? commentStyle;

  double viewWidth = 0;

  void init({
    required String lyrics,
  }) {
    _lyrics = lyrics;
    chordProcessor = ChordProcessor(viewWidth);
    _processLyrics(lyrics);
  }

  void selectKey(String key) {
    _lyrics = transposer.lyricsToKey(lyrics: _lyrics, toKey: key);
    _processLyrics(_lyrics);
  }

  void transposeUp(int value) {
    _lyrics = transposer.lyricsUp(lyrics: _lyrics, semitones: value);
    _processLyrics(_lyrics);
  }

  void transposeDown(int value) {
    _lyrics = transposer.lyricsDown(lyrics: _lyrics, semitones: value);
    _processLyrics(_lyrics);
  }

  void startAutoScroll(int scrollSpeed) {
    if (scrollSpeed <= 0) {
      // stop scrolling if the speed is 0 or less
      controller.jumpTo(controller.offset);
      return;
    }

    if (controller.offset >= controller.position.maxScrollExtent) return;

    final seconds =
        (controller.position.maxScrollExtent / (scrollSpeed)).floor();

    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: Duration(
        seconds: seconds,
      ),
      curve: Curves.linear,
    );
  }

  void stopAutoScroll() {
    controller.jumpTo(controller.offset);
  }

  void resizeText(double value) {
    scaleFactor = value;
    _processLyrics(_lyrics);
  }

  void _processLyrics(String lyricsText) {
    final chordLyricsDocument = chordProcessor.processText(
      text: lyricsText,
      lyricsStyle: textStyle ?? const TextStyle(fontSize: 12),
      chordStyle: chordStyle ?? const TextStyle(fontSize: 12),
      chorusStyle: chorusStyle ?? const TextStyle(fontSize: 12),
      widgetPadding: widgetPadding,
      scaleFactor: scaleFactor,
    );

    _chordLyricsDocument = chordLyricsDocument;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
