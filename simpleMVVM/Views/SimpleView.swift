//
//  SimpleView.swift
//  simpleMVVM
//
//  Created by seungwook.jung on 2020/11/07.
//

import SwiftUI

struct SimpleView: View {
    @ObservedObject var viewModel: SimpleViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                Text(post.title)
            }
            .alert(isPresented: $viewModel.isErrorShown, content: { () -> Alert in
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage))
            })
            .navigationBarTitle(Text("Repositories"))
        }
        .onAppear(perform: { self.viewModel.apply(.onAppear) })
    }
}

struct SimpleView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleView(viewModel: .init())
    }
}
