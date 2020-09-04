//
//  update.swift
//  
//
//  Created by neutralradiance on 9/3/20.
//

import Foundation
import ArgumentParser
import Files
import Yams
import Mustache

extension Builder {
    struct Update: ParsableCommand {
        static var configuration: CommandConfiguration =
            CommandConfiguration(
                abstract: "Update existing, sources, schemes and templates"
            )
        @Flag(inversion: .prefixedNo, help: "Generate themes from templates")
        var build: Bool = true
        @Flag(inversion: .prefixedNo, help: "Pull from repositories")
        var pull: Bool = true

        func run() {
            do {
                let git = Git()
                let sourceFile = try currentDirectory.createFileIfNeeded(
                    withName: "sources.yaml",
                    contents: String("""
                    schemes: https://github.com/chriskempson/base16-schemes-source.git
                    templates: https://github.com/chriskempson/base16-templates-source.git
                    """).data(using: .utf8))
                try SourceTypes.allCases.forEach { type in
                    try git.update(shouldPull: pull, forType: type, source: sourceFile)
                    if type == .templates && build {
                        for templateFolder in templatesFolder.subfolders {
                            let templateConfig = try templateFolder.subfolder(named: "templates")
                            if let configYaml = try Yams.load(
                                yaml: try templateConfig.file(named: "config.yaml").readAsString()
                                ) as? [String: [String: String]] {
                                try generate(with: templateConfig, config: configYaml)
                            } else {
                                print(
                                    BuildError.couldntParse(
                                        "configuration for \(templateFolder.path)"
                                    )
                                    .errorDescription!
                                )
                            }
                        }
                    }
                }
            } catch {
                Self.exit(withError: (error as? FilesError<Any>) ?? error)
            }
        }
    }
}

extension Builder.Update {
    func generate(with folder: Folder, config: [String: [String: String]]) throws {
        try schemesFolder.subfolders.forEach { themeFolder in
            for scheme in themeFolder.files where scheme.extension == "yaml" {
                var theme = (try Yams.load(yaml: scheme.readAsString()) as? [String: String]) ?? [:]
                guard !theme.isEmpty else { return }
                // render data
                theme["scheme-name"] = theme["scheme"]!
                theme["scheme-author"] = theme["author"]!
                theme["scheme-slug"] =
                    scheme.nameExcludingExtension.replacingOccurrences(of: " ", with: "-").lowercased()
                theme.removeValue(forKey: "scheme")
                theme.removeValue(forKey: "author")
                let rgbFormatter = NumberFormatter()
                rgbFormatter.allowsFloats = false
                rgbFormatter.maximum = 255
                rgbFormatter.minimum = 0
                let decFormatter = NumberFormatter()
                decFormatter.maximumFractionDigits = 8
                decFormatter.maximum = 1
                decFormatter.minimum = 0
                Self.keys.forEach { key in
                    let baseKey = "base"+key
                    // hex
                    let hex = theme[baseKey] ?? "000000"
                    let hrx = String(hex.dropLast(4))
                    let hgx: String = {
                        var hex = hex
                        hex.removeFirst(2)
                        hex.removeLast(2)
                        return hex
                    }()
                    let hbx = String(hex.dropFirst(4))
                    let intCode = Int(hex, radix: 16) ?? 0000000
                    // rgb
                    let r = Float((intCode >> 16) & 0xFF)
                    let g = Float((intCode >> 8) & 0xFF)
                    let b = Float(intCode & 0xFF)
                    // decimal
                    let red =  Float(r / 255)
                    let green = Float(g / 255)
                    let blue =  Float(b / 255)

                    theme[baseKey+"-hex"] = hex
                    theme[baseKey+"-hex-bgr"] = hbx+hgx+hrx
                    theme[baseKey+"-hex-r"] = hrx
                    theme[baseKey+"-hex-g"] = hgx
                    theme[baseKey+"-hex-b"] = hbx
                    theme[baseKey+"-rgb-r"] = rgbFormatter.string(from: NSNumber(value: r))
                    theme[baseKey+"-rgb-g"] = rgbFormatter.string(from: NSNumber(value: g))
                    theme[baseKey+"-rgb-b"] = rgbFormatter.string(from: NSNumber(value: b))
                    theme[baseKey+"-dec-r"] = decFormatter.string(from: NSNumber(value: red))
                    theme[baseKey+"-dec-g"] = decFormatter.string(from: NSNumber(value: green))
                    theme[baseKey+"-dec-b"] = decFormatter.string(from: NSNumber(value: blue))
                }
                try config.forEach { template, details  in
                    // apply mustache
                    let mustache = try folder.file(named: template+".mustache")
                    let template = try Template(path: mustache.path)
                    if let destination = details["output"] {
                        guard let writeFolder = try folder.parent?.createSubfolderIfNeeded(at: destination) else {
                            print(
                                BuildError.unexpected(
                                    "\(folder.path(relativeTo: templatesFolder)) is missing its parent."
                                )
                                .errorDescription!)
                            return
                        }
                        let name = "base16-"+theme["scheme-slug"]!+(details["extension"] ?? "")
                        let render = try template.render(theme)
                        if writeFolder.containsFile(named: name) {
                            try writeFolder.file(named: name).delete()
                            print("✗ \(writeFolder.path(relativeTo: templatesFolder)+"/"+name)")
                        }
                        try writeFolder.createFileIfNeeded(withName: name, contents: render.data(using: .utf8))
                    }
                }
            }
        }
    }
    static let keys: [String] =
    ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0A", "0B", "0C", "0D", "0E", "0F"]
}
