import Foundation

// Main logic
let arguments = ProcessInfo().arguments
guard arguments.count >= 3 else {
    fatalError("Usage: AssetsCodegen <inputAssetsPath> <outputPath> <optional: -xcodeProjectContext>")
}


let (input, output) = (URL(string: arguments[1])!, URL(string: arguments[2])!)
let xcodeProjectContext = arguments.contains("-xcodeProjectContext")

try generateAssetCatalogConstants(from: input, at: output, xcodeProjectContext: xcodeProjectContext)
