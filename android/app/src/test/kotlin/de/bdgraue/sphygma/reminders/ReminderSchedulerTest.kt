package de.bdgraue.sphygma.reminders

import org.junit.Assert.*
import org.junit.Test
import java.time.*

class ReminderSchedulerTest {
    private class Memory : SnapshotStore {
        var state = ReminderState()
        var fail = false
        override fun load() = state
        override fun save(state: ReminderState) { check(!fail) { "disk" }; this.state = state }
    }
    private class Ports : AlarmPort, NotificationPort {
        var exact = true; var allowed = true; var blocked = false
        var schedules = 0; var posts = 0; var cancels = 0; var fail = false
        var securityFailure = false; var revokeOnSchedule = false
        override fun exactAllowed() = exact
        override fun scheduleExact(occurrence: Occurrence, generation: Long) {
            check(!fail)
            if (revokeOnSchedule) exact = false
            if (securityFailure || revokeOnSchedule) throw SecurityException("exact")
            schedules++
        }
        override fun scheduleInexact(occurrence: Occurrence, generation: Long) { check(!fail); schedules-- }
        override fun cancel(identity: String) { check(!fail); cancels++ }
        override fun permissions() = Permissions(allowed, exact, blocked)
        override fun post(occurrence: Occurrence) { posts++ }
    }
    private val now = Instant.parse("2026-09-11T05:00:00Z")
    private val rule = ReminderRule(1, 1, 1, listOf(480), now, null)
    private fun desired(enabled: Boolean = true, generation: Long = 1) = ReminderSnapshot(generation, enabled, listOf(rule), emptySet(), emptySet(), emptySet())
    private fun scheduler(m: Memory, p: Ports, instant: Instant = now) = ReminderScheduler(m, p, p, Clock.fixed(instant, ZoneOffset.UTC)) { ZoneId.of("Europe/Berlin") }
    @Test fun exactAndFallbackAndBlocked() {
        for (exact in listOf(true, false)) {
            val m = Memory(); val p = Ports(); p.exact = exact
            val result = scheduler(m, p).replace(desired())
            assertEquals(if (exact) "exact" else "inexact", result["mode"])
            assertEquals(if (exact) 1 else -1, p.schedules)
        }
        val m = Memory(); val p = Ports(); p.blocked = true
        assertEquals("blocked", scheduler(m, p).replace(desired())["mode"])
        assertEquals(0, p.schedules)
    }
    @Test fun partialFailureRetainsIdentityAndRetriesSameGeneration() {
        val m = Memory(); val p = Ports(); p.fail = true
        assertEquals("failed", scheduler(m, p).replace(desired())["mode"])
        assertNull(m.state.applied); assertEquals(1, m.state.pending.size)
        p.fail = false
        assertEquals("exact", scheduler(m, p).replace(desired())["mode"])
        assertEquals(1L, m.state.applied)
        assertEquals("off", scheduler(m, p).replace(desired(false, 2))["mode"])
        assertTrue(m.state.pending.isEmpty())
    }
    @Test fun oldAndDuplicateBroadcastsDoNotPost() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val occurrence = m.state.pending.values.single()
        val scheduler = scheduler(m, p, occurrence.dueAt!!)
        scheduler.deliver(0, occurrence.key)
        assertEquals(0, p.posts)
        scheduler.deliver(1, occurrence.key); scheduler.deliver(1, occurrence.key)
        assertEquals(1, p.posts)
        assertTrue(m.state.pending.values.single().localDate > occurrence.localDate)
    }
    @Test fun dstGapUsesFirstValidTimeAndOverlapEarlierInstance() {
        val zone = ZoneId.of("Europe/Berlin")
        assertEquals(Instant.parse("2026-03-29T01:00:00Z"), Occurrence.create(rule, LocalDate.parse("2026-03-29"), 150, zone).dueAt)
        assertEquals(Instant.parse("2026-10-25T00:30:00Z"), Occurrence.create(rule, LocalDate.parse("2026-10-25"), 150, zone).dueAt)
    }
    @Test fun acknowledgedReceiptsArePrunedAndUnacknowledgedSurviveRestart() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val keys = m.state.occurrences.keys
        assertEquals(keys, (scheduler(m, p).inspect()["occurrences"] as List<*>).map { (it as Map<*, *>)["key"] }.toSet())
        scheduler(m, p).replace(desired().copy(acknowledgedOccurrenceKeys = keys))
        assertTrue(m.state.occurrences.isEmpty())
    }
    @Test fun securityFailureFallsBackOnlyWhenPermissionWasRevoked() {
        val m = Memory(); val p = Ports(); p.securityFailure = true
        assertEquals("failed", scheduler(m, p).replace(desired())["mode"])
        assertEquals(0, p.schedules)
        p.revokeOnSchedule = true
        assertEquals("inexact", scheduler(m, p).replace(desired())["mode"])
        assertEquals(-1, p.schedules)
    }
    @Test fun fulfilledOccurrenceIsNotPostedOrScheduled() {
        val m = Memory(); val p = Ports()
        val key = Occurrence.create(rule, LocalDate.parse("2026-09-11"), 480, ZoneId.of("Europe/Berlin")).key
        scheduler(m, p).replace(desired().copy(fulfilledKeys = setOf(key)))
        assertEquals("2026-09-12", m.state.pending.values.single().localDate.toString())
        scheduler(m, p, now.plusSeconds(3600)).deliver(1, key)
        assertEquals(0, p.posts)
    }
    @Test fun restartReschedulesAndDisabledRestartStaysOff() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val before = p.schedules
        scheduler(m, p).inspect()
        assertEquals(before + 1, p.schedules)
        scheduler(m, p).replace(desired(false, 2))
        val disabled = p.schedules
        assertEquals("off", scheduler(m, p).inspect()["mode"])
        assertEquals(disabled, p.schedules)
    }
    @Test fun timeChangeReceiptSurvivesAndFutureUsesNewZone() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val changed = ReminderScheduler(m, p, p, Clock.fixed(now, ZoneOffset.UTC)) { ZoneId.of("Europe/London") }
        changed.inspect(true)
        assertEquals("Europe/Berlin", m.state.events.single().oldZone)
        assertEquals("Europe/London", m.state.pending.values.single().zoneId)
        assertEquals(Instant.parse("2026-09-11T07:00:00Z"), m.state.pending.values.single().dueAt)
        changed.inspect()
        assertEquals(1, m.state.events.size)
    }
    @Test fun historicalZoneIsNotInvented() {
        val m = Memory(); val p = Ports()
        scheduler(m, p).replace(desired().copy(rules = listOf(rule.copy(effectiveAt = now.minusSeconds(86400)))))
        val historic = m.state.occurrences.values.first { it.localDate.toString() == "2026-09-10" }
        assertNull(historic.dueAt); assertNull(historic.zoneId); assertTrue(historic.ambiguous)
    }
    @Test fun cancelFailureKeepsOffUnconfirmedAndRetryCancels() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        p.fail = true
        assertEquals("failed", scheduler(m, p).replace(desired(false, 2))["mode"])
        assertNull(m.state.applied); assertFalse(m.state.pending.isEmpty())
        p.fail = false
        assertEquals("off", scheduler(m, p).replace(desired(false, 2))["mode"])
        assertTrue(m.state.pending.isEmpty())
    }
    @Test fun persistenceFailureCannotReportApplied() {
        val m = Memory(); val p = Ports(); m.fail = true
        assertEquals("failed", scheduler(m, p).replace(desired())["mode"])
        assertEquals(0, p.schedules)
    }
    @Test fun newRevisionDropsUnacknowledgedSupersededFutureReceipts() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val changedAt = now.plusSeconds(1800)
        val replacement = rule.copy(revisionId = 2, minutesOfDay = listOf(600), effectiveAt = changedAt)
        scheduler(m, p, changedAt).replace(desired(generation = 2).copy(
            rules = listOf(rule.copy(endsAt = changedAt), replacement)))
        assertTrue(m.state.occurrences.values.none { it.revisionId == 1L })
        assertTrue(m.state.pending.values.all { it.revisionId == 2L })
    }
    @Test fun disabledAfterOfflineGapStillMaterializesEnabledHistory() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val disabledAt = now.plusSeconds(7 * 86400)
        scheduler(m, p, disabledAt).replace(desired(false, 2).copy(rules = listOf(rule.copy(endsAt = disabledAt))))
        assertTrue(m.state.pending.isEmpty())
        assertTrue(m.state.occurrences.values.any { it.localDate.toString() == "2026-09-15" })
        assertTrue(m.state.occurrences.values.none { it.dueAt!! >= disabledAt })
    }
    @Test fun eastwardZoneShiftUpdatesFormerFutureEvenWhenNewTimePassed() {
        val m = Memory(); val p = Ports()
        val snapshot = desired().copy(rules = listOf(rule.copy(effectiveAt = now.minusSeconds(86400))))
        scheduler(m, p).replace(snapshot)
        val key = m.state.pending.values.single().key
        scheduler(m, p).replace(snapshot.copy(acknowledgedOccurrenceKeys = m.state.occurrences.keys))
        val changed = ReminderScheduler(m, p, p, Clock.fixed(now, ZoneOffset.UTC)) { ZoneId.of("Asia/Tokyo") }
        changed.inspect(true)
        assertEquals("Asia/Tokyo", m.state.occurrences[key]!!.zoneId)
        assertTrue(m.state.occurrences[key]!!.dueAt!! < now)
        assertTrue(m.state.pending.values.none { it.key == key })
    }

    @Test fun westwardShiftNeverReopensPastLocalTermOnLaterInspect() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val oldKey = m.state.pending.values.single().key
        val changedNow = now.plusSeconds(7200)
        val changed = ReminderScheduler(m, p, p, Clock.fixed(changedNow, ZoneOffset.UTC)) { ZoneId.of("America/New_York") }
        changed.inspect(true)
        assertTrue(m.state.pending.values.none { it.key == oldKey })
        changed.inspect()
        assertTrue(m.state.pending.values.none { it.key == oldKey })
    }

    @Test fun zoneShiftBeforePlanStartRetiresAndAckCannotLoseRemoval() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val key = m.state.pending.values.single().key
        val keys = m.state.occurrences.keys
        scheduler(m, p).replace(desired().copy(acknowledgedOccurrenceKeys = keys))
        val changed = ReminderScheduler(m, p, p, Clock.fixed(now, ZoneOffset.UTC)) { ZoneId.of("Asia/Tokyo") }
        val receipt = changed.inspect(true)
        assertTrue((receipt["retiredOccurrenceKeys"] as List<*>).contains(key))
        assertFalse(m.state.occurrences.containsKey(key))
        val retried = changed.replace(desired().copy(acknowledgedOccurrenceKeys = keys))
        assertTrue((retried["retiredOccurrenceKeys"] as List<*>).contains(key))
        val events = m.state.events.map { it.eventId }.toSet()
        val acknowledged = changed.replace(desired().copy(acknowledgedOccurrenceKeys = keys, acknowledgedEventIds = events))
        assertTrue((acknowledged["retiredOccurrenceKeys"] as List<*>).isEmpty())
    }
    @Test fun reverseZoneShiftReplacesRetirementWithValidOccurrence() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val key = m.state.pending.values.single().key
        ReminderScheduler(m, p, p, Clock.fixed(now, ZoneOffset.UTC)) { ZoneId.of("Asia/Tokyo") }.inspect(true)
        val receipt = scheduler(m, p).inspect(true)
        assertTrue((receipt["retiredOccurrenceKeys"] as List<*>).isEmpty())
        assertEquals("Europe/Berlin", m.state.occurrences[key]!!.zoneId)
        assertTrue(m.state.pending.values.any { it.key == key })
    }

    @Test fun acknowledgedRetirementCanReappearAfterReverseZoneShift() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val key = m.state.pending.values.single().key
        val keys = m.state.occurrences.keys
        scheduler(m, p).replace(desired().copy(acknowledgedOccurrenceKeys = keys))
        val tokyo = ReminderScheduler(m, p, p, Clock.fixed(now, ZoneOffset.UTC)) { ZoneId.of("Asia/Tokyo") }
        tokyo.inspect(true)
        tokyo.replace(desired().copy(acknowledgedEventIds = m.state.events.map { it.eventId }.toSet()))
        val receipt = scheduler(m, p).inspect(true)
        assertTrue((receipt["retiredOccurrenceKeys"] as List<*>).isEmpty())
        assertEquals("Europe/Berlin", m.state.occurrences[key]!!.zoneId)
        assertTrue(m.state.pending.values.any { it.key == key })
    }

    @Test fun resumeBeforeDelayedBroadcastRetainsAlreadyArmedOccurrence() {
        val m = Memory(); val p = Ports(); p.exact = false
        scheduler(m, p).replace(desired())
        val occurrence = m.state.pending.values.single()
        val resumed = scheduler(m, p, occurrence.dueAt!!.plusSeconds(60))
        resumed.inspect()
        assertEquals(occurrence.key, m.state.pending.values.single().key)
        resumed.deliver(1, occurrence.key)
        assertEquals(1, p.posts)
    }
    @Test fun unrelatedNewGenerationPreservesDelayedAlarmButBootDoesNotReplayIt() {
        val m = Memory(); val p = Ports(); scheduler(m, p).replace(desired())
        val occurrence = m.state.pending.values.single()
        val resumed = scheduler(m, p, occurrence.dueAt!!.plusSeconds(60))
        resumed.replace(desired(generation = 2))
        assertEquals(occurrence.key, m.state.pending.values.single().key)
        resumed.inspect(resetAlarms = true)
        assertTrue(m.state.pending.values.none { it.key == occurrence.key })
        assertEquals(0, p.posts)
    }

}
