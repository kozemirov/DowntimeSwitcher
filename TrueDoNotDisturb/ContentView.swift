//
//  ContentView.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm: ScriptViewModel
    
    init(vm: ScriptViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()
            
            Text("Current state of Downtime is \(vm.downtimeState)").task {
                await vm.script()
            }

        }
        .frame(width: 300, height: 300)
    }
}

#Preview {
    ContentView(vm: ScriptViewModel())
}
