package de.bdgraue.sphygma

import android.app.Activity
import android.os.Bundle
import android.widget.ScrollView
import android.widget.TextView

/**
 * Von Health Connect geoeffnet, wenn der Nutzer wissen will, wofuer Sphygma
 * die Gesundheitsdaten nutzt (ACTION_SHOW_PERMISSIONS_RATIONALE bzw.
 * VIEW_PERMISSION_USAGE). Muss inhaltlich zur Datenschutzerklaerung im
 * Play-Store-Eintrag passen (PLAN.md §3.3, M7).
 */
class PermissionsRationaleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val text = TextView(this).apply {
            val pad = (16 * resources.displayMetrics.density).toInt()
            setPadding(pad, pad, pad, pad)
            textSize = 16f
            setText(
                "Sphygma liest Blutdruck und Puls aus deinem Omron-Messgerät " +
                    "und speichert Messwerte, Einstellungen, Tags, Bemerkungen, Phasen, " +
                    "Messpläne und deine " +
                    "Zuordnungsentscheidungen lokal auf deinem Telefon.\n\n" +
                    "• Es werden ausschließlich Blutdruck (systolisch/diastolisch) " +
                    "und Puls geschrieben.\n" +
                    "• Mit deiner Schreibberechtigung kannst du Messungen einzeln " +
                    "oder gesammelt nach Health Connect übertragen. Bei eingeschaltetem " +
                    "Autoexport werden neue übernommene Messungen nach einem " +
                    "erfolgreichen Abgleich automatisch übertragen.\n" +
                    "• Sphygma liest keine Daten aus Health Connect.\n" +
                    "• Ein aktivierter Messplan erinnert lokal über Android. Die " +
                    "Benachrichtigung nennt den Speicherplatz, keine Messwerte. " +
                    "Die Sperrbildschirm-Anzeige richtet sich nach deinen " +
                    "Android-Einstellungen. Das Abschalten des Messplans " +
                    "stoppt auch seine Erinnerungen.\n" +
                    "• Sphygma hat keinen Server und keine Konten. Android-Cloud-Backup " +
                    "und automatischer Android-Gerätetransfer der App-Daten sind " +
                    "ausgeschlossen, auch für den Pairing-Schlüssel.\n" +
                    "• Es gibt keine eigene Backupfunktion. Bei Verlust des Telefons " +
                    "oder Löschen der App gehen die lokalen Daten verloren; " +
                    "nach einer Neuinstallation musst du das Messgerät neu koppeln.\n" +
                    "• Bereits exportierte Daten bleiben in Health Connect. Vor dem " +
                    "Löschen der App kannst du sie über Sphygma zurückziehen; danach " +
                    "löschst du sie in Health Connect. Dort kannst du die " +
                    "Berechtigung jederzeit entziehen."
            )
        }
        setContentView(ScrollView(this).apply { addView(text) })
    }
}
