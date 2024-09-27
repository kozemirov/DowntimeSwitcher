//
//  ContentView.swift
//  DowntimeSwitcher
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm: DowntimeViewModel
    
    init(vm: DowntimeViewModel) {
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
    ContentView(vm: DowntimeViewModel())
}
