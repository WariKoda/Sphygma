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
                    "und schreibt sie in Health Connect.\n\n" +
                    "• Es werden ausschließlich Blutdruck (systolisch/diastolisch) " +
                    "und Puls geschrieben.\n" +
                    "• Sphygma liest keine Daten aus Health Connect.\n" +
                    "• Die Daten verlassen dein Gerät nicht; es gibt keinen Server " +
                    "und keine Konten.\n" +
                    "• Du kannst die Berechtigung jederzeit in Health Connect entziehen."
            )
        }
        setContentView(ScrollView(this).apply { addView(text) })
    }
}
