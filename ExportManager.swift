import UIKit
import SwiftUI
import PDFKit

final class ExportManager {
    static let shared = ExportManager()
    private init() {}

    private final class YPosition { var y: CGFloat = 0 }

    // MARK: - Public API

    func exportURL(from entries: [JournalEntry]) -> URL? {
        let data = generatePDF(from: entries)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("journal_export_\(Int(Date().timeIntervalSince1970)).pdf")
        try? data.write(to: url)
        return url
    }

    // MARK: - Layout Constants

    private enum Layout {
        static let pageWidth:    CGFloat = 595
        static let pageHeight:   CGFloat = 842
        static let margin:       CGFloat = 50
        static let contentWidth: CGFloat = pageWidth - margin * 2
        static let bottomBound:  CGFloat = pageHeight - margin

        static let black    = UIColor.black
        static let darkGray = UIColor.darkGray
        static let white    = UIColor.white

        static let h1Font      = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let h2Font      = UIFont.systemFont(ofSize: 15, weight: .semibold)
        static let h3Font      = UIFont.systemFont(ofSize: 12, weight: .semibold)
        static let bodyFont    = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let labelFont   = UIFont.systemFont(ofSize: 11, weight: .medium)
        static let captionFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    }

    // MARK: - PDF Generation

    private func generatePDF(from entries: [JournalEntry]) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: Layout.pageWidth, height: Layout.pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in

            let pos = YPosition()
            pos.y = Layout.margin

            func newPage() {
                ctx.beginPage()
                Layout.white.setFill()
                UIRectFill(pageRect)
                pos.y = Layout.margin
            }

            func ensureSpace(_ needed: CGFloat) {
                if pos.y + needed > Layout.bottomBound { newPage() }
            }

            newPage()

            pos.y = draw(text: "Journal Export",
                             font: Layout.h1Font, color: Layout.black,
                             x: Layout.margin, y: pos.y,
                             width: Layout.contentWidth) + 6

            let dateRange = dateRangeString(entries: entries)
            pos.y = draw(text: dateRange,
                             font: Layout.labelFont, color: Layout.darkGray,
                             x: Layout.margin, y: pos.y,
                             width: Layout.contentWidth) + 4

            pos.y = draw(text: "\(entries.count) \(entries.count == 1 ? "entry" : "entries")",
                             font: Layout.captionFont, color: Layout.darkGray,
                             x: Layout.margin, y: pos.y,
                             width: Layout.contentWidth) + 12

            UIColor(white: 0, alpha: 0.25).setFill()
            UIRectFill(CGRect(x: Layout.margin, y: pos.y,
                              width: Layout.contentWidth, height: 0.5))
            pos.y += 16

            let stamp = "Exported \(Date().formatted(date: .complete, time: .shortened))"
            pos.y = draw(text: stamp,
                             font: Layout.captionFont, color: Layout.darkGray,
                             x: Layout.margin, y: pos.y,
                             width: Layout.contentWidth) + 24

            if let icon = UIImage(named: "App Icon PNG") {
                let remaining = Layout.bottomBound - pos.y
                let iconSize  = min(remaining - Layout.margin, Layout.contentWidth)
                let iconX     = Layout.margin + (Layout.contentWidth - iconSize) / 2

                if let ctx = UIGraphicsGetCurrentContext() {
                    ctx.saveGState()
                    let iconRect = CGRect(x: iconX, y: pos.y, width: iconSize, height: iconSize)
                    UIBezierPath(roundedRect: iconRect, cornerRadius: iconSize * 0.2237).addClip()
                    icon.draw(in: iconRect)
                    ctx.restoreGState()
                }
            }

