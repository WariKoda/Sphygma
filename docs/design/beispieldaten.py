"""Erzeugt den verbindlichen Beispieldatensatz für die Konzeptentwürfe.

Alle Entwurfstafeln zeigen dieselben 114 Messungen. Ohne das laufen die
Zahlen zwischen den Dateien auseinander — genau das ist passiert.
"""
import random, json, datetime as dt
from pathlib import Path

random.seed(4711)
JETZT = dt.datetime(2026, 9, 5, 23, 59)

mess = []


def add(z, s, d, p, bew=False, arr=False):
    mess.append([z, s, d, p, bew, arr])


def block(von, bis, sb, db, pb, dichte, doppel, luecken=True):
    """Morgens liegt der Druck hoeher als abends — das ist der Normalfall und
    die Grundlage des Konzepts "Tagesprofil". Ohne luecken=False entstehen
    Tage ohne Messung, was "Sieben Tage" braucht, um unvollstaendige Wochen
    zeigen zu koennen."""
    tag = von
    while tag < bis:
        if random.random() < dichte:
            for stunde, versatz in ((7, 8), (20, -3)):
                if (not luecken) or random.random() < 0.82:
                    n = 2 if random.random() < doppel else 1
                    m = random.randint(0, 45)
                    for k in range(n):
                        add(tag.replace(hour=stunde, minute=m) + dt.timedelta(minutes=k * 2),
                            sb + versatz + random.randint(-5, 5) - k * 2,
                            db + (versatz + 1) // 2 + random.randint(-3, 3) - k,
                            pb + random.randint(-5, 5),
                            bew=(random.random() < 0.07),
                            arr=(random.random() < 0.04))
        tag += dt.timedelta(days=1)


# Phase "Ohne Medikament", höhere Werte
block(dt.datetime(2026, 5, 12), dt.datetime(2026, 8, 10), 133, 88, 84, 0.62, 0.45)
# Phase "Ramipril 5 mg", niedriger und dichter
# Drei lueckenlos gemessene Wochen: 10.08.–30.08., Montag bis Sonntag
block(dt.datetime(2026, 8, 10), dt.datetime(2026, 8, 31), 126, 82, 81, 1.0, 0.0, luecken=False)
# Die laufende Woche, dicht aber nicht vollstaendig
block(dt.datetime(2026, 8, 31), dt.datetime(2026, 9, 5), 126, 82, 81, 0.95, 0.55)

# Der letzte Messanlass: zwei Messungen, zwei Minuten auseinander
add(dt.datetime(2026, 9, 5, 23, 55), 126, 85, 81)
add(dt.datetime(2026, 9, 5, 23, 57), 128, 87, 82)

# Auf 111 kürzen, damit mit den drei falsch datierten genau 114 herauskommen.
# Fail hard: Zu wenige Messungen dürfen nicht stillschweigend zu einem
# negativen Index werden — genau das hat vorher drei statt 111 geliefert.
if len(mess) < 111:
    raise SystemExit(f'nur {len(mess)} Messungen erzeugt, 111 gebraucht — Dichte erhöhen')
mess = mess[-111:]

# Drei Messungen, die das Gerät mit falsch gestellter Uhr auf 2023 datiert hat.
# Sie wurden zuletzt eingelesen — die Gerätenummer beweist es, das Datum lügt.
alt = dt.datetime(2023, 4, 18, 11, 2)
falsch = [
    [alt, 133, 91, 78, False, False],
    [alt + dt.timedelta(minutes=3), 129, 88, 81, False, False],
    [alt + dt.timedelta(minutes=6), 136, 92, 75, False, True],
]
mess = mess[:-2] + falsch + mess[-2:]

# Gerätenummern in Einlesereihenfolge, lückenlos
for i, m in enumerate(mess):
    m.insert(0, 429 + i)

letzte = mess[-1]

# Den Wochenschnitt exakt auf die belegten 124/85 ziehen
for idx, ziel in ((2, 124), (3, 85)):
    woche = [m for m in mess if m[1] >= JETZT - dt.timedelta(days=7)]
    diff = round(ziel * len(woche) - sum(m[idx] for m in woche))
    kand = [m for m in woche if m is not letzte]
    for k in range(abs(diff)):
        kand[k % len(kand)][idx] += 1 if diff > 0 else -1

# Die ältesten 14 gelten als nach Health Connect übertragen
for m in mess[:14]:
    m.append(True)
for m in mess[14:]:
    m.append(False)

# Neben das Skript, nicht nach /tmp: Wer Zahlen ändert, soll die alte und
# die neue Fassung nebeneinander sehen können. In /tmp ist die Datei nach dem
# nächsten Neustart weg, unter Windows gibt es den Pfad gar nicht.
ZIEL = Path(__file__).with_name('beispieldaten.json')
with ZIEL.open('w', encoding='utf-8') as f:
    json.dump([[m[0], m[1].isoformat()] + m[2:] for m in mess], f,
              ensure_ascii=False, indent=1)


def mit(ms, i):
    return sum(m[i] for m in ms) / len(ms)


woche = [m for m in mess if m[1] >= JETZT - dt.timedelta(days=7)]
z26 = [m for m in mess if m[1].year == 2026]
print(f'{len(mess)} Messungen, Nr. {mess[0][0]}–{mess[-1][0]}')
print(f'letzte Woche: {len(woche)} Messungen, Mittel {mit(woche,2):.2f}/{mit(woche,3):.2f}, Puls {mit(woche,4):.1f}')
print(f'letzte: Nr. {letzte[0]} · {letzte[1]:%d.%m.%Y %H:%M} · {letzte[2]}/{letzte[3]} Puls {letzte[4]}')
print(f'übertragen: {sum(1 for m in mess if m[7])} · offen: {sum(1 for m in mess if not m[7])}')
print(f'2026 zeitlich monoton: {all(z26[i][1] <= z26[i+1][1] for i in range(len(z26)-1))}')
print(f'Nummern monoton: {all(mess[i][0] < mess[i+1][0] for i in range(len(mess)-1))}')
print(f'Bewegung: {sum(1 for m in mess if m[5])} · Arrhythmie: {sum(1 for m in mess if m[6])}')
