// Die Gruppierung gegen den echten Beispieldatensatz.
// Quelle: docs/design/beispieldaten.md — 114 Messungen, 89 Anlässe.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/occasion_grouping.dart';

Measurement _m(
  int seq,
  DateTime at, {
  required int sys,
  required int dia,
  required int puls,
  required bool bewegung,
  required bool arrhythmie,
}) =>
    Measurement(
      id: seq,
      userSlot: 1,
      deviceSequence: seq,
      systolic: sys,
      diastolic: dia,
      pulse: puls,
      measuredAt: at,
      movement: bewegung,
      arrhythmia: arrhythmie,
      rawBytes: Uint8List(14),
      importedAt: DateTime(2026, 9, 5, 23, 58),
      exportedAt: null,
    );

void main() {
  final bestand = <Measurement>[
      _m(429, DateTime.parse('2026-07-11T20:37:00'), sys: 129, dia: 86, puls: 87, bewegung: false, arrhythmie: false),
      _m(430, DateTime.parse('2026-07-12T07:13:00'), sys: 144, dia: 92, puls: 89, bewegung: true, arrhythmie: false),
      _m(431, DateTime.parse('2026-07-12T07:15:00'), sys: 140, dia: 91, puls: 80, bewegung: false, arrhythmie: false),
      _m(432, DateTime.parse('2026-07-12T20:19:00'), sys: 132, dia: 89, puls: 82, bewegung: false, arrhythmie: false),
      _m(433, DateTime.parse('2026-07-13T20:37:00'), sys: 128, dia: 87, puls: 88, bewegung: false, arrhythmie: false),
      _m(434, DateTime.parse('2026-07-13T20:39:00'), sys: 127, dia: 87, puls: 83, bewegung: false, arrhythmie: false),
      _m(435, DateTime.parse('2026-07-15T07:05:00'), sys: 146, dia: 93, puls: 81, bewegung: false, arrhythmie: false),
      _m(436, DateTime.parse('2026-07-17T07:04:00'), sys: 137, dia: 94, puls: 82, bewegung: false, arrhythmie: true),
      _m(437, DateTime.parse('2026-07-17T07:06:00'), sys: 143, dia: 89, puls: 82, bewegung: false, arrhythmie: false),
      _m(438, DateTime.parse('2026-07-17T20:45:00'), sys: 134, dia: 88, puls: 82, bewegung: false, arrhythmie: false),
      _m(439, DateTime.parse('2026-07-17T20:47:00'), sys: 128, dia: 83, puls: 85, bewegung: false, arrhythmie: false),
      _m(440, DateTime.parse('2026-07-19T07:12:00'), sys: 137, dia: 93, puls: 80, bewegung: false, arrhythmie: false),
      _m(441, DateTime.parse('2026-07-19T20:10:00'), sys: 132, dia: 84, puls: 88, bewegung: false, arrhythmie: false),
      _m(442, DateTime.parse('2026-07-20T20:44:00'), sys: 134, dia: 86, puls: 80, bewegung: false, arrhythmie: false),
      _m(443, DateTime.parse('2026-07-21T07:31:00'), sys: 141, dia: 90, puls: 89, bewegung: false, arrhythmie: false),
      _m(444, DateTime.parse('2026-07-21T07:33:00'), sys: 136, dia: 94, puls: 83, bewegung: false, arrhythmie: false),
      _m(445, DateTime.parse('2026-07-21T20:12:00'), sys: 126, dia: 88, puls: 88, bewegung: false, arrhythmie: false),
      _m(446, DateTime.parse('2026-07-22T07:06:00'), sys: 137, dia: 89, puls: 79, bewegung: false, arrhythmie: false),
      _m(447, DateTime.parse('2026-07-22T07:08:00'), sys: 137, dia: 94, puls: 89, bewegung: true, arrhythmie: false),
      _m(448, DateTime.parse('2026-07-22T20:35:00'), sys: 131, dia: 87, puls: 84, bewegung: false, arrhythmie: false),
      _m(449, DateTime.parse('2026-07-24T07:10:00'), sys: 138, dia: 94, puls: 84, bewegung: false, arrhythmie: false),
      _m(450, DateTime.parse('2026-07-24T20:41:00'), sys: 135, dia: 86, puls: 83, bewegung: false, arrhythmie: false),
      _m(451, DateTime.parse('2026-07-24T20:43:00'), sys: 128, dia: 84, puls: 85, bewegung: false, arrhythmie: false),
      _m(452, DateTime.parse('2026-07-25T07:03:00'), sys: 136, dia: 89, puls: 86, bewegung: false, arrhythmie: false),
      _m(453, DateTime.parse('2026-07-25T07:05:00'), sys: 140, dia: 93, puls: 86, bewegung: false, arrhythmie: false),
      _m(454, DateTime.parse('2026-07-25T20:34:00'), sys: 134, dia: 89, puls: 85, bewegung: false, arrhythmie: false),
      _m(455, DateTime.parse('2026-07-27T20:37:00'), sys: 129, dia: 84, puls: 80, bewegung: false, arrhythmie: false),
      _m(456, DateTime.parse('2026-07-27T20:39:00'), sys: 133, dia: 89, puls: 79, bewegung: false, arrhythmie: false),
      _m(457, DateTime.parse('2026-07-28T07:31:00'), sys: 136, dia: 90, puls: 81, bewegung: false, arrhythmie: false),
      _m(458, DateTime.parse('2026-07-28T20:22:00'), sys: 126, dia: 89, puls: 83, bewegung: false, arrhythmie: false),
      _m(459, DateTime.parse('2026-07-30T20:38:00'), sys: 125, dia: 90, puls: 89, bewegung: false, arrhythmie: false),
      _m(460, DateTime.parse('2026-07-30T20:40:00'), sys: 128, dia: 83, puls: 88, bewegung: false, arrhythmie: false),
      _m(461, DateTime.parse('2026-07-31T20:40:00'), sys: 127, dia: 88, puls: 80, bewegung: true, arrhythmie: false),
      _m(462, DateTime.parse('2026-07-31T20:42:00'), sys: 125, dia: 83, puls: 85, bewegung: false, arrhythmie: false),
      _m(463, DateTime.parse('2026-08-01T07:43:00'), sys: 139, dia: 95, puls: 81, bewegung: false, arrhythmie: false),
      _m(464, DateTime.parse('2026-08-01T20:43:00'), sys: 128, dia: 90, puls: 89, bewegung: false, arrhythmie: false),
      _m(465, DateTime.parse('2026-08-02T07:21:00'), sys: 138, dia: 95, puls: 84, bewegung: false, arrhythmie: false),
      _m(466, DateTime.parse('2026-08-02T20:33:00'), sys: 132, dia: 90, puls: 86, bewegung: true, arrhythmie: false),
      _m(467, DateTime.parse('2026-08-03T07:20:00'), sys: 143, dia: 93, puls: 81, bewegung: false, arrhythmie: false),
      _m(468, DateTime.parse('2026-08-03T07:22:00'), sys: 135, dia: 89, puls: 89, bewegung: false, arrhythmie: false),
      _m(469, DateTime.parse('2026-08-03T20:40:00'), sys: 129, dia: 84, puls: 83, bewegung: false, arrhythmie: false),
      _m(470, DateTime.parse('2026-08-03T20:42:00'), sys: 124, dia: 86, puls: 86, bewegung: false, arrhythmie: false),
      _m(471, DateTime.parse('2026-08-04T07:21:00'), sys: 141, dia: 89, puls: 80, bewegung: false, arrhythmie: false),
      _m(472, DateTime.parse('2026-08-04T07:23:00'), sys: 134, dia: 93, puls: 84, bewegung: true, arrhythmie: false),
      _m(473, DateTime.parse('2026-08-04T20:06:00'), sys: 129, dia: 85, puls: 80, bewegung: false, arrhythmie: false),
      _m(474, DateTime.parse('2026-08-05T07:30:00'), sys: 136, dia: 94, puls: 80, bewegung: false, arrhythmie: false),
      _m(475, DateTime.parse('2026-08-05T20:14:00'), sys: 128, dia: 90, puls: 82, bewegung: true, arrhythmie: false),
      _m(476, DateTime.parse('2026-08-05T20:16:00'), sys: 129, dia: 83, puls: 81, bewegung: false, arrhythmie: false),
      _m(477, DateTime.parse('2026-08-06T07:16:00'), sys: 141, dia: 89, puls: 86, bewegung: false, arrhythmie: false),
      _m(478, DateTime.parse('2026-08-06T07:18:00'), sys: 142, dia: 88, puls: 89, bewegung: false, arrhythmie: false),
      _m(479, DateTime.parse('2026-08-06T20:04:00'), sys: 131, dia: 86, puls: 87, bewegung: false, arrhythmie: false),
      _m(480, DateTime.parse('2026-08-06T20:06:00'), sys: 133, dia: 87, puls: 87, bewegung: false, arrhythmie: false),
      _m(481, DateTime.parse('2026-08-07T07:31:00'), sys: 141, dia: 94, puls: 80, bewegung: false, arrhythmie: false),
      _m(482, DateTime.parse('2026-08-10T07:20:00'), sys: 132, dia: 84, puls: 83, bewegung: false, arrhythmie: false),
      _m(483, DateTime.parse('2026-08-10T20:06:00'), sys: 122, dia: 80, puls: 78, bewegung: false, arrhythmie: false),
      _m(484, DateTime.parse('2026-08-11T07:25:00'), sys: 131, dia: 85, puls: 84, bewegung: false, arrhythmie: false),
      _m(485, DateTime.parse('2026-08-11T20:04:00'), sys: 123, dia: 80, puls: 80, bewegung: false, arrhythmie: false),
      _m(486, DateTime.parse('2026-08-12T07:36:00'), sys: 132, dia: 89, puls: 86, bewegung: false, arrhythmie: false),
      _m(487, DateTime.parse('2026-08-12T20:45:00'), sys: 128, dia: 81, puls: 81, bewegung: false, arrhythmie: false),
      _m(488, DateTime.parse('2026-08-13T07:05:00'), sys: 131, dia: 89, puls: 77, bewegung: false, arrhythmie: false),
      _m(489, DateTime.parse('2026-08-13T20:26:00'), sys: 123, dia: 80, puls: 77, bewegung: false, arrhythmie: false),
      _m(490, DateTime.parse('2026-08-14T07:07:00'), sys: 135, dia: 85, puls: 78, bewegung: false, arrhythmie: false),
      _m(491, DateTime.parse('2026-08-14T20:42:00'), sys: 125, dia: 83, puls: 83, bewegung: false, arrhythmie: false),
      _m(492, DateTime.parse('2026-08-15T07:32:00'), sys: 135, dia: 85, puls: 81, bewegung: false, arrhythmie: false),
      _m(493, DateTime.parse('2026-08-15T20:45:00'), sys: 120, dia: 83, puls: 82, bewegung: false, arrhythmie: false),
      _m(494, DateTime.parse('2026-08-16T07:24:00'), sys: 135, dia: 88, puls: 78, bewegung: false, arrhythmie: false),
      _m(495, DateTime.parse('2026-08-16T20:04:00'), sys: 121, dia: 80, puls: 86, bewegung: false, arrhythmie: false),
      _m(496, DateTime.parse('2026-08-17T07:45:00'), sys: 129, dia: 86, puls: 76, bewegung: false, arrhythmie: false),
      _m(497, DateTime.parse('2026-08-17T20:16:00'), sys: 123, dia: 79, puls: 76, bewegung: false, arrhythmie: false),
      _m(498, DateTime.parse('2026-08-18T07:17:00'), sys: 129, dia: 83, puls: 86, bewegung: false, arrhythmie: false),
      _m(499, DateTime.parse('2026-08-18T20:01:00'), sys: 127, dia: 79, puls: 76, bewegung: false, arrhythmie: false),
      _m(500, DateTime.parse('2026-08-19T07:08:00'), sys: 129, dia: 86, puls: 82, bewegung: false, arrhythmie: false),
      _m(501, DateTime.parse('2026-08-19T20:03:00'), sys: 119, dia: 81, puls: 79, bewegung: false, arrhythmie: false),
      _m(502, DateTime.parse('2026-08-20T07:20:00'), sys: 135, dia: 86, puls: 83, bewegung: false, arrhythmie: false),
      _m(503, DateTime.parse('2026-08-20T20:22:00'), sys: 128, dia: 84, puls: 77, bewegung: true, arrhythmie: false),
      _m(504, DateTime.parse('2026-08-21T07:09:00'), sys: 136, dia: 85, puls: 84, bewegung: false, arrhythmie: false),
      _m(505, DateTime.parse('2026-08-21T20:10:00'), sys: 128, dia: 78, puls: 86, bewegung: false, arrhythmie: false),
      _m(506, DateTime.parse('2026-08-22T07:06:00'), sys: 131, dia: 89, puls: 77, bewegung: false, arrhythmie: false),
      _m(507, DateTime.parse('2026-08-22T20:01:00'), sys: 124, dia: 83, puls: 82, bewegung: false, arrhythmie: false),
      _m(508, DateTime.parse('2026-08-23T07:20:00'), sys: 131, dia: 87, puls: 76, bewegung: false, arrhythmie: false),
      _m(509, DateTime.parse('2026-08-23T20:06:00'), sys: 118, dia: 78, puls: 83, bewegung: false, arrhythmie: true),
      _m(510, DateTime.parse('2026-08-24T07:06:00'), sys: 130, dia: 84, puls: 78, bewegung: true, arrhythmie: false),
      _m(511, DateTime.parse('2026-08-24T20:13:00'), sys: 119, dia: 83, puls: 77, bewegung: true, arrhythmie: false),
      _m(512, DateTime.parse('2026-08-25T07:00:00'), sys: 137, dia: 88, puls: 85, bewegung: false, arrhythmie: false),
      _m(513, DateTime.parse('2026-08-25T20:01:00'), sys: 124, dia: 79, puls: 84, bewegung: false, arrhythmie: false),
      _m(514, DateTime.parse('2026-08-26T07:15:00'), sys: 137, dia: 86, puls: 76, bewegung: false, arrhythmie: false),
      _m(515, DateTime.parse('2026-08-26T20:22:00'), sys: 128, dia: 79, puls: 78, bewegung: false, arrhythmie: false),
      _m(516, DateTime.parse('2026-08-27T07:11:00'), sys: 133, dia: 89, puls: 77, bewegung: false, arrhythmie: true),
      _m(517, DateTime.parse('2026-08-27T20:22:00'), sys: 125, dia: 79, puls: 78, bewegung: false, arrhythmie: false),
      _m(518, DateTime.parse('2026-08-28T07:10:00'), sys: 136, dia: 86, puls: 85, bewegung: true, arrhythmie: false),
      _m(519, DateTime.parse('2026-08-28T20:03:00'), sys: 127, dia: 82, puls: 79, bewegung: false, arrhythmie: false),
      _m(520, DateTime.parse('2026-08-29T07:42:00'), sys: 138, dia: 86, puls: 86, bewegung: false, arrhythmie: false),
      _m(521, DateTime.parse('2026-08-29T20:39:00'), sys: 125, dia: 79, puls: 83, bewegung: false, arrhythmie: false),
      _m(522, DateTime.parse('2026-08-30T07:19:00'), sys: 134, dia: 87, puls: 83, bewegung: false, arrhythmie: false),
      _m(523, DateTime.parse('2026-08-30T20:26:00'), sys: 120, dia: 86, puls: 80, bewegung: false, arrhythmie: false),
      _m(524, DateTime.parse('2026-08-31T07:27:00'), sys: 131, dia: 88, puls: 81, bewegung: false, arrhythmie: false),
      _m(525, DateTime.parse('2026-08-31T07:29:00'), sys: 130, dia: 85, puls: 80, bewegung: false, arrhythmie: false),
      _m(526, DateTime.parse('2026-08-31T20:45:00'), sys: 115, dia: 82, puls: 79, bewegung: false, arrhythmie: true),
      _m(527, DateTime.parse('2026-08-31T20:47:00'), sys: 121, dia: 81, puls: 84, bewegung: false, arrhythmie: false),
      _m(528, DateTime.parse('2026-09-01T07:26:00'), sys: 128, dia: 92, puls: 80, bewegung: false, arrhythmie: false),
      _m(529, DateTime.parse('2026-09-01T07:28:00'), sys: 126, dia: 86, puls: 85, bewegung: false, arrhythmie: false),
      _m(530, DateTime.parse('2026-09-01T20:40:00'), sys: 115, dia: 84, puls: 82, bewegung: false, arrhythmie: false),
      _m(531, DateTime.parse('2026-09-01T20:42:00'), sys: 114, dia: 85, puls: 77, bewegung: false, arrhythmie: false),
      _m(532, DateTime.parse('2026-09-02T07:33:00'), sys: 131, dia: 85, puls: 81, bewegung: false, arrhythmie: false),
      _m(533, DateTime.parse('2026-09-02T20:17:00'), sys: 121, dia: 80, puls: 84, bewegung: false, arrhythmie: false),
      _m(534, DateTime.parse('2026-09-03T07:41:00'), sys: 128, dia: 89, puls: 77, bewegung: false, arrhythmie: false),
      _m(535, DateTime.parse('2026-09-03T20:21:00'), sys: 124, dia: 81, puls: 84, bewegung: false, arrhythmie: false),
      _m(536, DateTime.parse('2026-09-04T20:43:00'), sys: 123, dia: 82, puls: 77, bewegung: false, arrhythmie: false),
      _m(537, DateTime.parse('2026-09-04T20:45:00'), sys: 120, dia: 83, puls: 82, bewegung: false, arrhythmie: false),
      _m(538, DateTime.parse('2023-04-18T11:02:00'), sys: 133, dia: 91, puls: 78, bewegung: false, arrhythmie: false),
      _m(539, DateTime.parse('2023-04-18T11:05:00'), sys: 129, dia: 88, puls: 81, bewegung: false, arrhythmie: false),
      _m(540, DateTime.parse('2023-04-18T11:08:00'), sys: 136, dia: 92, puls: 75, bewegung: false, arrhythmie: true),
      _m(541, DateTime.parse('2026-09-05T23:55:00'), sys: 123, dia: 87, puls: 81, bewegung: false, arrhythmie: false),
      _m(542, DateTime.parse('2026-09-05T23:57:00'), sys: 128, dia: 87, puls: 82, bewegung: false, arrhythmie: false),  ];

  test('bildet aus 114 Rohmessungen 89 Anlässe', () {
    expect(proposeOccasions(bestand), hasLength(89));
  });

  test('jede Rohmessung gehört zu genau einem Anlass', () {
    final anlaesse = proposeOccasions(bestand);
    final nummern = [
      for (final a in anlaesse)
        for (final m in a.measurements) m.deviceSequence,
    ];

    expect(nummern, hasLength(114));
    expect(nummern.toSet(), hasLength(114));
  });

  test('der letzte Anlass fasst die Messungen 541 und 542 zusammen', () {
    final letzter = proposeOccasions(bestand).last;

    expect(letzter.measurements.map((m) => m.deviceSequence), [541, 542]);
    expect(letzter.result.systolic, 126, reason: '(123 + 128) / 2');
  });

  test('jedes Ergebnis nennt seine Regel', () {
    for (final a in proposeOccasions(bestand)) {
      expect(a.rule, isNotEmpty, reason: 'Anlass ${a.sequence}');
    }
  });
}
