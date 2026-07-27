# Notification Deduplication

## Overview

GoFlyAKite uses **state change detection** to prevent notification spam. You only receive alerts when weather conditions *transition* from not meeting your threshold to meeting it, rather than getting repeated notifications every 15 minutes while conditions persist.

## How It Works

### State Tracking

Each `WeatherWatch` tracks two pieces of state:

```swift
var lastNotifiedDate: Date? = nil           // When did we last send a notification?
var wasTriggeredOnLastCheck: Bool = false   // Was condition met on previous check?
```

### State Change Detection Logic

On each background check (~every 15 minutes):

1. **Evaluate current conditions** against threshold
2. **Compare to previous state** (`wasTriggeredOnLastCheck`)
3. **Determine action:**

| Previous State | Current State | Action |
|---------------|---------------|--------|
| Not triggered | Not triggered | ✅ No notification (condition not met) |
| Not triggered | **Triggered** | 🚨 **Send notification** (condition just started) |
| Triggered | Triggered | ⏸️ No notification (already notified) |
| Triggered | Not triggered | ✅ No notification (condition cleared) |

4. **Update state** for next check
5. **Save to database**

### Example Timeline

**Watch:** "Temperature below 32°F"

```
6:00 AM Check:
  Forecast low: 35°F → Not triggered
  wasTriggeredOnLastCheck: false
  Action: No notification ✅

6:15 AM Check:
  Forecast low: 31°F → Triggered!
  wasTriggeredOnLastCheck: false (changed from false to true)
  Action: SEND NOTIFICATION 🚨
  Update: wasTriggeredOnLastCheck = true
  Update: lastNotifiedDate = 6:15 AM

6:30 AM Check:
  Forecast low: 30°F → Still triggered
  wasTriggeredOnLastCheck: true (no state change)
  Action: No notification (already notified) ⏸️

6:45 AM Check:
  Forecast low: 29°F → Still triggered
  wasTriggeredOnLastCheck: true (no state change)
  Action: No notification (already notified) ⏸️

... continues throughout the day ...

3:00 PM Check:
  Forecast low: 34°F → Not triggered (temperature rising)
  wasTriggeredOnLastCheck: true
  Action: No notification (condition cleared) ✅
  Update: wasTriggeredOnLastCheck = false

3:15 PM Check:
  Forecast low: 35°F → Not triggered
  wasTriggeredOnLastCheck: false
  Action: No notification ✅

... next day ...

6:00 AM Check:
  Forecast low: 28°F → Triggered again!
  wasTriggeredOnLastCheck: false (new condition)
  Action: SEND NOTIFICATION 🚨 (fresh alert for new freeze event)
```

## Benefits

### ✅ No Spam
- You get **one notification** when a condition starts
- Not 96 notifications throughout the day!

### ✅ Actionable Alerts
- Notifications represent **new information**
- Each alert requires attention/action

### ✅ Handles Recovery
- When conditions clear and trigger again later
- You get a fresh notification for the new event

### ✅ Works with Rolling 24h Window
- State changes based on forecast, not just current conditions
- Morning alerts about afternoon/evening conditions

## Debug Logging

When watching console logs during background checks, you'll see:

```
🔍 Checking 3 watches...

🚨 Alert triggered for: Home (state changed to triggered)
  → Notification sent!

⚠️ Alert still triggered for: Work (no new notification)
  → Already notified, condition persists

✓ No alert for: Garden
  → Condition not met
```

## Future Enhancements

### Periodic Reminders (Not Yet Implemented)

The model includes `shouldSendPeriodicReminder` for a potential future feature:

- Send a reminder every 12 hours if condition persists
- Useful for long-duration events (multi-day heat waves, extended freezes)
- Would be opt-in per watch

**Example:**
```
6:00 AM: Initial freeze alert 🚨
6:00 PM: Periodic reminder (still freezing) 🔔
6:00 AM next day: Periodic reminder (still freezing) 🔔
```

### Smart Re-notification

Potential strategies for important conditions:

- **Critical thresholds**: Re-notify for severe weather (e.g., below 0°F)
- **Escalating alerts**: First subtle, then more prominent if unacknowledged
- **Time-based**: Re-notify if condition will occur within next 2 hours

### User Preferences

Allow users to configure notification behavior per watch:

- **One-time only**: Default behavior (current implementation)
- **Periodic reminders**: Every X hours while triggered
- **Daily digest**: One notification per day summarizing all watches
- **Quiet hours**: Don't notify during sleep hours

## Technical Details

### Database Schema

```swift
@Model
final class WeatherWatch {
    // ... other properties ...
    
    var lastNotifiedDate: Date? = nil           // Optional - nil until first notification
    var wasTriggeredOnLastCheck: Bool = false   // Defaults to false for new watches
}
```

### Persistence

State is saved to SwiftData after each background check:

```swift
watch.wasTriggeredOnLastCheck = isTriggered
if shouldNotify {
    watch.lastNotifiedDate = Date()
}
try? modelContext.save()
```

This ensures state survives app restarts and system reboots.

### CloudKit Compatibility

These properties use the same CloudKit-compatible patterns:
- Default values (not optional for `wasTriggeredOnLastCheck`)
- `lastNotifiedDate` is optional (nil is valid default)
- No unique constraints

When CloudKit sync is added, notification state will sync across devices, preventing duplicate notifications on multiple devices.

## Testing

### Manual Testing

1. Create a watch with easily triggerable threshold
2. Wait for background check (or simulate in debugger)
3. Check console logs for state transitions
4. Verify only ONE notification received

### Automated Testing

State change logic can be tested by:
- Creating watches with known states
- Simulating weather snapshots
- Asserting notification behavior based on state transitions

---

**Summary:** State change detection ensures you get **actionable, non-spammy notifications** that represent new weather events, not repeated alerts for the same persistent condition.
