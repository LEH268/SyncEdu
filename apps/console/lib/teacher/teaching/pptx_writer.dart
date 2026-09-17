/// Writes a re-teach deck as a real `.pptx` the teacher can open and edit.
///
/// A `.pptx` is an OPC package: a zip of OOXML parts wired together by
/// relationship files. `archive` writes the zip; every part below is composed
/// here, because the alternative -- rendering a PDF -- hands the teacher
/// something they cannot change, and a deck they cannot change is a deck they
/// will not use.
///
/// Deliberately placeholder-free: every shape is an explicit text box with its
/// own position, so nothing depends on inheritance from the slide layout and
/// the file renders the same in PowerPoint, Keynote and Google Slides. The
/// single blank layout and master exist only because the format requires them.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// One slide: a heading, its bullets, and what to say while it is up.
class SlideSpec {
  const SlideSpec({
    required this.title,
    required this.bullets,
    this.notes = '',
  });

  final String title;
  final List<String> bullets;
  final String notes;
}

/// A deck. [subtitle] is rendered under [title] on the opening slide and is
/// where the console states which class and chapter the deck was built from.
class DeckSpec {
  const DeckSpec({
    required this.title,
    required this.subtitle,
    required this.slides,
  });

  final String title;
  final String subtitle;
  final List<SlideSpec> slides;
}

// 16:9, in EMU (914400 per inch).
const int _slideWidth = 12192000;
const int _slideHeight = 6858000;
const int _margin = 838200;

const String _aNs = 'http://schemas.openxmlformats.org/drawingml/2006/main';
const String _rNs =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const String _pNs =
    'http://schemas.openxmlformats.org/presentationml/2006/main';
const String _relNs =
    'http://schemas.openxmlformats.org/package/2006/relationships';
const String _ct = 'application/vnd.openxmlformats-officedocument.presentationml';

/// XML text escaping. Every string reaching a part goes through this: slide
/// text is model output, so an unescaped `&` would produce a file PowerPoint
/// refuses to open rather than merely an odd-looking slide.
String _x(String value) => const HtmlEscape(HtmlEscapeMode.element)
    .convert(value)
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;')
    // XML 1.0 admits no control characters other than tab, LF and CR.
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

const String _decl = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';

/// Builds the deck. The result is the exact bytes of a `.pptx` file.
Uint8List buildPptx(DeckSpec deck) {
  final Archive archive = Archive();
  void add(String name, String content) =>
      archive.add(ArchiveFile.string(name, content));

  // The title slide is generated, so slide numbering runs one ahead of the
  // caller's list: slide1 is the cover, slide N+1 is deck.slides[N-1].
  final int slideCount = deck.slides.length + 1;

  add('[Content_Types].xml', _contentTypes(deck));
  add('_rels/.rels', _rootRels());
  add('ppt/presentation.xml', _presentation(slideCount));
  add('ppt/_rels/presentation.xml.rels', _presentationRels(slideCount));
  add('ppt/theme/theme1.xml', _theme('Office Theme'));
  add('ppt/theme/theme2.xml', _theme('Office Theme'));
  add('ppt/slideMasters/slideMaster1.xml', _slideMaster());
  add('ppt/slideMasters/_rels/slideMaster1.xml.rels', _slideMasterRels());
  add('ppt/slideLayouts/slideLayout1.xml', _slideLayout());
  add('ppt/slideLayouts/_rels/slideLayout1.xml.rels', _slideLayoutRels());
  add('ppt/notesMasters/notesMaster1.xml', _notesMaster());
  add('ppt/notesMasters/_rels/notesMaster1.xml.rels', _notesMasterRels());

  add('ppt/slides/slide1.xml', _titleSlide(deck.title, deck.subtitle));
  add('ppt/slides/_rels/slide1.xml.rels', _slideRels(1, hasNotes: false));

  for (int i = 0; i < deck.slides.length; i++) {
    final int number = i + 2;
    final SlideSpec slide = deck.slides[i];
    final bool hasNotes = slide.notes.trim().isNotEmpty;
    add('ppt/slides/slide$number.xml', _contentSlide(slide));
    add('ppt/slides/_rels/slide$number.xml.rels',
        _slideRels(number, hasNotes: hasNotes));
    if (hasNotes) {
      add('ppt/notesSlides/notesSlide$number.xml', _notesSlide(slide.notes));
      add(
        'ppt/notesSlides/_rels/notesSlide$number.xml.rels',
        _notesSlideRels(number),
      );
    }
  }

  return ZipEncoder().encodeBytes(archive);
}

