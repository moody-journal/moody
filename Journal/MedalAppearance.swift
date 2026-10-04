import SceneKit
import UIKit

@MainActor
enum MedalAppearance {
    static func resourceURL(named name: String, bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: name, withExtension: "usdz", subdirectory: "badges")
            ?? bundle.url(forResource: name, withExtension: "usdz")
    }

    static func light(_ scene: SCNScene) {
        // Six real cubemap faces provide reflections; a flat UIColor is not an environment texture.
        scene.lightingEnvironment.contents = studioFaces
        scene.lightingEnvironment.intensity = 0.45
        addLight(to: scene, type: .directional, intensity: 1000, at: SCNVector3(-3, 4, 5))
        addLight(to: scene, type: .directional, intensity: 600, at: SCNVector3(3, 1, -4))
        addLight(to: scene, type: .omni, intensity: 300, at: SCNVector3(3, -2, 3))
        addLight(to: scene, type: .ambient, intensity: 100, at: SCNVector3Zero)
    }

    private static func addLight(to scene: SCNScene, type: SCNLight.LightType, intensity: CGFloat, at position: SCNVector3) {
        let light = SCNLight()
        light.type = type
        light.color = UIColor.white
        light.intensity = intensity
        let node = SCNNode()
        node.light = light
        node.position = position
        if type == .directional { node.look(at: SCNVector3Zero) }
        scene.rootNode.addChildNode(node)
    }

    private static let studioFaces: [UIImage] = (0..<6).map { face in
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 256, height: 256), format: format).image { renderer in
            let context = renderer.cgContext
            UIColor(white: face == 3 ? 0.32 : 0.58, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 256, height: 256))
            let colors = [UIColor.white.cgColor, UIColor(white: 0.6, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                context.drawRadialGradient(gradient, startCenter: CGPoint(x: 80, y: 64), startRadius: 12,
                                           endCenter: CGPoint(x: 128, y: 128), endRadius: 210, options: .drawsAfterEndLocation)
            }
            UIColor(white: 1, alpha: face == 3 ? 0.2 : 0.7).setFill()
            context.fill(CGRect(x: 25, y: 30, width: 54, height: 170))
        }
    }
}
