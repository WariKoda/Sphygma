import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/frame_mailbox.dart';

void main() {
  group('FrameMailbox', () {
    test('liefert ein Element, das eintrifft, waehrend next() schon wartet',
        () async {
      final mailbox = FrameMailbox<int>();

      final pending = mailbox.next();
      mailbox.deliver(1);

      expect(await pending, 1);
    });

    test('puffert ein Element, das eintrifft, bevor next() aufgerufen wird',
        () async {
      final mailbox = FrameMailbox<int>();

      mailbox.deliver(2);

      expect(await mailbox.next(), 2);
    });

    test('mehrere sequentielle next()-Aufrufe liefern in Ankunftsreihenfolge',
        () async {
      final mailbox = FrameMailbox<int>();

      mailbox.deliver(10);
      expect(await mailbox.next(), 10);

      mailbox.deliver(20);
      expect(await mailbox.next(), 20);

      final pending = mailbox.next();
      mailbox.deliver(30);
      expect(await pending, 30);
    });
  });
}