String _contentTypes(DeckSpec deck) {
  final int slideCount = deck.slides.length + 1;
  final StringBuffer buffer = StringBuffer()
    ..write(_decl)
    ..write('<Types xmlns="http://schemas.openxmlformats.org/package/2006/'
        'content-types">')
    ..write('<Default Extension="rels" ContentType="application/vnd.'
        'openxmlformats-package.relationships+xml"/>')
    ..write('<Default Extension="xml" ContentType="application/xml"/>')
    ..write('<Override PartName="/ppt/presentation.xml" ContentType="'
        '$_ct.presentation.main+xml"/>')
    ..write('<Override PartName="/ppt/slideMasters/slideMaster1.xml" '
        'ContentType="$_ct.slideMaster+xml"/>')
    ..write('<Override PartName="/ppt/slideLayouts/slideLayout1.xml" '
        'ContentType="$_ct.slideLayout+xml"/>')
    ..write('<Override PartName="/ppt/notesMasters/notesMaster1.xml" '
        'ContentType="$_ct.notesMaster+xml"/>')
    ..write('<Override PartName="/ppt/theme/theme1.xml" ContentType="'
        'application/vnd.openxmlformats-officedocument.theme+xml"/>')
    ..write('<Override PartName="/ppt/theme/theme2.xml" ContentType="'
        'application/vnd.openxmlformats-officedocument.theme+xml"/>');
  for (int n = 1; n <= slideCount; n++) {
    buffer.write('<Override PartName="/ppt/slides/slide$n.xml" ContentType="'
        '$_ct.slide+xml"/>');
    // The cover has no notes, and neither does a slide whose notes are blank.
    // Declaring an override for a part that is not in the package makes the
    // file invalid, so this mirrors exactly what buildPptx wrote.
    if (n >= 2 && deck.slides[n - 2].notes.trim().isNotEmpty) {
      buffer.write('<Override PartName="/ppt/notesSlides/notesSlide$n.xml" '
          'ContentType="$_ct.notesSlide+xml"/>');
    }
  }
  return (buffer..write('</Types>')).toString();
}

String _rootRels() => '$_decl<Relationships xmlns="$_relNs">'
    '<Relationship Id="rId1" Type="$_rNs/officeDocument" '
    'Target="ppt/presentation.xml"/>'
    '</Relationships>';

String _presentation(int slideCount) {
  final StringBuffer slides = StringBuffer();
  for (int n = 1; n <= slideCount; n++) {
    // Slide ids are arbitrary but must be >= 256 and unique.
    slides.write('<p:sldId id="${255 + n}" r:id="rId${n + 2}"/>');
  }
  return '$_decl'
      '<p:presentation xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs" '
      'saveSubsetFonts="1">'
      '<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/>'
      '</p:sldMasterIdLst>'
      '<p:notesMasterIdLst><p:notesMasterId r:id="rId2"/></p:notesMasterIdLst>'
      '<p:sldIdLst>$slides</p:sldIdLst>'
      '<p:sldSz cx="$_slideWidth" cy="$_slideHeight"/>'
      '<p:notesSz cx="6858000" cy="9144000"/>'
      '</p:presentation>';
}

String _presentationRels(int slideCount) {
  final StringBuffer buffer = StringBuffer()
    ..write('$_decl<Relationships xmlns="$_relNs">')
    ..write('<Relationship Id="rId1" Type="$_rNs/slideMaster" '
        'Target="slideMasters/slideMaster1.xml"/>')
    ..write('<Relationship Id="rId2" Type="$_rNs/notesMaster" '
        'Target="notesMasters/notesMaster1.xml"/>');
  for (int n = 1; n <= slideCount; n++) {
    buffer.write('<Relationship Id="rId${n + 2}" Type="$_rNs/slide" '
        'Target="slides/slide$n.xml"/>');
  }
  return (buffer..write('</Relationships>')).toString();
}

String _slideMasterRels() => '$_decl<Relationships xmlns="$_relNs">'
    '<Relationship Id="rId1" Type="$_rNs/slideLayout" '
    'Target="../slideLayouts/slideLayout1.xml"/>'
    '<Relationship Id="rId2" Type="$_rNs/theme" Target="../theme/theme1.xml"/>'
    '</Relationships>';

String _slideLayoutRels() => '$_decl<Relationships xmlns="$_relNs">'
    '<Relationship Id="rId1" Type="$_rNs/slideMaster" '
    'Target="../slideMasters/slideMaster1.xml"/>'
    '</Relationships>';

String _notesMasterRels() => '$_decl<Relationships xmlns="$_relNs">'
    '<Relationship Id="rId1" Type="$_rNs/theme" Target="../theme/theme2.xml"/>'
    '</Relationships>';

