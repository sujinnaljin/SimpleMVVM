//
//  SimpleViewModel.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import Foundation
import SwiftUI
import Combine

final class SimpleViewModel: ObservableObject {
    typealias InputType = Input
    
    private var cancellables: [AnyCancellable] = []
    
    private let onAppearSubject = PassthroughSubject<Void, Never>()
    
    // MARK: Input
    enum Input {
        case onAppear
    }
    func apply(_ input: Input) {
        switch input {
        case .onAppear: onAppearSubject.send(())
        }
    }
    
    // MARK: Output
    @Published private(set) var posts: [Post] = []
    @Published private(set) var profile: Profile? = nil
    @Published var isErrorShown = false
    @Published var errorMessage = ""
    @Published private(set) var shouldShowIcon = false
    
    private let responseSubject = PassthroughSubject<SimpleResponse, Never>()
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    private let trackingSubject = PassthroughSubject<TrackEventType, Never>()
    
    private var apiService: APIServiceType
    private var tracker: TrackerType
    
    init(apiService: APIServiceType = APIService(),
         tracker: TrackerType = Tracker()) {
        self.apiService = apiService
        self.tracker = tracker
        
        self.bindInputs()
        self.bindOutputs()
    }
    
    private func bindInputs() {
        let request = SimpleRequest()
        
        let responsePublisher = self.onAppearSubject.flatMap { [apiService] _ in
            (apiService.response(from: request)!
                .catch { [weak self] error -> Empty<SimpleResponse, Never> in
                    self?.errorSubject.send(error)
                    return .init()
                })
        }
        
        let responseStream = responsePublisher.subscribe(self.responseSubject)
        
        let trackingSubjectStream = self.trackingSubject.sink(receiveValue: self.tracker.log)
        
        let trackingStream = self.onAppearSubject.map { .listView }.subscribe(self.trackingSubject)
        
        cancellables += [
            responseStream,
            trackingSubjectStream,
            trackingStream,
        ]
        
    }
    
    private func bindOutputs() {
        let postsStream = self.responseSubject
            .map { $0.posts }
            .assign(to: \.posts, on: self)
        
        let profileStream = self.responseSubject
            .map { $0.profile }
            .assign(to: \.profile, on: self)
        
        let errorMessageStream = self.errorSubject
            .map { error -> String in
                switch error {
                case .responseError: return "network error"
                case .parseError: return "parse error"
                }
            }
            .assign(to: \.errorMessage, on: self)
        
        let errorStream = self.errorSubject
            .map { _ in true }
            .assign(to: \.isErrorShown, on: self)
        
        cancellables += [
            postsStream,
            profileStream,
            errorStream,
            errorMessageStream
        ]
    }
}
