//
//  ContentView.swift
//  202NeonReverie
//
//  Created by Roman on 6/4/26.
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()

    var body: some View {
        RootView()
            .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
