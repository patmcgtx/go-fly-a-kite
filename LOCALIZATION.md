# Localization

This app supports multiple languages through Apple's String Catalog localization system.

## Supported Languages

- English (en) - Source language

The string catalog starts English-only. The structure supports adding more languages (e.g. Spanish) at any time — see "Adding a New Language" below — but no other language has been populated yet.

## How It Works

All user-facing strings are localized using the `Localizable.xcstrings` file, which is Apple's modern approach to localization (introduced in Xcode 15). This file contains all translations in a single JSON-based catalog.

### Using Localized Strings in Code

The app uses abstracted kebab-case keys (max 24 characters) for localization. The app provides a convenient `.localized` extension on `String` for accessing localized strings:

```swift
// For Text views
Text("watch-list-title".localized)

// For Button labels
Button("save".localized) {
    // action
}

// For navigation titles
.navigationTitle("add-watch".localized)

// For Picker options
Text("kite".localized)
```

Under the hood, `.localized` uses `String(localized:)` to look up translations in the String Catalog.

### Localization Keys

All keys use kebab-case format and are limited to 24 characters. First-pass keys:
- `"watch-list-title"` → "My Watches"
- `"add-watch"` → "Add Watch"
- `"kite"` → "Kite"
- `"faucet"` → "Faucet"
- `"umbrella"` → "Umbrella"
- `"save"` → "Save"
- `"cancel"` → "Cancel"
- `"use-current-location"` → "Use Current Location"
- `"location-permission-denied"` → "Location permission denied"
- `"weather-fetch-failed"` → "Couldn't fetch weather"

### Adding New Strings

1. Choose a descriptive kebab-case key (max 24 characters)
2. Add the key to your code using `"your-key".localized`
3. Add the key and translation to `Localizable.xcstrings`
4. Build the app in Xcode to verify

### Adding a New Language

1. In Xcode, select the `Localizable.xcstrings` file
2. Click the "+" button in the localizations section
3. Select the new language
4. Provide translations for all strings

## String Catalog Structure

The `Localizable.xcstrings` file contains:
- Source language (English)
- Abstracted kebab-case keys (max 24 chars) as identifiers
- Translations for each supported language
- State information (translated, needs review, etc.)

## Info.plist Localization

System strings like permission descriptions are localized using `InfoPlist.strings` files in language-specific `.lproj` directories:
- `en.lproj/InfoPlist.strings` - English system strings

Currently localized system strings:
- `NSLocationWhenInUseUsageDescription` - Location permission message

## Testing

To test localization:
1. In Xcode, select a scheme
2. Edit the scheme and change the App Language under the Run > Options tab
3. Run the app to see the selected language

Alternatively, change your device/simulator language in Settings > General > Language & Region.
