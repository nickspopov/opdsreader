//
//  ContentView.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import SwiftUI
import CoreData
import ReadiumOPDS

struct ContentView: View {
    @StateObject var viewModel = SearchScreenViewModel()
    
    func onTapItem(book: Book) {
        if let _link = book.link {
            UIApplication.shared.open(_link)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.loading == false {
                    List(viewModel.list, id: \.title) { _item in
                        HStack {
                            Button(action: {onTapItem(book: _item)}) {
                                Text(_item.title)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }.navigationTitle("List")
        }
        .searchable(text: $viewModel.searchValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
