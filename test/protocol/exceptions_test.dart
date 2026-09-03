import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/exceptions.dart';

void main() {
  test('ProtocolException traegt die Nachricht in toString', () {
    final e = ProtocolException('Pruefsumme ungueltig');

    expect(e.toString(), contains('Pruefsumme ungueltig'));
  });

  test('ProtocolException ist eine Exception', () {
    expect(ProtocolException('x'), isA<Exception>());
  });
}
