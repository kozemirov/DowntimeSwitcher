//
//  ScriptService.swift
//  DowntimeSwitcher
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import Foundation

class DowntimeScriptService {
    func executeScript() async throws -> Bool {
        guard let path = Bundle.main.path(forResource: "DowntimeScript", ofType: "scpt") else {
            return false
        }
                       
        let url = URL(fileURLWithPath: path)
        var errors: NSDictionary?

        guard let appleScript = NSAppleScript(contentsOf: url, error: &errors) else {
           if let errors = errors {
               return false
           } else {
               return false
           }
        }

        var executionError: NSDictionary?
        DispatchQueue.main.sync {
           _ = appleScript.executeAndReturnError(&executionError)
        }

        if let executionError = executionError {
            return false
        }

        return true
    }
}
