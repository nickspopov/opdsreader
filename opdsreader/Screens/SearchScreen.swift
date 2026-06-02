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
        TabView {
            // Books Tab
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        if viewModel.loading && !viewModel.fetchingMore {
                            ProgressView()
                        } else {
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
                            if viewModel.fetchingMore && !viewModel.booksList.isEmpty {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Books")
            }
            .tabItem {
                Label("Books", systemImage: "book")
            }
            // Book details sheet
            .sheet(item: $detailsBook) { _detailsBook in
                BookDetailsScreen(book: _detailsBook)
            }
            .onAppear {
                viewModel.searchBy = .book
            }

            // Authors Tab
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        if viewModel.loadingAuthors {
                            ProgressView()
                        } else {
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
                            if viewModel.fetchingMore && !viewModel.authorsList.isEmpty {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                }
                .navigationTitle("Authors")
            }
            .tabItem {
                Label("Authors", systemImage: "person.2")
            }
            // Author details sheet
            .sheet(item: $detailsAuthor) { _detailsAuthor in
                AuthorDetailsScreen(author: _detailsAuthor)
            }
            .onAppear {
                viewModel.searchBy = .author
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

