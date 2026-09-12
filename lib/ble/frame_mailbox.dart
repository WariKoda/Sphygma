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
  Object? _failure;
  StackTrace? _failureStack;

  /// Ein Transportfehler beendet die Sitzung auch dann, wenn der Aufrufer
  /// noch auf seinen Write wartet und erst danach die Antwort abholt.
  void fail(Object error, [StackTrace? stackTrace]) {
    if (_failure != null) return;
    _failure = error;
    _failureStack = stackTrace;
    _buffered.clear();
    final waiting = _waiting;
    _waiting = null;
    waiting?.completeError(error, stackTrace);
  }

  /// Uebergibt ein Element. Weckt einen wartenden [next]-Aufruf, falls
  /// einer ansteht, sonst wird das Element gepuffert.
  void deliver(T value) {
    if (_failure != null) return;
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
    final failure = _failure;
    if (failure != null) return Future.error(failure, _failureStack);
    if (_buffered.isNotEmpty) {
      return Future.value(_buffered.removeFirst());
    }
    final completer = Completer<T>();
    _waiting = completer;
    return completer.future;
  }
}
