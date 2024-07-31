import 'package:custom_flutter_chord/src/lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'model/chord_lyrics_line.dart';

typedef ChordViewBuilder = Widget Function(Widget child);

class LyricsRenderer extends StatefulWidget {
  final String lyrics;
  final TextStyle textStyle;
  final TextStyle chordStyle;
  final bool showChord;
  final bool showText;
  final bool minorScale;
  final Function onTapChord;

  /// To help stop overflow, this should be the sum of left & right padding
  final double widgetPadding;

  /// Extra height between each line
  final double lineHeight;

  /// Widget before the lyrics starts
  final Widget? leadingWidget;

  /// Widget after the lyrics finishes
  final Widget? trailingWidget;

  /// Horizontal alignment
  final CrossAxisAlignment horizontalAlignment;

  /// Scale factor of chords and lyrics
  final double scaleFactor;

  /// Define physics of scrolling
  final ScrollPhysics scrollPhysics;

  /// If not defined it will be the bold version of [textStyle]
  final TextStyle? chorusStyle;

  /// If not defined it will be the italic version of [textStyle]
  final TextStyle? capoStyle;

  /// If not defined it will be the italic version of [textStyle]
  final TextStyle? commentStyle;

  final List<String>? chordPresentation;

  final double fixedChordSpace;

  final LyricsController? lyricsController;

  final ChordViewBuilder? chordViewBuilder;

  const LyricsRenderer(
      {super.key,
      required this.lyrics,
      required this.textStyle,
      required this.chordStyle,
      required this.onTapChord,
      this.chorusStyle,
      this.commentStyle,
      this.capoStyle,
      this.scaleFactor = 1.0,
      this.showChord = true,
      this.showText = true,
      this.minorScale = false,
      this.widgetPadding = 0,
      this.lineHeight = 8.0,
      this.horizontalAlignment = CrossAxisAlignment.center,
      this.scrollPhysics = const ClampingScrollPhysics(),
      this.leadingWidget,
      this.trailingWidget,
      this.chordPresentation,
      this.lyricsController,
      this.chordViewBuilder,
      this.fixedChordSpace = 20.0});

  @override
  State<LyricsRenderer> createState() => _LyricsRendererState();
}

class _LyricsRendererState extends State<LyricsRenderer> {
  late ScrollController _controller;
  late TextStyle chorusStyle;
  late TextStyle capoStyle;
  late TextStyle commentStyle;
  bool _isChorus = false;
  bool _isComment = false;

  late LyricsController _lyricsController;

