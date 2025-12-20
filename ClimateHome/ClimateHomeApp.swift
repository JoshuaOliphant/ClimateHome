//
//  ClimateHomeApp.swift
//  ClimateHome
//
//  Created by Joshua Oliphant on 12/6/25.
//

import SwiftUI
import SwiftData

@main
struct ClimateHomeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedAddress.self)
    }
}
