# Watch List Visual Indicators

## Overview

The watch list now shows visual indicators when weather conditions have triggered and notifications have been sent. This gives users at-a-glance information about which watches are currently active.

## Visual Design

### Normal Watch (Not Triggered)

```
┌─────────────────────────────────────────┐
│ 🌡️  Home                                │
│     Temperature below 32°F              │
│     No alert                            │
└─────────────────────────────────────────┘
```

**Indicators:**
- Icon: Default color (primary)
- No warning badge
- Status: "No alert" in secondary color
- No "Active" badge

---

### Triggered Watch (Condition Met, Notification Sent)

```
┌─────────────────────────────────────────┐
│ 🌡️  Home  ⚠️                    🔔      │
│ (orange)                        Active  │
│     Temperature below 32°F              │
│     Conditions met                      │
│     Last notified: 2 hours ago          │
└─────────────────────────────────────────┘
```

**Indicators:**
- Icon: Orange color (alert state)
- Warning triangle badge (⚠️) next to name
- Status: "Conditions met" in orange, bold
- "Last notified" timestamp in small orange text
- Right side: Bell badge (🔔) + "Active" label in orange
- Overall emphasis on orange/alert styling

---

## UI Elements Breakdown

### 1. Icon Color
- **Normal**: System default (adapts to light/dark mode)
- **Triggered**: Orange - draws immediate attention

### 2. Alert Badge
- **When shown**: Only when `wasTriggeredOnLastCheck == true`
- **Symbol**: `exclamationmark.triangle.fill`
- **Position**: Next to watch name
- **Color**: Orange

### 3. Status Text
- **"No alert"**: Gray, regular weight
- **"Conditions met"**: Orange, medium weight (stands out)
- **"Loading"**: Gray (in progress)
- **"Weather fetch failed"**: Gray (error state)

### 4. Last Notified Timestamp
- **When shown**: Only when `lastNotifiedDate != nil`
- **Format**: Relative time ("2 hours ago", "30 minutes ago")
- **Style**: Very small caption, orange
- **Purpose**: Shows how recent the alert is

### 5. Active Badge (Right Side)
- **When shown**: Only when `wasTriggeredOnLastCheck == true`
- **Icon**: `bell.badge.fill`
- **Text**: "Active"
- **Color**: Orange
- **Purpose**: Quick visual scan - see all active alerts at a glance

---

## User Experience

### Scanning the List

Users can quickly identify active alerts by looking for:
1. **Orange icons** - immediate visual distinction
2. **"Active" badges** on the right - easy to scan vertically
3. **Warning triangles** - attention-grabbing

### Understanding Recency

The "Last notified" timestamp helps users understand:
- When they were alerted
- If a condition has been active for a long time
- Whether to take action now or if already handled

### State Awareness

Users can see the lifecycle of a watch:
1. **Created** → Gray icon, no alert
2. **Triggered** → Orange, "Active" badge, notification sent
3. **Still Active** → Orange, shows how long it's been active
4. **Cleared** → Returns to gray, "Active" badge removed

---

## Technical Implementation

### WatchRow.swift

```swift
// Icon with conditional color
Image(systemName: watch.kind.symbolName)
    .foregroundStyle(watch.wasTriggeredOnLastCheck ? .orange : .primary)

// Warning badge next to name
if watch.wasTriggeredOnLastCheck {
    Image(systemName: "exclamationmark.triangle.fill")
        .font(.caption)
        .foregroundStyle(.orange)
}

// Last notified timestamp
if let lastNotified = watch.lastNotifiedDate {
    Text("Last notified: \(lastNotified, style: .relative) ago")
        .font(.caption2)
        .foregroundStyle(.orange)
}

// Active badge
if watch.wasTriggeredOnLastCheck {
    VStack(spacing: 4) {
        Image(systemName: "bell.badge.fill")
            .foregroundStyle(.orange)
        Text("Active")
            .font(.caption2)
            .foregroundStyle(.orange)
    }
}
```

### State Management

The UI automatically updates because:
- `WeatherWatch` properties are observable via SwiftData
- Background checker updates `wasTriggeredOnLastCheck` and `lastNotifiedDate`
- `@Query` in `WatchListView` reactively observes changes
- SwiftUI re-renders when model changes

---

## Examples

### Example 1: Multiple Watches

```
Watch List
┌─────────────────────────────────────────┐
│ 🌡️  Home  ⚠️                    🔔      │
│ (orange)                        Active  │
│     Temperature below 32°F              │
│     Conditions met                      │
│     Last notified: 30 minutes ago       │
├─────────────────────────────────────────┤
│ 💨  Park                                │
│     Wind speed above 15 mph             │
│     No alert                            │
├─────────────────────────────────────────┤
│ 🌧️  Work  ⚠️                    🔔      │
│ (orange)                        Active  │
│     Rain above 0.5 inches               │
│     Conditions met                      │
│     Last notified: 2 hours ago          │
└─────────────────────────────────────────┘
```

**At a glance:**
- 2 active alerts (Home freeze, Work rain)
- 1 inactive watch (Park wind)
- Can see recency of each alert

### Example 2: Just Triggered

```
┌─────────────────────────────────────────┐
│ 🌡️  Home  ⚠️                    🔔      │
│ (orange)                        Active  │
│     Temperature below 32°F              │
│     Conditions met                      │
│     Last notified: Just now             │
└─────────────────────────────────────────┘
```

### Example 3: Long-Running Alert

```
┌─────────────────────────────────────────┐
│ 🌡️  Home  ⚠️                    🔔      │
│ (orange)                        Active  │
│     Temperature below 32°F              │
│     Conditions met                      │
│     Last notified: 8 hours ago          │
└─────────────────────────────────────────┘
```

**User insight:** "This has been freezing for 8 hours - I probably already handled it"

---

## Accessibility

### VoiceOver Support

The visual indicators enhance visual scanning, but VoiceOver users also benefit:
- State is part of the watch model, so screen readers can announce it
- "Active" badge provides clear semantic meaning
- Relative timestamps are naturally speakable

### Color Independence

While orange is used for emphasis:
- Icons and badges provide shape/symbol cues
- Text labels ("Active", "Conditions met") don't rely solely on color
- "Active" badge has both icon and text

### Dynamic Type

All text scales with user's preferred text size:
- Caption and caption2 styles scale appropriately
- Layout adapts to larger text sizes
- Orange emphasis remains effective at any size

---

## Future Enhancements

### Severity Levels
Different colors for different severity:
- 🟡 Yellow: Informational alerts
- 🟠 Orange: Standard alerts (current)
- 🔴 Red: Critical alerts (extreme weather)

### Swipe Actions
- Swipe to acknowledge (clears "Active" state manually)
- Swipe to snooze (re-notify in X hours)
- Swipe to disable temporarily

### Filtering
- "Show only active" toggle
- Filter by condition type
- Sort by last notified

### Rich Notifications
When tapping a triggered watch:
- Show full weather details
- Show notification history
- Offer quick actions

---

**Summary:** The watch list now provides immediate visual feedback about which watches are actively alerting, when they were last notified, and their current state - making it easy to understand your weather monitoring at a glance! 🎨
