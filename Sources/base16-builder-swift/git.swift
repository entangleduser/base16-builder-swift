//
//  git.swift
//  
//
//  Created by neutralradiance on 9/3/20.
//

import Foundation
import Files
import Yams

struct Git {
    let file: File? = (try? File(path: "/usr/local/bin/git")) ?? (try? File(path: "/usr/bin/git"))

    func run(_ arguments: [String], handler: @escaping (Process) -> Void = {_ in}) {
        let process = Process()
        guard let binary = self.file else {
            Builder.Update.exit(withError: BuildError.missing("git", suggestion: "Please download `git`."))
        }
        process.launchPath = binary.path
        process.arguments = arguments
        process.launch()
        process.waitUntilExit()
        handler(process)
    }
}

extension Git {
    func update(shouldPull pull: Bool, forType type: SourceTypes, source: File) throws {
        guard let sourceYaml =
                try Yams.load(yaml: source.readAsString()) as? [String: String],
              let sourceURL = sourceYaml[type.rawValue] else {
            throw BuildError.missing("config.yaml")
        }
        let sourceClone = "sources/"+type.rawValue
        // update lists
        if pull {
            self.run(["pull", sourceClone])
        } else {
            self.run(["clone", sourceURL, sourceClone])
        }
        // update repositories
        let listPath = sourceClone+"/list.yaml"
        guard let listFile = try? currentDirectory.file(at: listPath),
              let listYaml = try? Yams.load(yaml: listFile.readAsString()) as? [String: String] else {
            throw BuildError.missing(
                listPath,
                suggestion: "Try running `builder init` and make sure you're running in a terminal window.")
        }
        let root = type.rawValue+"/"
        listYaml.forEach { (name, url) in
            let listClone = root+name
            if pull {
                self.run(["pull", listClone])
            } else {
                self.run(["clone", url, listClone])
            }
        }
    }
}