  @override
  void initState() {
    super.initState();
    chorusStyle = widget.chorusStyle ??
        widget.textStyle.copyWith(fontWeight: FontWeight.bold);
    capoStyle = widget.capoStyle ??
        widget.textStyle.copyWith(fontStyle: FontStyle.italic);
    commentStyle = widget.commentStyle ??
        widget.textStyle.copyWith(
          fontStyle: FontStyle.italic,
          fontSize: widget.textStyle.fontSize! - 2,
        );

    _controller = ScrollController();
    _lyricsController = widget.lyricsController ?? LyricsController();
    _lyricsController.capoStyle = capoStyle;
    _lyricsController.commentStyle = commentStyle;
    _lyricsController.chorusStyle = chorusStyle;
    _lyricsController.scaleFactor = widget.scaleFactor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
      _lyricsController.viewWidth = 1000;
      _lyricsController.init(lyrics: widget.lyrics);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle getLineTextStyle() {
    if (_isChorus) {
      return chorusStyle;
    } else if (_isComment) {
      return commentStyle;
    } else {
      return widget.textStyle;
    }
  }

  // String replaceChord(String chord) {
  //   String currentChord = chord;
  //   switch (widget.chordNotation) {
  //     case ChordNotation.american:
  //       int i = 0;
  //       for (var c in americanNotes) {
  //         if (chord.contains(c)) {
  //           currentChord =
  //               chord.replaceAll(RegExp(c), widget.chordPresentation![i]);
  //           break;
  //         }
  //         i += 1;
  //       }
  //       break;
  //     default:
  //       int i = 0;
  //       for (var c in italianNotes) {
  //         if (chord.contains(c)) {
  //           currentChord =
  //               chord.replaceAll(RegExp(c), widget.chordPresentation![i]);
  //           break;
  //         }
  //         i += 1;
  //       }
  //       break;
  //   }

  //   return currentChord;
  // }

  // String transposeToMinor(String chord) {
  //   String currentChord = chord;

  //   // transpose chords into minor natural scale based on 5th circle
  //   if (widget.minorScale && !chord.contains('m')) {
  //     for (var c in minorScale.entries) {
  //       if (chord.contains(c.key)) {
  //         currentChord = chord.replaceAll(RegExp(c.key), c.value);
  //       }
  //     }
  //   }

  //   return currentChord;
  // }

  Widget getFinalText(MapEntry<int, Chord> chord) {
    // if (widget.minorScale) {
    //   return RichText(
    //     text: TextSpan(
    //         text: transposeToMinor(chord.value.chordText),
    //         style: widget.chordStyle),
    //     textScaler: TextScaler.linear(widget.scaleFactor),
    //   );
    // }
    return RichText(
      text: TextSpan(
        text: chord.value.chordText,
        style: widget.chordStyle,
      ),
      textScaler: TextScaler.linear(_lyricsController.scaleFactor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lyricsController,
      builder: (context, _) {
        final chordLyricsDocument = _lyricsController.chordLyricsDocument;
        if (chordLyricsDocument == null ||
            chordLyricsDocument.chordLyricsLines.isEmpty) return Container();
        Widget child = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: widget.horizontalAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingWidget != null) widget.leadingWidget!,
              if (chordLyricsDocument.capo != null)
                Text('Capo: ${chordLyricsDocument.capo!}', style: capoStyle),
              SizedBox(
                width: 1000,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => SizedBox(
                    height: widget.lineHeight,
                  ),
                  itemBuilder: (context, index) {
                    final ChordLyricsLine line =
                        chordLyricsDocument.chordLyricsLines[index];
                    if (line.isStartOfChorus()) {
                      _isChorus = true;
                    }
                    if (line.isEndOfChorus()) {
                      _isChorus = false;
                    }
                    if (line.isComment()) {
                      _isComment = true;
                    } else {
                      _isComment = false;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showChord)
                          Row(
                            children: line.chords
                                .asMap()
                                .entries
                                .map((chord) => Row(
                                      children: [
                                        SizedBox(
                                          width: !widget.showText
                                              ? (chord.key == 0
                                                  ? 0
                                                  : widget.fixedChordSpace)
                                              : chord.value.leadingSpace,
                                        ),
                                        GestureDetector(
                                          onTap: () => widget.onTapChord(
                                              chord.value.chordText),
                                          child: widget.chordViewBuilder
                                                  ?.call(getFinalText(chord)) ??
                                              getFinalText(chord),
                                        )
                                      ],
                                    ))
                                .toList(),
                          ),
                        // if (widget.showText)
                        //   RichText(
                        //     text: TextSpan(
                        //         text: line.lyrics, style: getLineTextStyle()),
                        //     textScaler: TextScaler.linear(widget.scaleFactor),
                        //   )
                        if (widget.showText)
                          Text.rich(
                            TextSpan(children: line.lyricsContent),
                            style: getLineTextStyle(),
                            textScaler: TextScaler.linear(
                                _lyricsController.scaleFactor),
                          )
                      ],
                    );
                  },
                  itemCount: chordLyricsDocument.chordLyricsLines.length,
                ),
              ),
              if (widget.trailingWidget != null) widget.trailingWidget!,
            ],
          ),
        );

        return SingleChildScrollView(
          controller: _lyricsController.controller,
          physics: widget.scrollPhysics,
          child: child,
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant LyricsRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.scrollSpeed != widget.scrollSpeed) {
    //   _scrollToEnd();
    // }
  }
}

class TextRender extends CustomPainter {
  final String text;
  final TextStyle style;
  TextRender(this.text, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: style,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
