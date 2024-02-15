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
            ScrollView{
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section {
                        switch viewModel.searchBy {
                        case .book:
                            if viewModel.loading == false {
                                LazyVStack {
                                    ForEach(viewModel.booksList) { _item in
                                        SearchItem(book: _item, onTapItem: onTapItem)
                                            .onAppear {
                                                if viewModel.booksList.last == _item {
                                                    viewModel.fetchMore()
                                                }
                                            }
                                            .padding(.bottom, 10)
                                            .overlay(
                                                EdgeBorder(width: 0.2, edges: [.bottom]).foregroundColor(.gray)
                                            )
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                                if viewModel.fetchingMore {
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                }
                            } else {
                                ProgressView()
                            }
                        case .author:
                            if viewModel.loading == false {
                                LazyVStack {
                                    ForEach(viewModel.authorsList) { _item in
                                        AuthorSearchItem(author: _item, onTapItem: onTapAuthor)
                                            .onAppear {
                                                if viewModel.authorsList.last == _item {
                                                    viewModel.fetchMore()
                                                }
                                            }
                                            .padding(.bottom, 10)
                                            .overlay(
                                                EdgeBorder(width: 0.2, edges: [.bottom]).foregroundColor(.gray)
                                            )
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                                if viewModel.fetchingMore {
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                }
                            } else {
                                ProgressView()
                            }
                        }
                    } header: {
                        Picker("What is your favorite color?", selection: $viewModel.searchBy) {
                            Text("Book").tag(SearchBy.book)
                            Text("Author").tag(SearchBy.author)
                        }
                        .padding()
                        .pickerStyle(.segmented)
                        .background(.background)
                    }
                }
            }
//            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Search")
            .sheet(item: $detailsBook) { _detailsBook in
                BookDetailsScreen(book: _detailsBook)
            }
            .sheet(item: $detailsAuthor) { _detailsAuthor in
                AuthorDetailsScreen(author: _detailsAuthor)
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


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}
