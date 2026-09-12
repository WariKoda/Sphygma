package de.bdgraue.sphygma.reminders

import java.time.Clock
import java.time.Instant
import java.time.ZoneId
import java.util.UUID

/** All entry points are called on ReminderRuntime's single process executor. */
class ReminderScheduler(private val store: SnapshotStore, private val alarms: AlarmPort,
    private val notifications: NotificationPort, private val clock: Clock,
    private val zoneProvider: () -> ZoneId) {
    private var state = store.load()
    private fun persist(next: ReminderState) { store.save(next); state = next }

    fun replace(desired: ReminderSnapshot): Map<String, Any?> = guarded {
        require(desired.generation >= state.desired.generation) { "Veraltete Erinnerungsgeneration" }
        if (desired.generation == state.desired.generation && state.lastCheck != null) {
            require(desired.enabled == state.desired.enabled && desired.rules == state.desired.rules) {
                "Geänderte Planregeln benötigen eine neue Generation"
            }
        }
        // A durable new generation rejects queued old broadcasts before any OS mutation.
        val acknowledged = desired.copy(
            acknowledgedOccurrenceKeys = state.desired.acknowledgedOccurrenceKeys + desired.acknowledgedOccurrenceKeys,
            acknowledgedEventIds = state.desired.acknowledgedEventIds + desired.acknowledgedEventIds)
        persist(state.copy(desired = acknowledged, applied = null, error = null,
            occurrences = if (state.events.all { it.eventId in acknowledged.acknowledgedEventIds })
                state.occurrences - desired.acknowledgedOccurrenceKeys else state.occurrences,
            retiredOccurrenceKeys = if (state.events.all { it.eventId in acknowledged.acknowledgedEventIds })
                emptySet() else state.retiredOccurrenceKeys,
            events = state.events.filterNot { it.eventId in desired.acknowledgedEventIds }))
        reconcile()
    }

    fun inspect(timeChanged: Boolean = false, resetAlarms: Boolean = false): Map<String, Any?> = guarded { reconcile(timeChanged, resetAlarms) }

    fun deliver(generation: Long, key: String): Map<String, Any?> = guarded {
        if (generation != state.desired.generation || !state.desired.enabled || key in state.delivered) return@guarded
        val occurrence = state.pending.values.singleOrNull { it.key == key } ?: return@guarded
        if (occurrence.dueAt == null || occurrence.dueAt > clock.instant()) return@guarded
        val permission = notifications.permissions()
        if (key !in state.desired.fulfilledKeys && permission.notificationsAllowed && !permission.channelBlocked) {
            // Claim before posting: a crash cannot produce a second notification. A crash between
            // claim and post may lose delivery; OS notification publication is not transactional.
            persist(state.copy(delivered = state.delivered + key, applied = null))
            notifications.post(occurrence)
        }
        reconcile()
    }

    private fun reconcile(timeChanged: Boolean = false, resetAlarms: Boolean = false) {
        val now = clock.instant()
        val zone = zoneProvider()
        val changed = timeChanged || (state.zone != null && state.zone != zone.id)
        if (changed) persist(state.copy(events = state.events + TimeChange(UUID.randomUUID().toString(), now, state.zone, zone.id)))
        val rulesByRevision = state.desired.rules.associateBy { it.revisionId }
        // A new revision can supersede receipts that Drift never acknowledged. They
        // must not resurrect discarded future terms under the new generation.
        val receipts = state.occurrences.filterValues { occurrence ->
            val rule = rulesByRevision[occurrence.revisionId]
            rule != null && occurrence.minute in rule.minutesOfDay &&
                (occurrence.dueAt == null || (occurrence.dueAt >= rule.effectiveAt &&
                    (rule.endsAt == null || occurrence.dueAt < rule.endsAt)))
        }.toMutableMap()
        val consumed = state.delivered.toMutableSet()
        val retired = state.retiredOccurrenceKeys.toMutableSet()
        val previousZone = state.zone?.let(ZoneId::of)
        val candidates = mutableListOf<Occurrence>()
        for (rule in state.desired.rules) {
            // Without a continuous known zone, historical civil dates are retained as ambiguous.
            val historyZone = if (!changed && state.zone == zone.id) zone else null
            val startDay = (state.lastCheck ?: rule.effectiveAt).atZone(zone).toLocalDate()
                .coerceAtLeast(rule.effectiveAt.atZone(zone).toLocalDate())
            val today = now.atZone(zone).toLocalDate()
            var day = startDay.coerceAtMost(today)
            val through = today.plusDays(1)
            while (!day.isAfter(through)) {
                for (minute in rule.minutesOfDay) {
                    val concrete = Occurrence.create(rule, day, minute, zone)
                    val due = concrete.dueAt!!
                    val previous = if (changed && previousZone != null)
                        Occurrence.create(rule, day, minute, previousZone) else null
                    if (due < rule.effectiveAt || (rule.endsAt != null && due >= rule.endsAt)) {
                        if (changed && previous?.dueAt?.let { it > now } == true &&
                            (concrete.key in state.desired.acknowledgedOccurrenceKeys ||
                                concrete.key in state.occurrences || state.pending.values.any { it.key == concrete.key })) {
                            retired.add(concrete.key)
                            receipts.remove(concrete.key)
                        }
                        continue
                    }
                    val previousOutsideRule = previous?.dueAt?.let { it < rule.effectiveAt || (rule.endsAt != null && it >= rule.endsAt) } == true
                    val reappeared = retired.remove(concrete.key)
                    if (reappeared) consumed.remove(concrete.key)
                    // Clock/zone changes must not turn a historical local term back
                    // into a fresh notification. This claim also survives later inspect.
                    if (!reappeared && previous?.dueAt != null && previous.dueAt <= now && previous.dueAt >= rule.effectiveAt) consumed.add(concrete.key)
                    val occurrence = if (due < now && historyZone == null && concrete.key !in receipts)
                        Occurrence.create(rule, day, minute, null) else concrete
                    if (reappeared || (changed && ((previousOutsideRule && due > now) || (previous?.dueAt?.let { it > now } ?: (due > now))))) {
                        receipts[concrete.key] = concrete
                    } else if (concrete.key !in state.desired.acknowledgedOccurrenceKeys && concrete.key !in receipts)
                        receipts[concrete.key] = occurrence
                    if (state.desired.enabled && due > now && concrete.key !in consumed && concrete.key !in state.desired.fulfilledKeys)
                        candidates.add(concrete)
                }
                day = day.plusDays(1)
            }
        }
        // An already armed inexact alarm can still be awaiting its OS broadcast
        // after dueAt. Ordinary app reconciliation must not silently replace it
        // with tomorrow. Lifecycle resets intentionally never replay old alarms.
        if (state.desired.enabled && !changed && !resetAlarms) {
            for (occurrence in state.pending.values) {
                val rule = rulesByRevision[occurrence.revisionId] ?: continue
                if (occurrence.dueAt != null && occurrence.dueAt <= now &&
                    occurrence.minute in rule.minutesOfDay &&
                    occurrence.dueAt >= rule.effectiveAt && (rule.endsAt == null || now < rule.endsAt) &&
                    occurrence.key !in consumed && occurrence.key !in state.desired.fulfilledKeys) {
                    candidates.add(occurrence)
                }
            }
        }
        val permission = notifications.permissions()
        val target = if (!permission.notificationsAllowed || permission.channelBlocked) emptyMap()
            else candidates.groupBy { it.identity }.mapValues { (_, values) -> values.minBy { it.dueAt!! } }
        // Journal the union BEFORE cancel/schedule; process death never loses an OS identity.
        persist(state.copy(applied = null, occurrences = receipts, delivered = consumed, retiredOccurrenceKeys = retired, pending = state.pending + target, error = null))
        for (identity in state.pending.keys.toList()) alarms.cancel(identity)
        for (occurrence in target.values) {
            if (alarms.exactAllowed()) {
                try { alarms.scheduleExact(occurrence, state.desired.generation) }
                catch (error: SecurityException) {
                    if (alarms.exactAllowed()) throw error
                    alarms.scheduleInexact(occurrence, state.desired.generation)
                }
            } else alarms.scheduleInexact(occurrence, state.desired.generation)
        }
        persist(state.copy(applied = state.desired.generation, pending = target, lastCheck = now, zone = zone.id, error = null))
    }

    private fun guarded(action: () -> Unit): Map<String, Any?> {
        var failure: String? = null
        try { action() } catch (error: Exception) {
            failure = error.message ?: error.javaClass.simpleName
            try { persist(state.copy(applied = null, error = failure)) }
            catch (persistError: Exception) { failure += "; Speichern: ${persistError.message}" }
        }
        val permission = notifications.permissions()
        val error = failure ?: state.error
        val mode = when {
            error != null -> "failed"
            !state.desired.enabled -> "off"
            !permission.notificationsAllowed || permission.channelBlocked -> "blocked"
            alarms.exactAllowed() -> "exact"
            else -> "inexact"
        }
        return mapOf("protocolVersion" to 1, "generation" to state.desired.generation,
            "appliedGeneration" to if (error == null) state.applied else null, "mode" to mode,
            "notificationsAllowed" to permission.notificationsAllowed, "exactAllowed" to alarms.exactAllowed(),
            "channelBlocked" to permission.channelBlocked, "pendingOccurrenceKeys" to state.pending.values.map { it.key },
            "retiredOccurrenceKeys" to state.retiredOccurrenceKeys.toList(),
            "occurrences" to state.occurrences.values.map { it.json() }, "timeChanges" to state.events.map { it.json() },
            "error" to error, "openPlanRequested" to false)
    }
}
