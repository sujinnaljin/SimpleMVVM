//
//  AnySubscription.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import Foundation
import Combine

//이건 왜 옮겨적으셨죠 승욱님?
final class AnySubscription: Subscription {
    
    private let cancellable: AnyCancellable
    
    init(_ cancel: @escaping () -> Void) {
        self.cancellable = AnyCancellable(cancel)
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
    
    func cancel() {
        self.cancellable.cancel()
    }
}
