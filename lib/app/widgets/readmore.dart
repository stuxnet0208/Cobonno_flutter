import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/routes/router.gr.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/shared_code.dart';

enum TrimMode {
  length,
  line,
}

class ReadMoreText extends StatefulWidget {
  const ReadMoreText(
    this.data, {
    Key? key,
    this.preDataText,
    this.postDataText,
    this.preDataTextStyle,
    this.postDataTextStyle,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.length,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = '$_kEllipsis ',
    this.delimiterStyle,
    this.callback,
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  /// Textspan used before the data any heading or somthing
  final String? preDataText;

  /// Textspan used after the data end or before the more/less
  final String? postDataText;

  /// Textspan used before the data any heading or somthing
  final TextStyle? preDataTextStyle;

  /// Textspan used after the data end or before the more/less
  final TextStyle? postDataTextStyle;

  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final String delimiter;
  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextStyle? delimiterStyle;

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign = widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor = widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText = widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final defaultLessStyle =
        widget.lessStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
    final defaultMoreStyle =
        widget.moreStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
    final defaultDelimiterStyle = widget.delimiterStyle ?? effectiveTextStyle;

    const hashtagTextStyle = TextStyle(color: Colors.blue);

    TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? defaultMoreStyle : defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    TextSpan delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
              ? widget.delimiter
              : ''
          : '',
      style: defaultDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        TextSpan? preTextSpan;
        TextSpan? postTextSpan;
        if (widget.preDataText != null) {
          preTextSpan = getHashTagTextSpan(
              decoratedStyle: hashtagTextStyle,
              basicStyle: widget.preDataTextStyle ?? effectiveTextStyle ?? const TextStyle(),
              source: widget.preDataText ?? '');
        }
        if (widget.postDataText != null) {
          postTextSpan = getHashTagTextSpan(
              decoratedStyle: hashtagTextStyle,
              basicStyle: widget.postDataTextStyle ?? effectiveTextStyle ?? const TextStyle(),
              source: widget.postDataText ?? '');
        }

        // Create a TextSpan with data
        final text = TextSpan(
          children: [
            if (preTextSpan != null) preTextSpan,
            getHashTagTextSpan(
                decoratedStyle: hashtagTextStyle,
                basicStyle: effectiveTextStyle ?? const TextStyle(),
                source: widget.data),
            if (postTextSpan != null) postTextSpan
          ],
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl ? readMoreSize : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.trimLength < widget.data.length) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _readMore ? widget.data.substring(0, widget.trimLength) : widget.data,
                children: <TextSpan>[delimiter, link],
              );
            } else {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: widget.data,
              );
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              textSpan = getHashTagTextSpan(
                  decoratedStyle: hashtagTextStyle,
                  basicStyle: effectiveTextStyle ?? const TextStyle(),
                  children: <TextSpan>[delimiter, link],
                  readMore: _readMore,
                  source: _readMore
                      ? widget.data.substring(0, endIndex) +
                          (linkLongerThanLine ? _kLineSeparator : '')
                      : widget.data);
            } else {
              textSpan = getHashTagTextSpan(
                  decoratedStyle: hashtagTextStyle,
                  basicStyle: effectiveTextStyle ?? const TextStyle(),
                  readMore: _readMore,
                  source: widget.data);
            }
            break;
          default:
            throw Exception('TrimMode type: ${widget.trimMode} is not supported');
        }

        return Text.rich(
          TextSpan(
            children: [
              if (preTextSpan != null) preTextSpan,
              textSpan,
              if (postTextSpan != null) postTextSpan,
            ],
          ),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.clip,
          textScaleFactor: textScaleFactor,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return result;
  }

  TextSpan getHashTagTextSpan({
    required TextStyle decoratedStyle,
    required TextStyle basicStyle,
    required String source,
    List<InlineSpan>? children,
    Function(String)? onTap,
    bool decorateAtSign = false,
    bool readMore = true,
  }) {
    final decorations = ReadMoreDetector(
            decoratedStyle: decoratedStyle, textStyle: basicStyle, decorateAtSign: decorateAtSign)
        .getDetections(source);

    // @david note: for some unknown reason, decorations always empty and in
    // the textspan, @alga maybe forgot to add the children which contains link

    // @alga note: it turns out that if the character is double bytes (japanese characters), the decoration will be empty.

    // if (decorations.isEmpty) {
    //   return TextSpan(text: source, style: basicStyle);
    // } else {
    // }
    decorations.sort();
    final span = decorations
        .asMap()
        .map(
          (index, item) {
            // final recognizer = TapGestureRecognizer()
            //   ..onTap = () {
            //     final decoration = decorations[index];
            //     if (decoration.style == decoratedStyle) {
            //       onTap!(decoration.range.textInside(source).trim());
            //     }
            //   };
            String clickableText = item.range.textInside(source);
            return MapEntry(
              index,
              TextSpan(
                style: item.style,
                text: clickableText,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    //debugPrint('clickable text $clickableText');
                    if (SharedCode.urlRegExp.hasMatch(clickableText)) {
                      try {
                        _launchUrl(clickableText);
                      } catch (e) {
                        SharedCode.showErrorDialog(
                            context, AppLocalizations.of(context).error, e.toString());
                      }
                    } else {
                      clickableText =
                          clickableText.substring(clickableText.indexOf('#'), clickableText.length);
                      //debugPrint('route ${AutoRouter.of(context).current.name}');
                      //debugPrint('route ${AutoRouter.of(context).current.parent?.name}');
                      context.router
                          .push(HomeRoute(children: [ExploreRoute(initialSearch: clickableText)]));
                    }
                  },
              ),
            );
          },
        )
        .values
        .toList();

    List<InlineSpan> list = [];
    list.addAll(span);
    if (_readMore && span.isEmpty) {
      list.add(TextSpan(text: source, style: basicStyle));
    }
    list.add(const TextSpan(text: ' '));
    if (children != null) {
      list.addAll(children);
    }

    return TextSpan(children: list);
  }

  Future<void> _launchUrl(String url) async {
    if (!url.contains('https://') && !url.contains('http://')) {
      url = 'https://$url';
    }
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw AppLocalizations.of(context).couldNotLaunchUrl(url);
    }
  }
}

