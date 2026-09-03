/// Wird geworfen bei Pruefsummenfehlern, unerwarteten Antworttypen oder
/// abgebrochenen Uebertragungen. Sphygma faellt hier hart aus - siehe
/// CLAUDE.md "Fail hard": eine leere Liste ist von "keine Messwerte" nicht
/// unterscheidbar.
class ProtocolException implements Exception {
  ProtocolException(this.message);

  final String message;

  @override
  String toString() => 'ProtocolException: $message';
}
