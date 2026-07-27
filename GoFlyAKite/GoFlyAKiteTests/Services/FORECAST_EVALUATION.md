# Forecast-Based Weather Evaluation

## Overview

GoFlyAKite uses **forecast data** from a **rolling 24-hour window** rather than just current conditions to evaluate weather watches. This allows the app to alert you about upcoming conditions, giving you time to prepare.

**Key feature:** The forecast window is always the next 24 hours from now, not just "today" — so checks at 11 PM will consider tomorrow's conditions too.

## Evaluation Strategy by Watch Type

### Temperature Watches

| Comparison | Data Used | Example Use Case |
|------------|-----------|------------------|
| **Above** | Highest temperature in next 24 hours | "Alert me if it will get above 85°F in the next day" (don't plan outdoor activities) |
| **Below** | Lowest temperature in next 24 hours | "Alert me if it will drop below 32°F in the next day" (protect plants, drip faucets) |

**Why:** You need advance warning to prepare. If you're watching for freezing temps, you want to know in the morning that it will freeze tonight, not when it's already freezing.

**Rolling window benefit:** If you check at 10 PM and tomorrow morning will freeze, you'll get alerted tonight while you can still prepare.

### Wind Speed Watches

| Comparison | Data Used | Example Use Case |
|------------|-----------|------------------|
| **Above** | Maximum wind speed in next 24 hours | "Alert me if winds will reach 15 mph in the next day" (good for kite flying!) |
| **Below** | Current wind speed | "Alert me if winds are calm right now" (good for drone flying, outdoor work) |

**Why:** 
- **Above**: You want to know if it will be windy at any point in the next 24 hours, so you can plan activities
- **Below**: You care about calm conditions right now, not in the future

**Rolling window benefit:** Works consistently regardless of time of day — evening checks see tomorrow's forecast.

### Rain Watches

| Comparison | Data Used | Example Use Case |
|------------|-----------|------------------|
| **Above** | Total rain accumulation in next 24 hours | "Alert me if we'll get more than 0.5 inches in the next day" (bring umbrella, reschedule outdoor work) |
| **Below** | Total rain accumulation in next 24 hours | "Alert me if we'll get less than 0.1 inches in the next day" (need to water plants) |

**Why:** Rain accumulation is inherently forecast-based — you're looking at what will happen over the next 24 hours.

**Rolling window benefit:** Consistent behavior — you always know what to expect in the next full day.

## Rolling 24-Hour Window Explained

### What Does "Rolling 24 Hours" Mean?

Instead of using calendar day boundaries (midnight to midnight), the app looks at the next 24 hours from whenever the check happens:

**Example at 8 AM:**
- Window: 8 AM today → 8 AM tomorrow
- Temperature low: Minimum temp in that window (tonight's low)
- Temperature high: Maximum temp in that window (today's high)

**Example at 10 PM:**
- Window: 10 PM today → 10 PM tomorrow
- Temperature low: Minimum temp in that window (tonight + tomorrow morning's low)
- Temperature high: Maximum temp in that window (tomorrow's high)

### Why This Is Better

| Calendar Day Approach | Rolling 24-Hour Window |
|----------------------|------------------------|
| 11 PM check misses tomorrow | ✅ Always includes next 24 hours |
| Resets at midnight | ✅ Continuous coverage |
| "Today's high" might be in the past | ✅ Always future-looking |
| Inconsistent behavior by time of day | ✅ Consistent anytime |

## Technical Implementation

### WeatherSnapshot
Contains both current conditions and forecast data for the next 24 hours:
```swift
struct WeatherSnapshot {
    var windSpeedMPH: Double              // Current wind
    var maxWindSpeedMPH: Double           // Max wind in next 24h
    var currentTemperatureF: Double       // Current temp
    var lowTemperatureF: Double           // Min temp in next 24h
    var highTemperatureF: Double          // Max temp in next 24h
    var rainAccumulationInches: Double    // Total rain in next 24h
}
```

### Data Collection (WeatherKitWeatherService)

```swift
// Get next 24 hours of hourly forecast data
let next24Hours = weather.hourlyForecast.prefix(24)

// Calculate rolling 24-hour temperature range
let temperatures = next24Hours.map { $0.temperature }
let lowTemp = temperatures.min()    // Coldest in next 24h
let highTemp = temperatures.max()   // Hottest in next 24h

// Calculate rolling 24-hour max wind
let windSpeeds = next24Hours.map { $0.wind.speed }
let maxWind = windSpeeds.max()      // Windiest in next 24h

// Calculate rolling 24-hour rain accumulation
let rainAccumulation = next24Hours.reduce(0.0) { total, hour in
    total + hour.precipitationAmount
}
```

### WeatherAlertEvaluator Logic

```swift
switch watch.kind {
case .temperature:
    switch watch.comparison {
    case .above:
        value = snapshot.highTemperatureF  // Will it get hot?
    case .below:
        value = snapshot.lowTemperatureF   // Will it get cold?
    }
case .windSpeed:
    switch watch.comparison {
    case .above:
        value = snapshot.maxWindSpeedMPH   // Will it get windy?
    case .below:
        value = snapshot.windSpeedMPH      // Is it calm now?
    }
case .rain:
    value = snapshot.rainAccumulationInches // How much rain today?
}
```

## User Experience Benefits

### Before (Current Conditions Only)
- ❌ 8 AM: Temperature is 65°F, watch for "below 32°F" doesn't trigger
- ❌ 8 PM: Temperature drops to 31°F, you get alerted
- ❌ **Too late!** Plants are already damaged, pipes may freeze

### After (Forecast-Based)
- ✅ 8 AM: Forecast shows low of 30°F tonight, you get alerted
- ✅ **Perfect!** You have all day to:
  - Cover sensitive plants
  - Set faucets to drip
  - Bring in outdoor items
  - Plan alternate activities

## Real-World Scenarios

### Scenario 1: Kite Flying (Morning Check)
**Watch:** "Wind speed above 12 mph"  
**Time:** 9 AM

**With rolling 24-hour forecast:**
- Current wind: 5 mph
- Forecast shows 15 mph gusts at 2 PM (within next 24h)
- ✅ You get notified in the morning
- You can pack your kite and plan your afternoon

### Scenario 2: Kite Flying (Evening Check)
**Watch:** "Wind speed above 12 mph"  
**Time:** 9 PM

**With rolling 24-hour forecast:**
- Current wind: 3 mph
- Forecast shows 18 mph winds tomorrow at 11 AM (within next 24h)
- ✅ You get notified tonight
- You can plan for tomorrow morning

### Scenario 3: Frost Protection (Evening Check)
**Watch:** "Temperature below 32°F"  
**Time:** 10 PM

**With rolling 24-hour forecast:**
- Current temp: 45°F
- Rolling 24h window shows low of 28°F at 6 AM tomorrow
- ✅ You get notified tonight
- You still have time to cover plants before bed

### Scenario 4: Rain Planning (Late Night Check)
**Watch:** "Rain above 0.25 inches"  
**Time:** 11 PM

**With rolling 24-hour forecast:**
- Rolling 24h window: 11 PM tonight → 11 PM tomorrow
- Forecast shows 0.5 inches accumulating during tomorrow
- ✅ You get notified tonight
- You can plan for tomorrow (bring umbrella, reschedule outdoor work)

## Background Monitoring

The background weather checker runs every ~15 minutes and evaluates these forecast-based conditions using a rolling 24-hour window. This means:

1. **Continuous coverage** — checks work consistently any time of day or night
2. **Always forward-looking** — you always get alerts about the *next* 24 hours
3. **You get actionable notifications** with time to prepare
4. **Alerts are relevant** to planning, not just reacting
5. **No midnight gaps** — evening checks include tomorrow's conditions

### Example Background Check Timeline

**8 AM Check:**
- Window: 8 AM today → 8 AM tomorrow
- Detects: Today's afternoon heat, tonight's freeze

**8 PM Check:**
- Window: 8 PM today → 8 PM tomorrow  
- Detects: Tonight's freeze, tomorrow's morning conditions

**11 PM Check:**
- Window: 11 PM today → 11 PM tomorrow
- Detects: Tomorrow's full day conditions (still actionable!)

## Future Enhancements

Potential improvements to forecast evaluation:

- **Time-specific watches**: "Alert me if it will be windy between 2-4 PM"
- **Multi-day forecasts**: "Alert me if it will freeze in the next 3 days"
- **Trend-based alerts**: "Alert me when temperature is rising/falling rapidly"
- **Confidence levels**: "High confidence of rain" vs "Possible rain"

---

**Summary:** GoFlyAKite uses a smart **rolling 24-hour forecast window** to give you **actionable** weather alerts with time to prepare, not reactive alerts when it's too late. The forecast is always forward-looking, regardless of when you check, ensuring consistent and useful notifications any time of day.
