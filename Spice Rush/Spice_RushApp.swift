//
//  Spice_RushApp.swift
//  Spice Rush

import SwiftUI

@main
struct Spice_RushApp: App {
    @UIApplicationDelegateAdaptor(SpiceRushAppDelegate.self) private var appDelegate
    var body: some Scene {
        WindowGroup {
            SpiceRushGameInitialView()
        }
    }
}
