package de.bdgraue.sphygma.reminders

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

internal fun Map<*, *>.number(key: String): Long = when (val value = get(key)) {
    is Int -> value.toLong()
    is Long -> value
    else -> error("Ganzzahl fehlt: $key")
}
internal fun Map<*, *>.strings(key: String): Set<String> =
    (get(key) as? List<*>)?.map { it as String }?.toSet() ?: error("Pflichtliste fehlt: $key")

data class ReminderRule(val planId: Long, val revisionId: Long, val userSlot: Int,
    val minutesOfDay: List<Int>, val effectiveAt: Instant, val endsAt: Instant?) {
    init {
        require(planId > 0 && revisionId > 0 && userSlot in 1..2)
        require(minutesOfDay.isNotEmpty() && minutesOfDay == minutesOfDay.distinct().sorted())
        require(minutesOfDay.all { it in 0..1439 })
        require(endsAt == null || endsAt >= effectiveAt)
    }
    fun identity(minute: Int) = "$userSlot/$revisionId/$minute"
    fun json(): Map<String, Any?> = mapOf("planId" to planId, "revisionId" to revisionId,
        "userSlot" to userSlot, "minutesOfDay" to minutesOfDay,
        "effectiveAtUtc" to effectiveAt.toString(), "endsAtUtc" to endsAt?.toString())
    companion object {
        fun parse(m: Map<*, *>) = ReminderRule(m.number("planId"), m.number("revisionId"),
            m.number("userSlot").toInt(), (m["minutesOfDay"] as List<*>).map { (it as Number).toInt() },
            Instant.parse(m["effectiveAtUtc"] as String), (m["endsAtUtc"] as String?)?.let(Instant::parse))
    }
}

data class ReminderSnapshot(val generation: Long, val enabled: Boolean, val rules: List<ReminderRule>,
    val fulfilledKeys: Set<String>, val acknowledgedOccurrenceKeys: Set<String>, val acknowledgedEventIds: Set<String>) {
    init { require(generation >= 0); require(rules.map { it.revisionId }.distinct().size == rules.size) }
    fun json(): Map<String, Any?> = mapOf("protocolVersion" to 1, "generation" to generation,
        "enabled" to enabled, "rules" to rules.map { it.json() }, "fulfilledKeys" to fulfilledKeys.toList(),
        "acknowledgedOccurrenceKeys" to acknowledgedOccurrenceKeys.toList(), "acknowledgedEventIds" to acknowledgedEventIds.toList())
    companion object {
        fun empty() = ReminderSnapshot(0, false, emptyList(), emptySet(), emptySet(), emptySet())
        fun parse(m: Map<*, *>): ReminderSnapshot {
            require(m.number("protocolVersion") == 1L) { "Unbekanntes Erinnerungsprotokoll" }
            return ReminderSnapshot(m.number("generation"), m["enabled"] as Boolean,
                (m["rules"] as List<*>).map { ReminderRule.parse(it as Map<*, *>) },
                m.strings("fulfilledKeys"), m.strings("acknowledgedOccurrenceKeys"), m.strings("acknowledgedEventIds"))
        }
    }
}

data class Occurrence(val key: String, val identity: String, val userSlot: Int, val revisionId: Long,
    val dueAt: Instant?, val localDate: LocalDate, val minute: Int, val zoneId: String?, val ambiguous: Boolean) {
    fun json(): Map<String, Any?> = mapOf("key" to key, "identity" to identity,
        "userSlot" to userSlot, "revisionId" to revisionId, "dueAt" to dueAt?.toString(),
        "localDate" to localDate.toString(), "minuteOfDay" to minute, "zoneId" to zoneId, "timeAmbiguous" to ambiguous)
    companion object {
        fun create(rule: ReminderRule, day: LocalDate, minute: Int, zone: ZoneId?): Occurrence {
            val local = day.atStartOfDay().plusMinutes(minute.toLong())
            val offsets = zone?.rules?.getValidOffsets(local)
            val due = if (zone == null) null else if (offsets!!.isEmpty())
                zone.rules.getTransition(local)!!.dateTimeAfter.atZone(zone).toInstant()
            else local.atOffset(offsets.first()).toInstant()
            return Occurrence("${rule.userSlot}:${rule.revisionId}:$day:$minute", rule.identity(minute),
                rule.userSlot, rule.revisionId, due, day, minute, zone?.id, zone == null || offsets!!.size != 1)
        }
        fun parse(m: Map<*, *>) = Occurrence(m["key"] as String, m["identity"] as String,
            m.number("userSlot").toInt(), m.number("revisionId"), (m["dueAt"] as String?)?.let(Instant::parse),
            LocalDate.parse(m["localDate"] as String), m.number("minuteOfDay").toInt(), m["zoneId"] as String?, m["timeAmbiguous"] as Boolean)
    }
}

data class TimeChange(val eventId: String, val occurredAt: Instant, val oldZone: String?, val newZone: String) {
    fun json(): Map<String, Any?> = mapOf("eventId" to eventId, "occurredAtUtc" to occurredAt.toString(),
        "oldZoneId" to oldZone, "newZoneId" to newZone)
}

data class ReminderState(val desired: ReminderSnapshot = ReminderSnapshot.empty(), val applied: Long? = null,
    val pending: Map<String, Occurrence> = emptyMap(), val delivered: Set<String> = emptySet(),
    val occurrences: Map<String, Occurrence> = emptyMap(), val events: List<TimeChange> = emptyList(),
    val lastCheck: Instant? = null, val zone: String? = null, val error: String? = null,
    val retiredOccurrenceKeys: Set<String> = emptySet())

data class Permissions(val notificationsAllowed: Boolean, val exactAllowed: Boolean, val channelBlocked: Boolean)
interface AlarmPort {
    fun exactAllowed(): Boolean
    fun scheduleExact(occurrence: Occurrence, generation: Long)
    fun scheduleInexact(occurrence: Occurrence, generation: Long)
    fun cancel(identity: String)
}
interface NotificationPort {
    fun permissions(): Permissions
    fun post(occurrence: Occurrence)
}
interface SnapshotStore { fun load(): ReminderState; fun save(state: ReminderState) }
