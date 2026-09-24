/// Joins [parts] with [separator], each part in a Unicode first-strong
/// isolate (FSI … PDI).
///
/// Mixed-direction runs — a Latin asset code next to an Arabic duration or
/// name — otherwise reorder around each other inside a right-to-left
/// paragraph: "AST-0017 • 07 م 09 ث" comes out with the number on the wrong
/// side of the code. Isolating each part lets it keep its own direction
/// while the separators follow the paragraph's.
String joinIsolated(Iterable<String> parts, String separator) =>
    parts.map((part) => '\u2068$part\u2069').join(separator);
