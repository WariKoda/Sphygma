package de.bdgraue.sphygma.reminders

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.time.Instant

class ReminderStore(context: Context) : SnapshotStore {
    private val preferences = context.getSharedPreferences("sphygma_reminders", Context.MODE_PRIVATE)
    override fun save(state: ReminderState) {
        val map = mapOf("storeVersion" to 2, "desired" to state.desired.json(), "applied" to state.applied,
            "pending" to state.pending.values.map { it.json() }, "delivered" to state.delivered.toList(),
            "occurrences" to state.occurrences.values.map { it.json() }, "events" to state.events.map { it.json() },
            "retiredOccurrenceKeys" to state.retiredOccurrenceKeys.toList(),
            "lastCheck" to state.lastCheck?.toString(), "zone" to state.zone, "error" to state.error)
        check(preferences.edit().putString("state", JSONObject(map).toString()).commit()) {
            "Erinnerungszustand konnte nicht dauerhaft gespeichert werden"
        }
    }
    override fun load(): ReminderState {
        val raw = preferences.getString("state", null) ?: return ReminderState()
        val map = decode(JSONObject(raw)) as Map<*, *>
        val version = map.number("storeVersion")
        require(version in 1L..2L) { "Unbekannte Erinnerungsspeicherversion" }
        fun occurrences(name: String) = (map[name] as List<*>).map { Occurrence.parse(it as Map<*, *>) }
        return ReminderState(ReminderSnapshot.parse(map["desired"] as Map<*, *>),
            (map["applied"] as Number?)?.toLong(), occurrences("pending").associateBy { it.identity },
            map.strings("delivered"), occurrences("occurrences").associateBy { it.key },
            (map["events"] as List<*>).map { value ->
                val event = value as Map<*, *>
                TimeChange(event["eventId"] as String, Instant.parse(event["occurredAtUtc"] as String),
                    event["oldZoneId"] as String?, event["newZoneId"] as String)
            }, (map["lastCheck"] as String?)?.let(Instant::parse), map["zone"] as String?, map["error"] as String?,
            if (version == 1L) emptySet() else map.strings("retiredOccurrenceKeys"))
    }
    private fun decode(value: Any?): Any? = when (value) {
        JSONObject.NULL -> null
        is JSONObject -> value.keys().asSequence().associateWith { decode(value.get(it)) }
        is JSONArray -> (0 until value.length()).map { decode(value.get(it)) }
        else -> value
    }
}
