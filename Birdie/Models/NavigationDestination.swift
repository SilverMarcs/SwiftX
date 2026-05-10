//
//  NavigationDestination.swift
//  Birdie
//
//  Created by Zabir Raihan on 01/10/2025.
//

import Foundation

enum NavigationDestination: Hashable {
    case tweetDetail(Tweet)
    case userDetail(User)
}