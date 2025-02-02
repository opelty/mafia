import PackagePlugin
import struct Foundation.URL

@main
struct assets_generator: BuildToolPlugin {
    private var toolName: String { "AssetsCodegen" }
    /// Entry point for creating build commands for targets in Swift packages.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceFiles = target.sourceModule?.sourceFiles else { return [] }

        // Find the code generator tool to run (replace this with the actual one).
        let generatorTool = try context.tool(named: self.toolName)

        return sourceFiles.map(\.url).compactMap {
            createBuildCommand(for: $0, in: context.pluginWorkDirectoryURL, with: generatorTool.url, xcodeProjectContext: false)
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension assets_generator: XcodeBuildToolPlugin {
    // Entry point for creating build commands for targets in Xcode projects.
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let generatorTool = try context.tool(named: self.toolName)

        return target.inputFiles.map(\.url).compactMap {
            createBuildCommand(for: $0, in: context.pluginWorkDirectoryURL, with: generatorTool.url, xcodeProjectContext: true)
        }
    }
}

#endif

extension assets_generator {
    /// Shared function that returns a configured build command if the input files is one that should be processed.
    func createBuildCommand(for inputPath: URL, in outputDirectoryPath: URL, with generatorToolPath: URL, xcodeProjectContext: Bool) -> Command? {
        guard inputPath.pathExtension == "xcassets" else { return .none }

        // Return a command that will run during the build to generate the output file.
        let inputName = inputPath.lastPathComponent
        let outputName = inputPath.deletingPathExtension().lastPathComponent + ".swift"
        let outputPath = outputDirectoryPath.appending(component: outputName)
        let xcodeProjectContext = xcodeProjectContext ? "-xcodeProjectContext" : ""

        print("-> ->", inputPath.path, outputPath.path, inputName, outputName)
        return .buildCommand(
            displayName: "Generating assets constants for \(outputName) from \(inputName)",
            executable: generatorToolPath,
            arguments: ["\(inputPath.path)", "\(outputPath.path)", outputName, xcodeProjectContext],
            inputFiles: [inputPath],
            outputFiles: [outputPath]
        )
    }
}
