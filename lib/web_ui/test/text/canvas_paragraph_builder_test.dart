// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.12
import 'package:test/bootstrap/browser.dart';
import 'package:test/test.dart';
import 'package:ui/src/engine.dart';
import 'package:ui/ui.dart';

const String paragraphStyle = 'style="position: absolute; white-space: pre-wrap; overflow-wrap: break-word; overflow: hidden;"';
const String defaultColor = 'color: rgb(255, 0, 0);';
const String defaultFontFamily = 'font-family: sans-serif;';
const String defaultFontSize = 'font-size: 14px;';

void main() {
  internalBootstrapBrowserTest(() => testMain);
}

void testMain() {
  setUpAll(() {
    WebExperiments.ensureInitialized();
  });

  test('Builds a text-only canvas paragraph', () {
    final EngineParagraphStyle style = EngineParagraphStyle(fontSize: 13.0);
    final CanvasParagraphBuilder builder = CanvasParagraphBuilder(style);

    builder.addText('Hello');

    final CanvasParagraph paragraph = builder.build();
    expect(paragraph.paragraphStyle, style);
    expect(paragraph.toPlainText(), 'Hello');
    expect(
      paragraph.toDomElement().outerHtml,
      '<p $paragraphStyle><span style="$defaultColor font-size: 13px; $defaultFontFamily">Hello</span></p>',
    );
    expect(paragraph.spans, hasLength(1));

    final ParagraphSpan span = paragraph.spans.single;
    expect(span, isA<FlatTextSpan>());
    final FlatTextSpan textSpan = span as FlatTextSpan;
    expect(textSpan.textOf(paragraph), 'Hello');
    expect(textSpan.style, styleWithDefaults(fontSize: 13.0));
  });

  test('Correct defaults', () {
    final EngineParagraphStyle style = EngineParagraphStyle();
    final CanvasParagraphBuilder builder = CanvasParagraphBuilder(style);

    builder.addText('Hello');

    final CanvasParagraph paragraph = builder.build();
    expect(paragraph.paragraphStyle, style);
    expect(paragraph.toPlainText(), 'Hello');
    expect(
      paragraph.toDomElement().outerHtml,
      '<p $paragraphStyle><span style="$defaultColor $defaultFontSize $defaultFontFamily">Hello</span></p>',
    );
    expect(paragraph.spans, hasLength(1));

    final FlatTextSpan textSpan = paragraph.spans.single as FlatTextSpan;
    expect(textSpan.style, styleWithDefaults());
  });

  test('Builds a single-span paragraph with complex styles', () {
    final EngineParagraphStyle style =
        EngineParagraphStyle(fontSize: 13.0, height: 1.5);
    final CanvasParagraphBuilder builder = CanvasParagraphBuilder(style);

    builder.pushStyle(TextStyle(fontSize: 9.0));
    builder.pushStyle(TextStyle(fontWeight: FontWeight.bold));
    builder.pushStyle(TextStyle(fontSize: 40.0));
    builder.pop();
    builder
        .pushStyle(TextStyle(fontStyle: FontStyle.italic, letterSpacing: 2.0));
    builder.addText('Hello');

    final CanvasParagraph paragraph = builder.build();
    expect(paragraph.toPlainText(), 'Hello');
    expect(
      paragraph.toDomElement().outerHtml,
      '<p $paragraphStyle>'
      '<span style="$defaultColor line-height: 1.5; font-size: 9px; font-weight: bold; font-style: italic; $defaultFontFamily letter-spacing: 2px;">'
      'Hello'
      '</span>'
      '</p>',
    );
    expect(paragraph.spans, hasLength(1));

    final FlatTextSpan span = paragraph.spans.single as FlatTextSpan;
    expect(span.textOf(paragraph), 'Hello');
    expect(
      span.style,
      styleWithDefaults(
        height: 1.5,
        fontSize: 9.0,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        letterSpacing: 2.0,
      ),
    );
  });

  test('Builds a multi-span paragraph', () {
    final EngineParagraphStyle style = EngineParagraphStyle(fontSize: 13.0);
    final CanvasParagraphBuilder builder = CanvasParagraphBuilder(style);

    builder.pushStyle(TextStyle(fontWeight: FontWeight.bold));
    builder.addText('Hello');
    builder.pop();
    builder.pushStyle(TextStyle(fontStyle: FontStyle.italic));
    builder.addText(' world');

    final CanvasParagraph paragraph = builder.build();
    expect(paragraph.toPlainText(), 'Hello world');
    expect(
      paragraph.toDomElement().outerHtml,
      '<p $paragraphStyle>'
      '<span style="$defaultColor font-size: 13px; font-weight: bold; $defaultFontFamily">'
      'Hello'
      '</span>'
      '<span style="$defaultColor font-size: 13px; font-style: italic; $defaultFontFamily">'
      ' world'
      '</span>'
      '</p>',
    );
    expect(paragraph.spans, hasLength(2));

    final FlatTextSpan hello = paragraph.spans.first as FlatTextSpan;
    expect(hello.textOf(paragraph), 'Hello');
    expect(
      hello.style,
      styleWithDefaults(
        fontSize: 13.0,
        fontWeight: FontWeight.bold,
      ),
    );

    final FlatTextSpan world = paragraph.spans.last as FlatTextSpan;
    expect(world.textOf(paragraph), ' world');
    expect(
      world.style,
      styleWithDefaults(
        fontSize: 13.0,
        fontStyle: FontStyle.italic,
      ),
    );
  });

  test('Builds a multi-span paragraph with complex styles', () {
    final EngineParagraphStyle style = EngineParagraphStyle(fontSize: 13.0);
    final CanvasParagraphBuilder builder = CanvasParagraphBuilder(style);

    builder.pushStyle(TextStyle(fontWeight: FontWeight.bold));
    builder.pushStyle(TextStyle(height: 2.0));
    builder.addText('Hello');
    builder.pop(); // pop TextStyle(height: 2.0).
    builder.pushStyle(TextStyle(fontStyle: FontStyle.italic));
    builder.addText(' world');
    builder.pushStyle(TextStyle(fontWeight: FontWeight.normal));
    builder.addText('!');

    final CanvasParagraph paragraph = builder.build();
    expect(paragraph.toPlainText(), 'Hello world!');
    expect(
      paragraph.toDomElement().outerHtml,
      '<p $paragraphStyle>'
      '<span style="$defaultColor line-height: 2; font-size: 13px; font-weight: bold; $defaultFontFamily">'
      'Hello'
      '</span>'
      '<span style="$defaultColor font-size: 13px; font-weight: bold; font-style: italic; $defaultFontFamily">'
      ' world'
      '</span>'
      '<span style="$defaultColor font-size: 13px; font-weight: normal; font-style: italic; $defaultFontFamily">'
      '!'
      '</span>'
      '</p>',
    );
    expect(paragraph.spans, hasLength(3));

    final FlatTextSpan hello = paragraph.spans[0] as FlatTextSpan;
    expect(hello.textOf(paragraph), 'Hello');
    expect(
      hello.style,
      styleWithDefaults(
        fontSize: 13.0,
        fontWeight: FontWeight.bold,
        height: 2.0,
      ),
    );

    final FlatTextSpan world = paragraph.spans[1] as FlatTextSpan;
    expect(world.textOf(paragraph), ' world');
    expect(
      world.style,
      styleWithDefaults(
        fontSize: 13.0,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );

    final FlatTextSpan bang = paragraph.spans[2] as FlatTextSpan;
    expect(bang.textOf(paragraph), '!');
    expect(
      bang.style,
      styleWithDefaults(
        fontSize: 13.0,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.italic,
      ),
    );
  });
}

TextStyle styleWithDefaults({
  Color color = const Color(0xFFFF0000),
  String fontFamily = DomRenderer.defaultFontFamily,
  double fontSize = DomRenderer.defaultFontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    color: color,
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    height: height,
    letterSpacing: letterSpacing,
  );
}