            for entry in entries {
                newPage()
                drawEntry(entry: entry,
                          pos: pos,
                          pageRect: pageRect,
                          newPage: newPage,
                          ensureSpace: ensureSpace)
            }
        }
    }

    // MARK: - Draw a Single Entry

    private func drawEntry(
        entry: JournalEntry,
        pos: YPosition,
        pageRect: CGRect,
        newPage: () -> Void,
        ensureSpace: (CGFloat) -> Void
    ) {
        let x = Layout.margin
        let w = Layout.contentWidth

        let dateStr = entry.date.formatted(date: .complete, time: .shortened)
        pos.y = draw(text: dateStr, font: Layout.h2Font, color: UIColor.black,
                     x: x, y: pos.y, width: w) + 6

        let iconSize: CGFloat = 22
        let mColor = moodColor(for: entry.mood)

        if let moodImage = moodSFImage(for: entry.mood, size: iconSize * 0.7) {
            mColor.withAlphaComponent(0.15).setFill()
            UIBezierPath(ovalIn: CGRect(x: x, y: pos.y, width: iconSize, height: iconSize)).fill()
            moodImage.draw(in: CGRect(
                x: x + (iconSize - moodImage.size.width) / 2,
                y: pos.y + (iconSize - moodImage.size.height) / 2,
                width: moodImage.size.width,
                height: moodImage.size.height
            ))
        }

        let moodLabel = "\(entry.mood.label)"
        draw(text: moodLabel, font: Layout.labelFont, color: mColor,
             x: x + iconSize + 6,
             y: pos.y + (iconSize - Layout.labelFont.lineHeight) / 2,
             width: w - iconSize - 6)
        pos.y += iconSize + 10

        let hadTags = entry.locationName != nil
            || entry.musicTitle != nil
            || entry.weatherCondition != nil
            || entry.audioData != nil

        if let loc = entry.locationName {
            pos.y = draw(text: "📍 \(loc)", font: Layout.labelFont,
                         color: UIColor.darkGray, x: x, y: pos.y, width: w) + 4
        }
        if let song = entry.musicTitle {
            let full = [song, entry.musicArtist].compactMap { $0 }.joined(separator: " · ")
            pos.y = draw(text: "🎵 \(full)", font: Layout.labelFont,
                         color: UIColor.darkGray, x: x, y: pos.y, width: w) + 4
        }
        if let weather = entry.weatherCondition {
            var wStr = "🌤 \(weather)"
            if let temp = entry.weatherTemperatureCelsius { wStr += " · \(Int(temp))°C" }
            pos.y = draw(text: wStr, font: Layout.labelFont,
                         color: UIColor.darkGray, x: x, y: pos.y, width: w) + 4
        }
        if entry.audioData != nil {
            pos.y = draw(text: "🎙 Audio recording attached (cannot be played in PDF)",
                         font: Layout.labelFont, color: UIColor.darkGray, x: x, y: pos.y, width: w) + 4
        }

        if !hadTags {
            pos.y += Layout.labelFont.lineHeight + 4 + 6
        } else {
            pos.y += 6
        }

        UIColor(white: 0, alpha: 0.15).setFill()
        UIRectFill(CGRect(x: x, y: pos.y, width: w, height: 0.5))
        pos.y += 10

        if !entry.text.isEmpty {
            drawFlowingText(text: entry.text, font: Layout.bodyFont, color: UIColor.black,
                            x: x, pos: pos, width: w,
                            newPage: newPage, ensureSpace: ensureSpace)
            pos.y += 12
        } else {
            let italicFont = UIFont.italicSystemFont(ofSize: 12)
            pos.y = draw(text: "No text provided for this entry.",
                         font: italicFont, color: UIColor.lightGray,
                         x: x, y: pos.y, width: w) + 12
        }

        if !entry.mediaData.isEmpty {
            if entry.text.isEmpty {
                ensureSpace(30)
            } else {
                newPage()
            }
            pos.y = draw(text: "Photos", font: Layout.h3Font, color: UIColor.black,
                         x: x, y: pos.y, width: w) + 6
            drawPhotoGrid(mediaData: entry.mediaData, x: x, pos: pos, width: w,
                          newPage: newPage, ensureSpace: ensureSpace)
        }

        if !entry.awards.isEmpty {
            ensureSpace(30)
            pos.y = draw(text: "Achievements", font: Layout.h3Font, color: UIColor.black,
                         x: x, y: pos.y, width: w) + 8

            for award in entry.awards {
                let awardNameH = boundingHeight(for: "\(award.type.medal)  \(award.displayTitle)",
                                               font: Layout.labelFont, width: w - 20)
                let descH      = boundingHeight(for: award.type.shortDescription,
                                               font: Layout.bodyFont, width: w - 20)
                let remarkH    = award.aiEncouragement
                    .map { boundingHeight(for: $0, font: Layout.captionFont, width: w - 20) } ?? 0
                let blockH     = 8 + awardNameH + 4 + descH
                               + (remarkH > 0 ? 4 + remarkH : 0) + 12

                ensureSpace(blockH + 8)

                let boxRect = CGRect(x: x, y: pos.y, width: w, height: blockH)
                UIColor(white: 0.96, alpha: 1).setFill()
                UIBezierPath(roundedRect: boxRect, cornerRadius: 6).fill()
                UIColor(white: 0.8, alpha: 1).setStroke()
                let stroke = UIBezierPath(roundedRect: boxRect.insetBy(dx: 0.5, dy: 0.5),
                                          cornerRadius: 6)
                stroke.lineWidth = 0.5
                stroke.stroke()

                var boxY = pos.y + 8

                let nameStr = "\(award.type.medal)  \(award.displayTitle)"
                boxY = draw(text: nameStr, font: Layout.labelFont, color: UIColor.black,
                            x: x + 10, y: boxY, width: w - 20) + 4
                boxY = draw(text: award.type.shortDescription, font: Layout.bodyFont,
                            color: UIColor.darkGray, x: x + 10, y: boxY, width: w - 20) + 4
                if let remark = award.aiEncouragement {
                    boxY = draw(text: "💬 \(remark)", font: Layout.captionFont,
                                color: UIColor.gray, x: x + 10, y: boxY, width: w - 20) + 4
                }

                pos.y += blockH + 8
            }
        }
    }

    // MARK: - Photo Grid

    // MARK: - Adaptive Photo Grid

    private func photoRowLayout(count: Int) -> [Int] {
        switch count {
        case 1: return [1]
        case 2: return [1, 1]
        case 3: return [1, 1, 1]
        case 4: return [2, 2]
        default:
            var rows: [Int] = []
            var remaining = count
            while remaining > 4 {
                rows += [2, 2]
                remaining -= 4
            }
            rows += photoRowLayout(count: remaining)
            return rows
        }
    }

    private func drawPhotoGrid(
        mediaData: [Data],
        x: CGFloat, pos: YPosition, width: CGFloat,
        newPage: () -> Void,
        ensureSpace: (CGFloat) -> Void
    ) {
        let images = mediaData.compactMap { UIImage(data: $0) }
        guard !images.isEmpty else { return }

        let gap:     CGFloat = 6
        let minRowH: CGFloat = (width - gap) / 2
        let count    = images.count

        if count == 3 {
            let available = Layout.bottomBound - pos.y
            let rh        = max(available, minRowH)
            let bigW      = (width - gap) * 0.6
            let smallW    = width - gap - bigW
            let smallH    = (rh - gap) / 2

            drawPhoto(images[0], in: CGRect(x: x, y: pos.y, width: bigW, height: rh))
            drawPhoto(images[1], in: CGRect(x: x + bigW + gap, y: pos.y,
                                            width: smallW, height: smallH))
            drawPhoto(images[2], in: CGRect(x: x + bigW + gap, y: pos.y + smallH + gap,
                                            width: smallW, height: smallH))
            pos.y += rh + gap
            return
        }

        let layout   = photoRowLayout(count: count)
        var imgIndex = 0
        var rowIndex = 0

        while rowIndex < layout.count {
            let availableH    = Layout.bottomBound - pos.y
            let maxRowsOnPage = max(1, Int(floor((availableH + gap) / (minRowH + gap))))
            let rowsThisPage  = min(maxRowsOnPage, layout.count - rowIndex)

            let gapTotal = gap * CGFloat(rowsThisPage - 1)
            let rh       = max((availableH - gapTotal) / CGFloat(rowsThisPage), minRowH)

            for i in 0 ..< rowsThisPage {
                let cols    = layout[rowIndex + i]
                let cellW   = (width - gap * CGFloat(cols - 1)) / CGFloat(cols)
                let rowW    = cellW * CGFloat(cols) + gap * CGFloat(cols - 1)
                let offsetX = (width - rowW) / 2

                for col in 0 ..< cols {
                    guard imgIndex < images.count else { break }
                    let cellX = x + offsetX + CGFloat(col) * (cellW + gap)
                    drawPhoto(images[imgIndex],
                              in: CGRect(x: cellX, y: pos.y, width: cellW, height: rh))
                    imgIndex += 1
                }

                pos.y += rh + gap
            }

            rowIndex += rowsThisPage

            if rowIndex < layout.count {
                newPage()
            }
        }
    }

    private func drawPhoto(_ image: UIImage, in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        UIBezierPath(roundedRect: rect, cornerRadius: 6).addClip()

        let imgAspect = image.size.width / image.size.height
        let boxAspect = rect.width / rect.height
        let drawRect: CGRect
        if imgAspect > boxAspect {
            let dw = rect.height * imgAspect
            drawRect = CGRect(x: rect.minX - (dw - rect.width) / 2,
                              y: rect.minY, width: dw, height: rect.height)
        } else {
            let dh = rect.width / imgAspect
            drawRect = CGRect(x: rect.minX,
                              y: rect.minY - (dh - rect.height) / 2,
                              width: rect.width, height: dh)
        }
        image.draw(in: drawRect)
        ctx.restoreGState()

        UIColor(white: 0, alpha: 0.1).setStroke()
        let border = UIBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 6)
        border.lineWidth = 0.5
        border.stroke()
    }

    // MARK: - Flowing Text

    private func drawFlowingText(
        text: String,
        font: UIFont,
        color: UIColor,
        x: CGFloat, pos: YPosition,
        width: CGFloat,
        newPage: () -> Void,
        ensureSpace: (CGFloat) -> Void
    ) {
        guard !text.isEmpty else { return }

        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineBreakMode = .byWordWrapping
        paraStyle.lineSpacing   = 2
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paraStyle
        ]

        let lineH = ceil(font.lineHeight) + 2

        let paragraphs = text.components(separatedBy: "\n")

        for (pIdx, paragraph) in paragraphs.enumerated() {
            let paraText = paragraph.isEmpty ? "" : paragraph

            if paraText.isEmpty {
                ensureSpace(lineH)
                pos.y += lineH
                continue
            }

            let attrPara = NSAttributedString(string: paraText, attributes: attrs)
            let typesetter = CTTypesetterCreateWithAttributedString(attrPara)
            var charStart = 0
            let paraLen = paraText.utf16.count

            while charStart < paraLen {
                let lineLen = CTTypesetterSuggestLineBreak(typesetter, charStart, Double(width))
                let lineRange = CFRange(location: charStart, length: lineLen)
                let ctLine = CTTypesetterCreateLine(typesetter, lineRange)

                ensureSpace(lineH)

                let lineStr = (paraText as NSString).substring(with: NSRange(location: charStart, length: lineLen))
                NSAttributedString(string: lineStr, attributes: attrs)
                    .draw(in: CGRect(x: x, y: pos.y, width: width, height: lineH + 2))

                pos.y += lineH
                charStart += lineLen
                _ = ctLine
            }

            if pIdx < paragraphs.count - 1 {
                pos.y += 2
            }
        }
    }

    // MARK: - Text Drawing Helper

    @discardableResult
    private func draw(
        text: String,
        font: UIFont,
        color: UIColor,
        x: CGFloat, y: CGFloat,
        width: CGFloat,
        alignment: NSTextAlignment = .left
    ) -> CGFloat {
        let para = NSMutableParagraphStyle()
        para.alignment     = alignment
        para.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: para
        ]
        let h = boundingHeight(for: text, font: font, width: width)
        NSAttributedString(string: text, attributes: attrs)
            .draw(in: CGRect(x: x, y: y, width: width, height: h + 2))
        return y + h
    }

    // MARK: - Helpers

    private func boundingHeight(for text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil
        ).size
        return ceil(size.height)
    }

    private func dateRangeString(entries: [JournalEntry]) -> String {
        guard let first = entries.last?.date, let last = entries.first?.date else {
            return Date().formatted(date: .abbreviated, time: .omitted)
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        if Calendar.current.isDate(first, equalTo: last, toGranularity: .day) {
            return fmt.string(from: first)
        }
        return "\(fmt.string(from: first)) – \(fmt.string(from: last))"
    }

    private func moodColor(for mood: Mood) -> UIColor {
        switch mood {
        case .great:    return .systemOrange
        case .good:     return .systemYellow
        case .okay:     return .systemMint
        case .bad:      return .systemBlue
        case .terrible: return .systemPurple
        }
    }

    private func moodSFImage(for mood: Mood, size: CGFloat) -> UIImage? {
        let name: String
        switch mood {
        case .great:    name = "face.smiling.inverse"
        case .good:     name = "face.smiling"
        case .okay:     name = "face.dashed"
        case .bad:      name = "cloud.drizzle"
        case .terrible: name = "cloud.bolt.rain"
        }
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .semibold)
        return UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0), renderingMode: .alwaysOriginal)
    }
}
