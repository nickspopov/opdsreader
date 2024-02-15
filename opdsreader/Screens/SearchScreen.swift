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
    @State var detailsAuthor: AuthorShort? = nil
    
    func onTapItem(_ book: Book) {
        detailsBook = book
    }
    
    func onTapAuthor(_ author: AuthorShort) {
        detailsAuthor = author
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("What is your favorite color?", selection: $viewModel.searchBy) {
                    Text("Book").tag(SearchBy.book)
                    Text("Author").tag(SearchBy.author)
                }
                .padding()
                .pickerStyle(.segmented)
                switch viewModel.searchBy {
                case .book:
                    if viewModel.loading == false {
                        List(viewModel.booksList) { _item in
                            SearchItem(book: _item, onTapItem: onTapItem)
                                .onAppear {
                                    if viewModel.booksList.last == _item {
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
                case .author:
                    if viewModel.loading == false {
                        List(viewModel.authorsList) { _item in
                            AuthorSearchItem(author: _item, onTapItem: onTapAuthor)
                                .onAppear {
                                    if viewModel.authorsList.last == _item {
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

            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Search")
            .sheet(item: $detailsBook) { _detailsBook in
                BookDetailsScreen(book: _detailsBook)
            }
            .sheet(item: $detailsAuthor) { _detailsAuthor in
                
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
