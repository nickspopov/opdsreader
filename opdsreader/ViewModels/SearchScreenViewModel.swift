//
//  SearchScreenViewModel.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import SwiftUI
import Combine

enum SearchBy {
    case book, author
}

@MainActor class SearchScreenViewModel: ObservableObject {
    @Published var searchBy: SearchBy = .book
    
    @Published var booksList: [Book] = []
    @Published var authorsList: [AuthorShort] = []
    
    @Published var searchValue = ""
    @Published var loading = false
    @Published var fetchingMore = false
    
    
    private var disposeBag = Set<AnyCancellable>()

    init() {
        self.search()
        self.debounceTextChanges()
    }

    private func debounceTextChanges() {
        $searchValue
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { _ in
                self.loading = true
                self.search()
            }
            .store(in: &disposeBag)
    }
    
    func search() {
        switch searchBy {
        case .book:
            searchByBook()
        case .author:
            searchByAuthor()
        }
    }
    
    private func searchByAuthor() {
        OpdsService.shared.searchByAuthor(searchQuery: self.searchValue) { authors, error in
            DispatchQueue.main.async {
                if(authors != nil) {
                    self.authorsList = authors!
                }
                self.loading = false
            }
        }
    }
    
    private func searchByBook() {
        OpdsService.shared.searchByTitle(searchQuery: self.searchValue) { books, error in
            DispatchQueue.main.async {
                if(books != nil) {
                    self.booksList = books!
                }
                self.loading = false
            }
        }
    }
    
    func fetchMore() {
        switch searchBy {
            case .book:
                fetchMoreBooks()
            case .author:
                fetchMoreAuthors()
        }
    }
    
    private func fetchMoreAuthors() {
        
    }
    
    private func fetchMoreBooks() {
        let shouldFetchMore = self.booksList.count % 20 == 0 && !self.loading
        
        if !shouldFetchMore {
            return
        }
        
        self.fetchingMore = true
        
        let nextPageNumber = self.booksList.count / 20 + 1
        
        OpdsService.shared.searchByTitle(searchQuery: self.searchValue, pageNumber: nextPageNumber) { books, error in
            DispatchQueue.main.async {
                if(books != nil) {
                    self.booksList.append(contentsOf: books!)
                }
                self.fetchingMore = false
            }
        }
    }
    
}
