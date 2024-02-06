// swift-tools-version: 5.9

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Your Presentation",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Your Presentation",
            targets: ["AppModule"],
            bundleIdentifier: "mystic.Your-Presentation",
            teamIdentifier: "96B293Z3Y9",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .mic),
            accentColor: .presetColor(.brown),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "Can I use camera for your presentation?"),
                .microphone(purposeString: "Can I use a microphone for your presentation?"),
                .speechRecognition(purposeString: "Can I use speech recognition for your presentation? (My app does not require network connection.)")
            ],
            appCategory: .education
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)