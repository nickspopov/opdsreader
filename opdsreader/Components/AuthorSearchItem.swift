//
//  AuthorSearchItem.swift
//  opdsreader
//
//  Created by Николай Попов on 14.02.2024.
//

import SwiftUI

struct AuthorSearchItem: View {
    var author: AuthorShort
    var onTapItem: (_ book: AuthorShort) -> ()
    
    var body: some View {
        HStack {
            Button(action: {
                onTapItem(author)
            }) {
                HStack{
                        EmptyImage()
                           .frame(width: 40, height: 40)
                    VStack(alignment: .leading){
                        Text(author.name)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AuthorSearchItem(
        author: AuthorShort(
            name: "Author Name"
        ), onTapItem: {author in}
    )
}