String _slideRels(int slideNumber, {required bool hasNotes}) {
  // The notes part relates from the slide, so its id lives here rather than in
  // the presentation's own relationships.
  final String notes = hasNotes
      ? '<Relationship Id="rId2" Type="$_rNs/notesSlide" '
          'Target="../notesSlides/notesSlide$slideNumber.xml"/>'
      : '';
  return '$_decl<Relationships xmlns="$_relNs">'
      '<Relationship Id="rId1" Type="$_rNs/slideLayout" '
      'Target="../slideLayouts/slideLayout1.xml"/>'
      '$notes'
      '</Relationships>';
}

String _notesSlideRels(int slideNumber) => '$_decl<Relationships '
    'xmlns="$_relNs">'
    '<Relationship Id="rId1" Type="$_rNs/slide" '
    'Target="../slides/slide$slideNumber.xml"/>'
    '<Relationship Id="rId2" Type="$_rNs/notesMaster" '
    'Target="../notesMasters/notesMaster1.xml"/>'
    '</Relationships>';

/// The empty shape tree every master and layout needs to be well-formed.
const String _emptyTree = '<p:spTree>'
    '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/>'
    '</p:nvGrpSpPr>'
    '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
    '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
    '</p:spTree>';

const String _clrMap = '<p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" '
    'accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" '
    'accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>';

String _slideMaster() => '$_decl'
    '<p:sldMaster xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs">'
    '<p:cSld><p:bg><p:bgPr><a:solidFill><a:schemeClr val="bg1"/>'
    '</a:solidFill><a:effectLst/></p:bgPr></p:bg>$_emptyTree</p:cSld>'
    '$_clrMap'
    '<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/>'
    '</p:sldLayoutIdLst>'
    '<p:txStyles>'
    '<p:titleStyle><a:lvl1pPr><a:defRPr sz="4000" b="1"/></a:lvl1pPr>'
    '</p:titleStyle>'
    '<p:bodyStyle><a:lvl1pPr><a:defRPr sz="2000"/></a:lvl1pPr></p:bodyStyle>'
    '<p:otherStyle><a:lvl1pPr><a:defRPr sz="1800"/></a:lvl1pPr></p:otherStyle>'
    '</p:txStyles>'
    '</p:sldMaster>';

String _slideLayout() => '$_decl'
    '<p:sldLayout xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs" '
    'type="blank" preserve="1">'
    '<p:cSld name="Blank">$_emptyTree</p:cSld>'
    '<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>'
    '</p:sldLayout>';

String _notesMaster() => '$_decl'
    '<p:notesMaster xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs">'
    '<p:cSld>$_emptyTree</p:cSld>'
    '$_clrMap'
    '<p:notesStyle><a:lvl1pPr><a:defRPr sz="1200"/></a:lvl1pPr></p:notesStyle>'
    '</p:notesMaster>';

/// One text box, positioned absolutely. [paragraphs] is pre-rendered XML.
String _textBox({
  required int id,
  required String name,
  required int x,
  required int y,
  required int cx,
  required int cy,
  required String paragraphs,
}) =>
    '<p:sp>'
    '<p:nvSpPr><p:cNvPr id="$id" name="${_x(name)}"/>'
    '<p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>'
    '<p:spPr><a:xfrm><a:off x="$x" y="$y"/><a:ext cx="$cx" cy="$cy"/></a:xfrm>'
    '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr>'
    '<p:txBody><a:bodyPr wrap="square" rtlCol="0"><a:normAutofit/></a:bodyPr>'
    '<a:lstStyle/>$paragraphs</p:txBody>'
    '</p:sp>';

String _paragraph(String text, {int size = 2000, bool bold = false, bool bullet = false}) {
  final String properties = bullet
      ? '<a:pPr marL="285750" indent="-285750"><a:buFont typeface="Arial"/>'
          '<a:buChar char="•"/></a:pPr>'
      : '<a:pPr/>';
  // An empty run is invalid; an empty paragraph is how OOXML spells a blank
  // line, so a blank bullet degrades to spacing rather than a broken file.
  if (text.trim().isEmpty) return '<a:p>$properties</a:p>';
  return '<a:p>$properties<a:r>'
      '<a:rPr lang="en-US" sz="$size"${bold ? ' b="1"' : ''} dirty="0"/>'
      '<a:t>${_x(text)}</a:t></a:r></a:p>';
}

String _slideShell(String shapes) => '$_decl'
    '<p:sld xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs">'
    '<p:cSld><p:spTree>'
    '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/>'
    '</p:nvGrpSpPr>'
    '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
    '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
    '$shapes'
    '</p:spTree></p:cSld>'
    '<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>'
    '</p:sld>';

