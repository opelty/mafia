import Foundation

struct Contents: Decodable {
    let images: [Image]
}

struct Image: Decodable {
    let filename: String?
}

func generateAssetCatalogConstants(from assetCatalogDirectory: URL, at outputFilePath: URL, xcodeProjectContext: Bool) throws {
    let bundle = xcodeProjectContext ?  "bundle" : ".module"
    let assetsName = assetCatalogDirectory.deletingPathExtension().lastPathComponent

    var generatedCode = """
    import Foundation
    import SwiftUI
    
    """
    
    if xcodeProjectContext {
        generatedCode.append("""
    private class GetBundle { }
    private let bundle = Bundle(for: GetBundle.self)
    
    
    """
        )
    }
    
    generatedCode.append("""
    public enum \(assetsName): String, CaseIterable {
    """)
    
    try FileManager.default.contentsOfDirectory(atPath: assetCatalogDirectory.path).forEach { directoryName in
        guard directoryName.hasSuffix("imageset") else {
            return
        }
        
        let contentsJsonURL = URL(fileURLWithPath: "\(assetCatalogDirectory)/\(directoryName)/Contents.json")
        let jsonData = try Data(contentsOf: contentsJsonURL)
        let assetCatalogContents = try JSONDecoder().decode(Contents.self, from: jsonData)
        let containsImage = !assetCatalogContents.images.filter { $0.filename != nil }.isEmpty
        
        if containsImage {
            let assetName = contentsJsonURL.deletingLastPathComponent().deletingPathExtension().lastPathComponent
            generatedCode.append("\n\t\tcase \(assetName)")
        }
    }


    generatedCode.append("""
    \n
        public var image: Image {
            Image(self.rawValue, bundle: \(bundle))
        }
    }
    """
    )

    try generatedCode.write(to: outputFilePath, atomically: true, encoding: .utf8)    
}
