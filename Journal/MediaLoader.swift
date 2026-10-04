import SwiftUI
import PhotosUI
import AVKit
import ImageIO
import CryptoKit
import UniformTypeIdentifiers

nonisolated struct ImportedMedia: Sendable {
    let data: Data
    let preview: UIImage
}

nonisolated struct PickedVideo: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { received in
            PickedVideo(data: try Data(contentsOf: received.file, options: .mappedIfSafe))
        }
    }
}

actor MediaLoader {
    private static let shared = MediaLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() { cache.totalCostLimit = 40 * 1024 * 1024 }

    @MainActor static func placeholder(for data: Data) -> UIImage {
        UIImage(systemName: "photo.on.rectangle") ?? UIImage()
    }

    static func load(_ items: [PhotosPickerItem]) async -> [ImportedMedia] {
        var result: [ImportedMedia] = []
        for item in items {
            guard !Task.isCancelled else { break }
            let data: Data?
            if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                data = try? await item.loadTransferable(type: PickedVideo.self)?.data
            } else {
                data = try? await item.loadTransferable(type: Data.self)
            }
            if let data {
                result.append(ImportedMedia(data: data, preview: await shared.preview(data, maximumSize: 1000)))
            }
        }
        return result
    }

    static func previews(_ media: [Data], maximumSize: Int = 1000) async -> [UIImage] {
        var result: [UIImage] = []
        for data in media {
            guard !Task.isCancelled else { break }
            result.append(await shared.preview(data, maximumSize: maximumSize))
        }
        return result
    }

    private func preview(_ data: Data, maximumSize: Int) async -> UIImage {
        let key = "\(maximumSize)-\(SHA256.hash(data: data))" as NSString
        if let image = cache.object(forKey: key) { return image }
        let image: UIImage
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumSize,
            kCGImageSourceShouldCacheImmediately: true
           ] as CFDictionary) {
            image = UIImage(cgImage: thumbnail)
        } else {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("preview-\(UUID().uuidString).mov")
            defer { try? FileManager.default.removeItem(at: url) }
            do {
                try data.write(to: url)
                let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: maximumSize, height: maximumSize)
                let frame = try await generator.image(at: .zero)
                image = UIImage(cgImage: frame.image)
            } catch { image = UIImage(systemName: "video.fill") ?? UIImage() }
        }
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: key, cost: cost)
        return image
    }
}

struct VideoAttachmentView: View {
    let data: Data
    let onClose: () -> Void
    @State private var player: AVPlayer?
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            if let player { VideoPlayer(player: player) }
            if let errorMessage { Text(errorMessage).foregroundStyle(.white).padding() }
            Button("Done", action: onClose).padding().background(.regularMaterial, in: Capsule()).padding()
        }
        .task {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("playback-\(UUID().uuidString).mov")
            defer { player?.pause(); player = nil; try? FileManager.default.removeItem(at: url) }
            do {
                try await Task.detached(priority: .userInitiated) { try data.write(to: url) }.value
                try Task.checkCancellation()
                player = AVPlayer(url: url)
                player?.play()
                while !Task.isCancelled { try await Task.sleep(for: .seconds(30)) }
            } catch is CancellationError { }
            catch { errorMessage = "This video could not be opened." }
        }
    }
}
