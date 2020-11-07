//
//  SimpleRequest.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import Foundation

struct SimpleRequest: APIRequestType {
    typealias Response = SimpleResponse
    
    var path: String {
        "/seungwook-jung/SimpleJSONServer/db"
    }
    
    var queryItems: [URLQueryItem]? {
        nil
//        [.init(name: "q", value: "SwiftUI"), .init(name: "order", value: "desc")]
    }
}
