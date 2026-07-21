import Testing
@testable import GoFlyAKite

@Suite("WeatherAlertEvaluator")
struct WeatherAlertEvaluatorTests {

    @Test("Kite triggers when wind is high", arguments: [
        (windSpeedMPH: 20.0, expected: true),
        (windSpeedMPH: 5.0, expected: false),
    ])
    func kiteThreshold(windSpeedMPH: Double, expected: Bool) {
        let snapshot = WeatherSnapshot(windSpeedMPH: windSpeedMPH, precipitationChance: 0, lowTemperatureF: 60)
        #expect(WeatherAlertEvaluator.isTriggered(kind: .kite, snapshot: snapshot) == expected)
    }

    @Test("Faucet triggers when low temperature is at or below freezing", arguments: [
        (lowTemperatureF: 30.0, expected: true),
        (lowTemperatureF: 50.0, expected: false),
    ])
    func faucetThreshold(lowTemperatureF: Double, expected: Bool) {
        let snapshot = WeatherSnapshot(windSpeedMPH: 5, precipitationChance: 0, lowTemperatureF: lowTemperatureF)
        #expect(WeatherAlertEvaluator.isTriggered(kind: .faucet, snapshot: snapshot) == expected)
    }

    @Test("Umbrella triggers when precipitation chance is high", arguments: [
        (precipitationChance: 0.8, expected: true),
        (precipitationChance: 0.1, expected: false),
    ])
    func umbrellaThreshold(precipitationChance: Double, expected: Bool) {
        let snapshot = WeatherSnapshot(windSpeedMPH: 5, precipitationChance: precipitationChance, lowTemperatureF: 60)
        #expect(WeatherAlertEvaluator.isTriggered(kind: .umbrella, snapshot: snapshot) == expected)
    }
}