class ReadMoreDetector {
  final TextStyle? textStyle;
  final TextStyle? decoratedStyle;
  final bool? decorateAtSign;

  ReadMoreDetector({this.textStyle, this.decoratedStyle, this.decorateAtSign = false});

  List<Detection> _getSourceDetections(List<RegExpMatch> tags, String copiedText) {
    TextRange? previousItem;
    final result = <Detection>[];
    for (var tag in tags) {
      ///Add untagged content
      if (previousItem == null) {
        if (tag.start > 0) {
          result.add(Detection(range: TextRange(start: 0, end: tag.start), style: textStyle));
        }
      } else {
        result.add(
            Detection(range: TextRange(start: previousItem.end, end: tag.start), style: textStyle));
      }

      ///Add tagged content
      result
          .add(Detection(range: TextRange(start: tag.start, end: tag.end), style: decoratedStyle));
      previousItem = TextRange(start: tag.start, end: tag.end);
    }

    ///Add remaining untagged content
    if (result.last.range.end < copiedText.length) {
      result.add(Detection(
          range: TextRange(start: result.last.range.end, end: copiedText.length),
          style: textStyle));
    }
    return result;
  }

  ///Decorate tagged content, filter out the ones includes emoji.
  List<Detection> _getEmojiFilteredDetections(
      {required List<Detection> source, String? copiedText, List<RegExpMatch>? emojiMatches}) {
    final result = <Detection>[];
    for (var item in source) {
      int? emojiStartPoint;
      for (var emojiMatch in emojiMatches!) {
        final detectionContainsEmoji =
            (item.range.start < emojiMatch.start && emojiMatch.end <= item.range.end);
        if (detectionContainsEmoji) {
          /// If the current Emoji's range.start is the smallest in the tag, update emojiStartPoint
          emojiStartPoint = (emojiStartPoint != null)
              ? ((emojiMatch.start < emojiStartPoint) ? emojiMatch.start : emojiStartPoint)
              : emojiMatch.start;
        }
      }
      if (item.style == decoratedStyle && emojiStartPoint != null) {
        result.add(Detection(
          range: TextRange(start: item.range.start, end: emojiStartPoint),
          style: decoratedStyle,
        ));
        result.add(Detection(
            range: TextRange(start: emojiStartPoint, end: item.range.end), style: textStyle));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Return the list of decorations with tagged and untagged text
  List<Detection> getDetections(String copiedText) {
    /// Text to change emoji into replacement text
    final fullWidthRegExp = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

    final fullWidthRegExpMatches = fullWidthRegExp.allMatches(copiedText).toList();
    final tokenRegExp = RegExp(r'[・ぁ-んーァ-ヶ一-龥\u1100-\u11FF\uAC00-\uD7A3０-９ａ-ｚＡ-Ｚ　]');
    final emojiMatches = fullWidthRegExpMatches
        .where((match) => (!tokenRegExp.hasMatch(copiedText.substring(match.start, match.end))))
        .toList();

    /// This is to avoid the error caused by 'regExp' which counts the emoji's length 1.
    for (var emojiMatch in emojiMatches) {
      final emojiLength = emojiMatch.group(0)!.length;
      final replacementText = "a" * emojiLength;
      copiedText = copiedText.replaceRange(emojiMatch.start, emojiMatch.end, replacementText);
    }

    /// Regular expression to extract hashtag from text
    ///
    /// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
    final hashTagRegExp = RegExp(
      "(?!\\n)(?:^|\\s)(#([$hashTagContentLetters]+))|((https?:www\\.)|(https?:\\/\\/)|(www\\.))[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9]{1,6}(\\/[-a-zA-Z0-9()@:%_\\+.~#?&\\/=]*)?",
      multiLine: true,
    );

    /// Regular expression when you select decorateAtSign
    final hashTagAtSignRegExp = RegExp(
      "(?!\\n)(?:^|\\s)([#@]([$hashTagContentLetters]+))|((https?:www\\.)|(https?:\\/\\/)|(www\\.))[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9]{1,6}(\\/[-a-zA-Z0-9()@:%_\\+.~#?&\\/=]*)?",
      multiLine: true,
    );

    RegExp regExp = decorateAtSign! ? hashTagAtSignRegExp : hashTagRegExp;

    List<RegExpMatch> tags = regExp.allMatches(copiedText).toList();

    if (tags.isEmpty) {
      return [];
    }

    final sourceDetections = _getSourceDetections(tags, copiedText);

    final emojiFilteredResult = _getEmojiFilteredDetections(
        copiedText: copiedText, emojiMatches: emojiMatches, source: sourceDetections);

    return emojiFilteredResult;
  }
}
