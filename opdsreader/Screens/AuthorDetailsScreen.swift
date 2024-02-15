//
//  AuthorDetailsScreen.swift
//  opdsreader
//
//  Created by Николай Попов on 15.02.2024.
//

import SwiftUI

struct AuthorDetailsScreen: View {
    @Environment(\.dismiss) var dismiss
    @State var books: [Book] = []
    @State var selecetedBook: Book? = nil
    
    var author: AuthorShort
    
    func onClose() {
        dismiss()
    }
    
    func onAppear() {
        Task {
            if let link = author.link {
                OpdsService.shared.getBooksByAuthor(authorLink: link) { books, error in
                    if(books != nil) {
                        self.books = books!
                    }
                }
            }
        }
    }
    
    func onTapItem(book: Book) {
        selecetedBook = book
    }
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button(action: onClose) {
                    Text("Close")
                }
            }
            .padding()
            List(books) { _item in
                SearchItem(book: _item, onTapItem: onTapItem)
            }
        }
        .onAppear(perform: onAppear)
        .sheet(item: $selecetedBook) { book in
            BookDetailsScreen(book: book)
        }
    }
}

#Preview {
    AuthorDetailsScreen(
        author: AuthorShort(name: "Author Name")
    )
}
