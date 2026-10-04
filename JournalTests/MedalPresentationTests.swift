import XCTest
import SceneKit
import AVFoundation
import SwiftUI
@testable import Journal

@MainActor
final class MedalPresentationTests: XCTestCase {
    func testCarouselKeepsCenterLargestAndScalesBothSidesSmoothly() {
        for width: CGFloat in [320, 393, 768] {
            let center = width / 2
            XCTAssertEqual(MedalCarouselLayout.scale(center: center, viewportWidth: width), 1)
            let near = MedalCarouselLayout.scale(center: center + width * 0.1, viewportWidth: width)
            let far = MedalCarouselLayout.scale(center: center + width * 0.4, viewportWidth: width)
            XCTAssertGreaterThan(near, far)
            XCTAssertLessThan(near, 1)
            XCTAssertEqual(far, MedalCarouselLayout.scale(center: center - width * 0.4, viewportWidth: width), accuracy: 0.0001)
            XCTAssertGreaterThanOrEqual(MedalCarouselLayout.scale(center: width * 4, viewportWidth: width), 0.64)
        }
    }

    func testAllThirtySixUSDZMedalsResolveAndLoad() throws {
        let names = ["Autocorrect Disaster Badge", "Blew Up A Microwave Badge", "Breakfast Pizza Badge", "Comfort Zone Badge", "Created Something Badge", "Cried It Out Badge", "Disconnected From Screens Badge", "Doomscrolled Badge", "Dropped Phone On Face Badge", "Fed Curiosity Badge", "Finished Tasks Badge", "Forgave Yourself Badge", "Goal Achieved Badge", "Guessed The Time Correctly Badge", "Helped Others Badge", "Heroic Napper Badge", "Kept Going Badge", "Lost A Sock Badge", "Made Amends Badge", "Made Connections Badge", "Mindfulness Badge", "New Beginnings Badge", "Nourished Yourself Badge", "Overcoming Difficulty Badge", "Reached Out Badge", "Reached Out First Badge", "Remembered A Dream", "Rest Well Badge", "Said No Badge", "Sang In The Shower Badge", "Sat With Uncertainty Badge", "Set Boundaries Badge", "Showed Up For Yourself Badge", "Slept Without Guilt Badge", "Stayed Active Badge", "Touched Grass Badge"]
        XCTAssertEqual(names.count, AwardType.allCases.count)
        for name in names {
            let url = try XCTUnwrap(MedalAppearance.resourceURL(named: name), "Missing model: \(name)")
            let scene = try SCNScene(url: url)
            var geometryCount = 0
            scene.rootNode.enumerateChildNodes { node, _ in
                if let geometry = node.geometry {
                    geometryCount += 1
                    XCTAssertFalse(geometry.materials.isEmpty, name)
                }
            }
            XCTAssertGreaterThan(geometryCount, 0, name)
        }
    }

    func testAllMedalIconsAreBundledWithTransparentMargins() throws {
        let names = [
            "Medal2D-beganSomething",
            "Medal2D-handledDifficulty",
            "Medal2D-practicedMindfulness",
            "Medal2D-prioritisedSleep",
            "Medal2D-madeAmends",
            "Medal2D-connectedWithSomeone",
            "Medal2D-askedForHelp",
            "Medal2D-finishedSomething",
            "Medal2D-celebratedAWin",
            "Medal2D-steppedOutsideComfort",
            "Medal2D-movedYourBody",
            "Medal2D-createdSomething",
            "Medal2D-helpedOthers",
            "Medal2D-ateWell",
            "Medal2D-reachedOutFirst",
            "Medal2D-learnedSomethingNew",
            "Medal2D-spentTimeInNature",
            "Medal2D-disconnectedFromScreens",
            "Medal2D-satWithUncertainty",
            "Medal2D-restedWithoutGuilt",
            "Medal2D-keptGoing",
            "Medal2D-saidNo",
            "Medal2D-setABoundary",
            "Medal2D-showedUpForYourself",
            "Medal2D-criedItOut",
            "Medal2D-sangInTheShower",
            "Medal2D-forgivingYourself",
            "Medal2D-blewUpMicrowave",
            "Medal2D-heroicNapper",
            "Medal2D-doomScrolled",
            "Medal2D-lostASock",
            "Medal2D-breakfastPizza",
            "Medal2D-autocorrectDisaster",
            "Medal2D-rememberedADream",
            "Medal2D-guessedTimeCorrectly",
            "Medal2D-droppedPhoneOnFace"
        ]
        XCTAssertEqual(names.count, AwardType.allCases.count)
        for name in names {
            let image = try XCTUnwrap(UIImage(named: name), name)
            let cgImage = try XCTUnwrap(image.cgImage, name)
            XCTAssertEqual(cgImage.width, 512, name)
            XCTAssertEqual(cgImage.height, 512, name)
            var pixel = [UInt8](repeating: 0, count: 4)
            let context = try XCTUnwrap(CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8,
                bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            let corner = try XCTUnwrap(cgImage.cropping(to: CGRect(x: 0, y: 0, width: 1, height: 1)))
            context.draw(corner, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            XCTAssertEqual(pixel[3], 0, "Opaque background in \(name)")
        }
    }

    func testChimeIsShortStereoAndDoesNotClip() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "MedalChime", withExtension: "wav"))
        let file = try AVAudioFile(forReading: url)
        XCTAssertEqual(file.processingFormat.channelCount, 2)
        XCTAssertEqual(Double(file.length) / file.processingFormat.sampleRate, 1.9, accuracy: 0.01)
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)))
        try file.read(into: buffer)
        let channels = try XCTUnwrap(buffer.floatChannelData)
        for channel in 0..<2 {
            let peak = (0..<Int(buffer.frameLength)).map { abs(channels[channel][$0]) }.max() ?? 0
            XCTAssertGreaterThan(peak, 0.1)
            XCTAssertLessThan(peak, 0.7)
            XCTAssertLessThan(abs(channels[channel][Int(buffer.frameLength) - 1]), 0.001)
        }
    }

    func testAudioSessionActivatesAndDeactivatesAsynchronously() async throws {
        try await AudioSessionController.shared.activate(category: .ambient, options: .mixWithOthers)
        try await AudioSessionController.shared.deactivate()
    }

    func testCenteredProgressRendersAtPhoneSizes() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        defer { previousKeyWindow?.makeKey() }
        for width in [320.0, 393.0] {
            let content = ZStack {
                LinearGradient(colors: [.black, .indigo.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                AchievementProgressOverlay(onContinue: {})
            }.environment(\.colorScheme, .dark)
            let controller = UIHostingController(rootView: content)
            let window = UIWindow(windowScene: scene)
            window.frame = CGRect(x: 0, y: 0, width: width, height: 780)
            window.rootViewController = controller
            window.makeKeyAndVisible()
            controller.view.frame = window.bounds
            controller.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(300))
            let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
            let image = renderer.image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            XCTAssertEqual(image.size.width, width)
            let path = FileManager.default.temporaryDirectory.appendingPathComponent("achievement-overlay-\(Int(width)).png")
            try XCTUnwrap(image.pngData()).write(to: path)
            print("OVERLAY_PREVIEW: \(path.path)")
            window.isHidden = true
        }
    }
}
