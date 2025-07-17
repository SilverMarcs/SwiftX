//
//  AppSettings.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    static let localhost = "http://192.168.0.139:8000"
    static let webserver = "https://snscrape-production.up.railway.app"
//    static let webserver = "https://snscrape.vercel.app"

    @AppStorage("useWebserver") var useWebserver: Bool = false
    @AppStorage("apiKey") var apiKey: String = ""
}
