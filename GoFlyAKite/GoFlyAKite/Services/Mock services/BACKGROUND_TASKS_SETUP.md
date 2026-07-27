# Background Tasks Configuration

## Required Info.plist Changes

Add the following to your `Info.plist` file:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.goFlyAKite.weatherCheck</string>
</array>
```

## Required Xcode Configuration

### 1. Add Background Modes Capability
1. Select your app target in Xcode
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Background Modes"
5. Enable these checkboxes:
   - ✅ Background fetch
   - ✅ Remote notifications (optional, for future push notification support)

### 2. Testing Background Tasks in Simulator

Background tasks don't run automatically in the simulator. To test them:

1. Run your app in the simulator
2. Once the app is running, pause execution in Xcode
3. In the debugger console (lldb), type:
   ```
   e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.goFlyAKite.weatherCheck"]
   ```
4. Resume execution
5. The background task should run immediately

### 3. Testing on Device

On a real device:
1. Install the app
2. Add some weather watches
3. Close the app completely (swipe up from app switcher)
4. Wait 15-30 minutes
5. The system will run background refreshes based on usage patterns

**Note:** iOS learns when to run background tasks based on user behavior. If you frequently open the app at certain times, iOS will schedule background refreshes before those times.

## How It Works

1. **Registration**: The app registers the background task handler in `GoFlyAKiteApp.init()`
2. **Scheduling**: First scheduled when the app appears, then rescheduled after each run
3. **Execution**: Every 15 minutes (minimum allowed by iOS), the system may wake up the app
4. **Weather Check**: Fetches weather for all enabled watches
5. **Notifications**: Sends notifications when threshold conditions are met
6. **Rescheduling**: After completion, schedules the next refresh

## Frequency

- **Requested interval**: 15 minutes
- **Actual interval**: Varies based on iOS battery optimization and usage patterns
- **Guaranteed**: No - iOS decides when to actually run the task

## Privacy

The app requests these permissions:
- **Location**: To fetch weather for watch locations (when in use)
- **Notifications**: To send weather alerts

## Future Enhancements

Consider adding:
- User preference for notification frequency
- Quiet hours (don't notify at night)
- Critical alerts for severe weather
- Live Activities for real-time weather monitoring
