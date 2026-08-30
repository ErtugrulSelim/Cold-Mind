/// Latin-script letters that fold to an ASCII base so a player typing without
/// diacritics still matches. Covers every Latin language pack the game ships.
const Map<String, String> _latinFolding = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'å': 'a',
  'ą': 'a',
  'ă': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'ę': 'e',
  'ě': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ı': 'i',
  'į': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ø': 'o',
  'ő': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ů': 'u',
  'ű': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'ş': 's',
  'ś': 's',
  'š': 's',
  'ß': 's',
  'ğ': 'g',
  'ż': 'z',
  'ź': 'z',
  'ž': 'z',
  'ł': 'l',
  'ř': 'r',
  'ť': 't',
  'ď': 'd',
  'æ': 'a',
};

/// Codepoint above which a letter is no longer Latin-with-diacritics.
/// Everything below is Basic Latin, Latin-1/Extended, IPA, spacing modifiers
/// and combining marks; Greek starts at U+0370, and Cyrillic, CJK, Hangul,
/// Kana, Arabic, Devanagari and Hebrew all sit above it.
const int _nonLatinScriptStart = 0x370;

/// Normalizes text for free-text comparison: lowercase, fold Latin diacritics
/// to ASCII, keep letters from non-Latin scripts as they are, and collapse
/// everything else to spaces.
///
/// Non-Latin letters have to survive: they are what a Ukrainian, Korean or
/// Chinese player actually types, and a phrase that normalized to the empty
/// string would make `contains()` succeed against any answer at all.
String normalizeAnswer(String input) {
  final lower = input.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    final mapped = _latinFolding[ch] ?? ch;
    final code = mapped.codeUnitAt(0);
    final keep =
        RegExp(r'[a-z0-9]').hasMatch(mapped) ||
        (code >= _nonLatinScriptStart && _isWordChar(mapped));
    buf.write(keep ? mapped : ' ');
  }
  return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// True for anything that carries meaning inside a word in a non-Latin script:
/// letters, digits, and the combining marks that Devanagari matras, Arabic
/// harakat and Hangul jamo are built from — dropping those would shred the word.
/// Punctuation, symbols, separators and control characters are dropped so they
/// cannot leak into a comparison. Latin combining diacritics (U+0300–U+036F)
/// never reach here: they sit below [_nonLatinScriptStart].
bool _isWordChar(String ch) =>
    !RegExp(r'[\p{P}\p{S}\p{Z}\p{C}]', unicode: true).hasMatch(ch) &&
    !_isEmojiModifier(ch);

/// Variation selectors — U+FE0F is what makes '✔️' two code units rather than
/// one. They are nonspacing marks, so the mark-preserving rule above would keep
/// them and leave an invisible character glued to the end of a phrase.
bool _isEmojiModifier(String ch) {
  final code = ch.codeUnitAt(0);
  return code >= 0xFE00 && code <= 0xFE0F;
}
