//
//  ContentView.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import SwiftUI
import CoreData
import ReadiumOPDS

struct SearchScreen: View {
    @StateObject var viewModel = SearchScreenViewModel()
    
    @State var detailsBook: Book? = nil
    
    func onTapItem(_ book: Book) {
        detailsBook = book
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.loading == false {
                    List(viewModel.list) { _item in
                        SearchItem(book: _item, onTapItem: onTapItem)
                            .onAppear {
                                if viewModel.list.last == _item {
                                    viewModel.fetchMore()
                                }
                            }
                    }
                    if viewModel.fetchingMore {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Search")
            .sheet(item: $detailsBook) { _detailsBook in
                BookDetailsScreen(book: _detailsBook)
            }
        }
        .searchable(text: $viewModel.searchValue)
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen()
    }
}
