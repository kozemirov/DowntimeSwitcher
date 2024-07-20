//
//  ScriptService.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import Foundation

class ScriptService {
    func executeScript() async throws -> Bool {
        guard let path = Bundle.main.path(forResource: "Script", ofType: "scpt") else {
                   throw NSError(domain: "ScriptServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Script file not found"])
               }
                       
        let url = URL(fileURLWithPath: path)
        var errors: NSDictionary?

        guard let appleScript = NSAppleScript(contentsOf: url, error: &errors) else {
           if let errors = errors {
               throw NSError(domain: "ScriptServiceError", code: 2, userInfo: errors as? [String: Any])
           } else {
               throw NSError(domain: "ScriptServiceError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create AppleScript"])
           }
        }

        var executionError: NSDictionary?
        DispatchQueue.main.sync {
           _ = appleScript.executeAndReturnError(&executionError)
        }

        if let executionError = executionError {
           throw NSError(domain: "ScriptServiceError", code: 3, userInfo: executionError as? [String: Any])
        }

        return true
    }
}
