import Testing
@testable import GoFlyAKite

@Suite("WeatherAlertEvaluator")
struct WeatherAlertEvaluatorTests {

    @Test("Temperature above threshold triggers")
    func temperatureAbove() {
        let watch = WeatherWatch(
            kind: .temperature,
            label: "Test",
            latitude: 0,
            longitude: 0,
            comparison: .above,
            thresholdValue: 80
        )
        
        let hotSnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0,
            lowTemperatureF: 70,
            highTemperatureF: 90,
            currentTemperatureF: 85,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: hotSnapshot) == true)
        
        let coolSnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0,
            lowTemperatureF: 60,
            highTemperatureF: 75,
            currentTemperatureF: 70,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: coolSnapshot) == false)
    }

    @Test("Temperature below threshold triggers")
    func temperatureBelow() {
        let watch = WeatherWatch(
            kind: .temperature,
            label: "Test",
            latitude: 0,
            longitude: 0,
            comparison: .below,
            thresholdValue: 32
        )
        
        let coldSnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0,
            lowTemperatureF: 25,
            highTemperatureF: 35,
            currentTemperatureF: 30,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: coldSnapshot) == true)
        
        let warmSnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0,
            lowTemperatureF: 40,
            highTemperatureF: 50,
            currentTemperatureF: 45,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: warmSnapshot) == false)
    }

    @Test("Wind speed above threshold triggers")
    func windSpeedAbove() {
        let watch = WeatherWatch(
            kind: .windSpeed,
            label: "Test",
            latitude: 0,
            longitude: 0,
            comparison: .above,
            thresholdValue: 15
        )
        
        let windySnapshot = WeatherSnapshot(
            windSpeedMPH: 20,
            precipitationChance: 0,
            lowTemperatureF: 60,
            highTemperatureF: 70,
            currentTemperatureF: 65,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: windySnapshot) == true)
        
        let calmSnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0,
            lowTemperatureF: 60,
            highTemperatureF: 70,
            currentTemperatureF: 65,
            rainAccumulationInches: 0
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: calmSnapshot) == false)
    }

    @Test("Rain accumulation above threshold triggers")
    func rainAbove() {
        let watch = WeatherWatch(
            kind: .rain,
            label: "Test",
            latitude: 0,
            longitude: 0,
            comparison: .above,
            thresholdValue: 0.5
        )
        
        let rainySnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0.8,
            lowTemperatureF: 60,
            highTemperatureF: 70,
            currentTemperatureF: 65,
            rainAccumulationInches: 0.75
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: rainySnapshot) == true)
        
        let drySnapshot = WeatherSnapshot(
            windSpeedMPH: 5,
            precipitationChance: 0.1,
            lowTemperatureF: 60,
            highTemperatureF: 70,
            currentTemperatureF: 65,
            rainAccumulationInches: 0.1
        )
        #expect(WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: drySnapshot) == false)
    }
}
