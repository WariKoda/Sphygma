// Einzelabnehmer-Warteschlange: entkoppelt den Notify-Callback (der Werte
// liefert, wann immer das BLE-Geraet sendet) vom async/await-Konsumenten
// (der der Reihe nach auf das naechste Element wartet).
//
// Ein einfacher StreamController.stream.first waere hier ein Fehlgriff:
// Dart erlaubt genau EIN Listen auf einen Single-Subscription-Stream,
// selbst nach Cancel wirft ein zweiter .first "Bad state: Stream has
// already been listened to." - empirisch geprueft, nicht angenommen.
import 'dart:async';
import 'dart:collection';

class FrameMailbox<T> {
  final Queue<T> _buffered = Queue<T>();
  Completer<T>? _waiting;

  /// Uebergibt ein Element. Weckt einen wartenden [next]-Aufruf, falls
  /// einer ansteht, sonst wird das Element gepuffert.
  void deliver(T value) {
    final waiting = _waiting;
    if (waiting != null) {
      _waiting = null;
      waiting.complete(value);
    } else {
      _buffered.add(value);
    }
  }

  /// Liefert das naechste Element - sofort, falls bereits gepuffert,
  /// sonst sobald [deliver] aufgerufen wird.
  Future<T> next() {
    if (_buffered.isNotEmpty) {
      return Future.value(_buffered.removeFirst());
    }
    final completer = Completer<T>();
    _waiting = completer;
    return completer.future;
  }
}
