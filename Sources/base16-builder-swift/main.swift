//
//  main.swift
//
//
//  Created by neutralradiance on 9/3/20.
//

import Foundation
import ArgumentParser
import Files

let process = Process()
let currentDirectory = try Folder(path: process.currentDirectoryPath)
let schemeSources = try currentDirectory.createSubfolderIfNeeded(at: "/sources/schemes/")
let templateSources = try currentDirectory.createSubfolderIfNeeded(at: "/sources/templates/")
let schemesFolder = try currentDirectory.createSubfolderIfNeeded(at: "/schemes/")
let templatesFolder = try currentDirectory.createSubfolderIfNeeded(at: "/templates/")

struct Builder: ParsableCommand {
    static var configuration: CommandConfiguration =
        CommandConfiguration(
            abstract: "base16-builder-swift",
            version: "0.5",
            subcommands: [Init.self, Clean.self, Update.self],
            defaultSubcommand: Init.self
        )
}

extension Builder {
    struct Init: ParsableCommand {
        static var configuration: CommandConfiguration =
            CommandConfiguration(
                abstract: "Clear schemes and templates, then rebuild in the working directory"
            )
        func run() {
            do {
                // clear and build folders
                try schemeSources.empty(includingHidden: true)
                try templateSources.empty(includingHidden: true)
                try schemesFolder.empty(includingHidden: true)
                try templatesFolder.empty(includingHidden: true)
                Update.main(["--no-pull"])
            } catch {
                Self.exit(withError: (error as? FilesError<Any>) ?? error)
            }
        }
    }
    struct Clean: ParsableCommand {
        static var configuration: CommandConfiguration =
            CommandConfiguration(
                abstract: "Delete Builder folders in the current directory"
            )
        func run() {
            do {
                // clear and build folders
                try schemeSources.delete()
                try templateSources.delete()
                try schemesFolder.delete()
                try templatesFolder.delete()
            } catch {
                Self.exit(withError: (error as? FilesError<Any>) ?? error)
            }
        }
    }
}

Builder.main()