String _titleSlide(String title, String subtitle) => _slideShell(
      _textBox(
            id: 2,
            name: 'Title',
            x: _margin,
            y: 2286000,
            cx: _slideWidth - _margin * 2,
            cy: 1600200,
            paragraphs: _paragraph(title, size: 4000, bold: true),
          ) +
          _textBox(
            id: 3,
            name: 'Subtitle',
            x: _margin,
            y: 3962400,
            cx: _slideWidth - _margin * 2,
            cy: 914400,
            paragraphs: _paragraph(subtitle, size: 1800),
          ),
    );

String _contentSlide(SlideSpec slide) {
  final StringBuffer body = StringBuffer();
  for (final String bullet in slide.bullets) {
    body.write(_paragraph(bullet, size: 2000, bullet: true));
  }
  // A slide with no bullets would leave an empty txBody, which PowerPoint
  // rejects; one empty paragraph is the well-formed equivalent.
  if (slide.bullets.isEmpty) body.write('<a:p><a:pPr/></a:p>');

  return _slideShell(
    _textBox(
          id: 2,
          name: 'Title',
          x: _margin,
          y: 457200,
          cx: _slideWidth - _margin * 2,
          cy: 1143000,
          paragraphs: _paragraph(slide.title, size: 3200, bold: true),
        ) +
        _textBox(
          id: 3,
          name: 'Body',
          x: _margin,
          y: 1828800,
          cx: _slideWidth - _margin * 2,
          cy: _slideHeight - 1828800 - 457200,
          paragraphs: body.toString(),
        ),
  );
}

String _notesSlide(String notes) {
  final StringBuffer paragraphs = StringBuffer();
  for (final String line in notes.split('\n')) {
    paragraphs.write(_paragraph(line, size: 1200));
  }
  return '$_decl'
      '<p:notes xmlns:a="$_aNs" xmlns:r="$_rNs" xmlns:p="$_pNs">'
      '<p:cSld><p:spTree>'
      '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/>'
      '</p:nvGrpSpPr>'
      '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
      '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
      '<p:sp>'
      '<p:nvSpPr><p:cNvPr id="2" name="Notes Placeholder"/>'
      '<p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>'
      '<p:nvPr><p:ph type="body" idx="1"/></p:nvPr></p:nvSpPr>'
      '<p:spPr/>'
      '<p:txBody><a:bodyPr/><a:lstStyle/>$paragraphs</p:txBody>'
      '</p:sp>'
      '</p:spTree></p:cSld>'
      '<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>'
      '</p:notes>';
}

/// A complete Office-style theme. Required by the format; the deck's own text
/// boxes carry their sizes explicitly, so nothing here is load-bearing beyond
/// the colour and font names PowerPoint resolves `schemeClr` against.
String _theme(String name) {
  const String fill = '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>';
  const String line = '<a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:prstDash val="solid"/></a:ln>';
  const String effect = '<a:effectStyle><a:effectLst/></a:effectStyle>';
  return '$_decl'
      '<a:theme xmlns:a="$_aNs" name="${_x(name)}">'
      '<a:themeElements>'
      '<a:clrScheme name="Office">'
      '<a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>'
      '<a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>'
      '<a:dk2><a:srgbClr val="44546A"/></a:dk2>'
      '<a:lt2><a:srgbClr val="E7E6E6"/></a:lt2>'
      '<a:accent1><a:srgbClr val="4472C4"/></a:accent1>'
      '<a:accent2><a:srgbClr val="ED7D31"/></a:accent2>'
      '<a:accent3><a:srgbClr val="A5A5A5"/></a:accent3>'
      '<a:accent4><a:srgbClr val="FFC000"/></a:accent4>'
      '<a:accent5><a:srgbClr val="5B9BD5"/></a:accent5>'
      '<a:accent6><a:srgbClr val="70AD47"/></a:accent6>'
      '<a:hlink><a:srgbClr val="0563C1"/></a:hlink>'
      '<a:folHlink><a:srgbClr val="954F72"/></a:folHlink>'
      '</a:clrScheme>'
      '<a:fontScheme name="Office">'
      '<a:majorFont><a:latin typeface="Calibri Light"/><a:ea typeface=""/>'
      '<a:cs typeface=""/></a:majorFont>'
      '<a:minorFont><a:latin typeface="Calibri"/><a:ea typeface=""/>'
      '<a:cs typeface=""/></a:minorFont>'
      '</a:fontScheme>'
      '<a:fmtScheme name="Office">'
      '<a:fillStyleLst>$fill$fill$fill</a:fillStyleLst>'
      '<a:lnStyleLst>$line$line$line</a:lnStyleLst>'
      '<a:effectStyleLst>$effect$effect$effect</a:effectStyleLst>'
      '<a:bgFillStyleLst>$fill$fill$fill</a:bgFillStyleLst>'
      '</a:fmtScheme>'
      '</a:themeElements>'
      '<a:objectDefaults/><a:extraClrSchemeLst/>'
      '</a:theme>';
}
