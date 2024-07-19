//
//  ScriptViewModel.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import Foundation

@MainActor 
class ScriptViewModel: ObservableObject {

    @Published var downtimeState: Bool = false
    
    func script() async {
        do {
            let state = try await ScriptService().executeScript()
            self.downtimeState = state
        } catch {
            print(error)
        }
    }
}
