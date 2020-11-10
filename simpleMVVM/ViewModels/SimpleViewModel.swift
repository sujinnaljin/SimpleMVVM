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
    // @State는 View에서 사용하는 어노테이션이기 때문에 여기선 @Published로 사용하는 듯
    @Published private(set) var posts: [Post] = []
    @Published private(set) var profile: Profile? = nil
    @Published var isErrorShown = false
    @Published var errorMessage = ""
    @Published private(set) var shouldShowIcon = false
    
    //PassthroughSubject는 publisher의 일종으로 초기값 없음. send(_:) 통해 새로운 값 게시 가능. 초기값 있는건 CurrentValueSubject 사용.
    private let responseSubject = PassthroughSubject<SimpleResponse, Never>()
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    private let trackingSubject = PassthroughSubject<TrackEventType, Never>()
    
    //기본값 초기화도 안하고 optional도 아니게 타입 선언하는거는 init() 안에서 해당 값을 초기화할때 사용하는 타입? 그건  Implicitly Unwrapped Optional 인가? 튼 왜 바로 초기값 선언 안하는지?
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
        
        //일단 flatMap이 publisher를 뱉어냄
        //근데 여긴 class라 apiService를 캡쳐해줘야하는건가? 왜 어디서 이제 self. 써서 캡쳐 안해줘도 된다고 본거 같지🤔
        //이걸로 결국 네트워크 요청이 되는거니까 새로 네트워크 요청하고 싶으면 onAppearSubject.send() 하면 되겠군여
        let responsePublisher = self.onAppearSubject.flatMap { [apiService] _ in
            (apiService.response(from: request)!
                //catch는 (APIServiceError)를 받아서 -> Publisher 리턴하는 handler 넣어준다
                //Error는 어떤 데이터도 발행하지 않는 퍼블리셔로 주로 에러처리나 옵셔널값을 처리할때 사용된다는데.. 발행하지 않는데 왜 Output 타입을 명시해줘야하지 ㅋㅎ 그리고 여기에 그리고 String 넣으면 에러나는걸로 보아 뭔가와.. 짝이 맞아야하는거 같다?
                .catch { [weak self] error -> Empty<SimpleResponse, Never> in
                    self?.errorSubject.send(error)
                    //와 .init() 이건 도대체 어떻게 동작하는 코드지 🤔
                    return .init()
                })
        }
        
        //오 .subscribe(_:) 인자안에 subscriber을 넣어도 되고 subject를 넣어도 되는군요..? 그럼 서브젝트로 넣었을때는 publisher에서 값 뱉어낼때마다 send를 이어서 호출하는건가?
        //얜 값 처리용?
        let responseStream = responsePublisher.subscribe(self.responseSubject)
        
        //self.trackingSubject.sink { (trackerType) in } 원래 이렇게 될걸 그냥 tracker.log 함수를 넣어준거군여?
        //얜 로그 기록용?
        let trackingSubjectStream = self.trackingSubject.sink(receiveValue: self.tracker.log)
        
        //대체 listView의 case는 어떻게 추론했길래 .으로만도 접근이 됨? 생각했는데 뒤에 trackingSubject 때문에 되는건듯? 얘는 onAppearSubject가 값 쏠때마다 listView를 trackingSubject로 보내는 역할인듯?
        //얜 onAppear 때 처리용?
        let trackingStream = self.onAppearSubject.map { .listView }.subscribe(self.trackingSubject)
        
        //오 끝에 ,가 있어도 에러가 안나는구나 신기하다
        cancellables += [
            responseStream,
            trackingSubjectStream,
            trackingStream,
        ]
        
    }
    
    //bindOutputs은 뷰에 직접적으로 연관된 동작들 넣은건가보지?
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
