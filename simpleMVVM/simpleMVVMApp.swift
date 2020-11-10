//
//  simpleMVVMApp.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import SwiftUI

@main
struct simpleMVVMApp: App {
    
    var body: some Scene {
        //App에 표현 될 뷰계층을 위해 사용되는 컨테이너.
        //그룹 컨텐츠로서 선언하는 계층은 앱이 그룹으로부터 생성하는 각 Window의 템플릿 역할을 하게 된다?
        WindowGroup {
            SimpleView(viewModel: .init())
        }
    }
}
