import AppKit
import SceneKit
import Metal

// Run from the project root: swift Tools/render-medal-icons.swift
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let originals = root.appendingPathComponent("Journal/badges")
let device = MTLCreateSystemDefaultDevice()!
func faces() -> [NSImage] {
    (0..<6).map { face in
        let image = NSImage(size: NSSize(width: 256, height: 256))
        image.lockFocus()
        NSColor(white: 0.58, alpha: 1).setFill(); NSRect(x: 0,y: 0,width: 256,height: 256).fill()
        NSGradient(starting: .white, ending: NSColor(white: 0.6,alpha:1))!.draw(in: NSBezierPath(rect:NSRect(x:0,y:0,width:256,height:256)), relativeCenterPosition: NSPoint(x:-0.35,y:0.5))
        NSColor(white:1,alpha:face == 3 ? 0.2:0.7).setFill();NSRect(x:25,y:56,width:54,height:170).fill()
        image.unlockFocus();return image
    }
}
let environment = faces()
func render(_ url: URL) throws -> NSImage {
    let source = try SCNScene(url:url)
    let scene = SCNScene()
    scene.background.contents = NSColor.clear
    let medal = SCNNode()
    for child in source.rootNode.childNodes { medal.addChildNode(child) }
    medal.eulerAngles.x = -.pi/2
    let (lo,hi) = medal.boundingBox
    let corners = [lo.x,hi.x].flatMap { x in [lo.y,hi.y].flatMap { y in [lo.z,hi.z].map { z in medal.convertPosition(SCNVector3(x,y,z), to:nil) } } }
    let minX = corners.map(\.x).min()!, maxX = corners.map(\.x).max()!
    let minY = corners.map(\.y).min()!, maxY = corners.map(\.y).max()!
    let minZ = corners.map(\.z).min()!, maxZ = corners.map(\.z).max()!
    let scale = 1.8 / max(maxX-minX,maxY-minY,maxZ-minZ)
    let wrapper = SCNNode();wrapper.addChildNode(medal);wrapper.scale = SCNVector3(scale,scale,scale)
    wrapper.position = SCNVector3(-(maxX+minX)*scale/2,-(maxY+minY)*scale/2,-(maxZ+minZ)*scale/2)
    scene.rootNode.addChildNode(wrapper)
    func light(_ type: SCNLight.LightType,_ intensity: CGFloat,_ position: SCNVector3,_ color: NSColor = .white) {
        let l=SCNLight();l.type=type;l.intensity=intensity;l.color=color
        let n=SCNNode();n.light=l;n.position=position
        if type == .directional { n.look(at: SCNVector3Zero) }
        scene.rootNode.addChildNode(n)
    }
    scene.lightingEnvironment.contents=environment;scene.lightingEnvironment.intensity=0.45
    light(.directional,1000,SCNVector3(-3,4,5));light(.directional,600,SCNVector3(3,1,-4));light(.omni,300,SCNVector3(3,-2,3));light(.ambient,100,SCNVector3Zero)
    let camera=SCNCamera();camera.usesOrthographicProjection=true;camera.orthographicScale=1.0;camera.wantsHDR=true;camera.bloomIntensity=0;camera.bloomThreshold=1
    let cn=SCNNode();cn.camera=camera;cn.position=SCNVector3(0,0,3.6);scene.rootNode.addChildNode(cn)
    let renderer=SCNRenderer(device:device,options:nil);renderer.scene=scene;renderer.pointOfView=cn
    return renderer.snapshot(atTime:0,with:NSSize(width:512,height:512),antialiasingMode:.multisampling4X)
}

let rows = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent("Tools/medal-icons.json"))) as! [[String:String]]
let assets = root.appendingPathComponent("Journal/Assets.xcassets")
for row in rows {
    let folder=assets.appendingPathComponent(row["asset"]!+".imageset")
    try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)
    let result=try render(originals.appendingPathComponent(row["model"]!+".usdz"))
    let bitmap=NSBitmapImageRep(data:result.tiffRepresentation!)!
    try bitmap.representation(using:.png,properties:[:])!.write(to:folder.appendingPathComponent("medal.png"))
    let json:[String:Any] = ["images":[["filename":"medal.png","idiom":"universal"]],"info":["author":"xcode","version":1]]
    try JSONSerialization.data(withJSONObject:json,options:.prettyPrinted).write(to:folder.appendingPathComponent("Contents.json"))
    print(row["model"]!,bitmap.pixelsWide,bitmap.pixelsHigh)
}
