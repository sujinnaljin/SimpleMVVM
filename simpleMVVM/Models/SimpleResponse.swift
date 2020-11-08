//
//  SimpleResponse.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import Foundation
import SwiftUI

// MARK: - SimpleResponse
struct SimpleResponse: Codable {
    let posts: [Post]
    let profile: Profile
}

// MARK: - Post
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
}

// MARK: - Profile
struct Profile: Codable {
    let name: String
}
