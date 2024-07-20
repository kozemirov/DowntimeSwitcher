//
//  ScriptViewModel.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import Foundation

@MainActor 
class DowntimeViewModel: ObservableObject {

    @Published var downtimeState: Bool = false
    
    func script() async {
        do {
            let state = try await DowntimeScriptService().executeScript()
            if state {
                self.downtimeState.toggle()
            }
        } catch {
            print(error)
        }
    }
}
