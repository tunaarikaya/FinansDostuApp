//
//  FinansDostuApp.swift
//  FinansDostu
//
//  Created by Mehmet Tuna Arıkaya on 6.01.2025.
//

import SwiftUI
import OneSignalFramework
import UserNotifications

@main
struct FinansDostuApp: App {
    @StateObject private var viewModel = MainViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Debug loglarını kapat
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        #if DEBUG
        UserDefaults.standard.setValue(false, forKey: "CA_DEBUG_TRANSACTIONS")
        #endif
        
        // Varsayılan tema ayarını koyu olarak ayarla
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "isDarkMode")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
                .onAppear {
                    // Gereksiz animasyonları kapat
                    UIView.setAnimationsEnabled(false)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // OneSignal initialization
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("b01c5e20-27dd-43c2-bcef-65508d86f0fd", withLaunchOptions: launchOptions)
        
        // Yerel bildirimler için izin isteği
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Yerel bildirim izni verildi")
            } else {
                print("Yerel bildirim izni reddedildi: \(error?.localizedDescription ?? "")")
            }
        }
        
        // OneSignal bildirimleri için izin isteği
        OneSignal.Notifications.requestPermission({ accepted in
            print("OneSignal bildirim izni: \(accepted)")
        }, fallbackToSettings: true)
        
        return true
    }
}
