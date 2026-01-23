//
//  PicpuzzieApp.swift
//  Picpuzzie
//
//  Created by Edward Brayman on 1/18/26.
//

import SwiftUI

@main
struct PicpuzzieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
