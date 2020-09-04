//
//  types.swift
//  
//
//  Created by neutralradiance on 9/3/20.
//

import Foundation

enum SourceTypes: String, CaseIterable {
    case schemes, templates
}

enum BuildError: LocalizedError {
    case missing(String, suggestion: String? = nil), noInput(String), couldntParse(String), unexpected(String)
    var errorDescription: String? {
        switch self {
        default: return """
            \(self.failureReason ?? "Unknown")!
            \(self.recoverySuggestion ?? "")
            """
        }
    }
    var failureReason: String? {
        switch self {
        case let .missing(path, _): return "missing `\(path)`"
        case let .couldntParse(path): return "couldn't parse \(path)"
        case let .unexpected(error): return "unexpected: \(error)"
        default: return nil
        }
    }
    var recoverySuggestion: String? {
        switch self {
        case let .missing(_, suggestion): return suggestion
        case let .unexpected(error): return error
        default: return nil
        }
    }
}
