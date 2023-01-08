//
//  SearchItem.swift
//  opdsreader
//
//  Created by Николай Попов on 08.01.2023.
//

import SwiftUI

struct SearchItem: View {
    
    var book: Book
    var onTapItem: (_ book: Book) -> ()
    
    var body: some View {
        HStack {
            Button(action: {
                onTapItem(book)
            }) {
                HStack{
                    if book.image != nil {
                        AsyncImage(url: book.image) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            } else if phase.error != nil {
                                Color.brown
                                    .frame(width: 40, height: 40)
                            } else {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                            
                        }
                    } else {
                        EmptyImage()
                           .frame(width: 40, height: 40)
                    }
                    VStack(alignment: .leading){
                        Text(book.title)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        if book.author != nil {
                            Text(book.author ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(.primary.opacity(0.4))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct SearchItem_Previews: PreviewProvider {
    func onTapItem(_ book: Book) {}
    
    static var previews: some View {
        List {
            SearchItem(
                book: Book(
                    title: "Short title"
                ),
                onTapItem: {book in }
            )
            SearchItem(
                book: Book(
                    title: "Short title",
                    author: "Short Author"
                ),
                onTapItem: {book in }
            )
            SearchItem(
                book: Book(
                    title: "Short title",
                    author: "Short Author",
                    image: URL(string: "https://picsum.photos/200")!
                ),
                onTapItem: {book in }
            )
            SearchItem(
                book: Book(
                    title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                    author: "Short Author",
                    image: URL(string: "https://picsum.photos/200")!
                ),
                onTapItem: {book in }
            )
            SearchItem(
                book: Book(
                    title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                    author: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                    image: URL(string: "https://picsum.photos/200")!
                ),
                onTapItem: {book in }
            )
            SearchItem(
                book: Book(
                    title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed doLorem ipsum dolor sit amet, consectetur adipiscing elit, sed doLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                    author: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed doLorem ipsum dolor sit amet, consectetur adipiscing elit, sed doLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                    image: URL(string: "https://picsum.photos/200")!
                ),
                onTapItem: {book in }
            )
        }
        .preferredColorScheme(.dark)
    }
}
