//
//  SearchScreenViewModel.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import SwiftUI
import Combine


@MainActor class SearchScreenViewModel: ObservableObject {
    @Published var list: [Book] = []
    @Published var searchValue = ""
    @Published var loading = false
    
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
        OpdsService.shared.searchByTitle(searchQuery: self.searchValue) { books, error in
            DispatchQueue.main.async {
                if(books != nil) {
                    self.list = books!
                }
                self.loading = false
            }
        }
    }
    
}
