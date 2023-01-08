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
    
    func onTapItem(book: Book) {
        detailsBook = book
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.loading == false {
                    List(viewModel.list) { _item in
                        HStack {
                            Button(action: {
                                onTapItem(book: _item)
                            }) {
                                HStack{
                                    if _item.image != nil {
                                        AsyncImage(
                                            url: _item.image,
                                            content: { image in
                                                image.resizable()
                                                     .aspectRatio(contentMode: .fit)
                                                     .frame(width: 40, height: 40)
                                            },
                                            placeholder: {
                                                ProgressView()
                                                    .frame(width: 40, height: 40)
                                            }
                                        )
                                    }
                                    VStack(alignment: .leading){
                                        Text(_item.title)
                                            .foregroundColor(.primary)
                                        Text(_item.author ?? "")
                                            .font(.system(size: 12))
                                            .foregroundColor(.primary.opacity(0.4))
                                    }
                                    Spacer()
                                }
                            }
                        }
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
