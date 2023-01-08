//
//  BookDetailsScreen.swift
//  opdsreader
//
//  Created by Николай Попов on 07.01.2023.
//

import SwiftUI


struct BookDetailsScreen: View {
    @Environment(\.dismiss) var dismiss

    var book: Book
    
    func onClose() {
        dismiss()
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
            HStack{
                Spacer()
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        if let _link = book.link {
                            UIApplication.shared.open(_link)
                        }
                    }
            }
            ScrollView{
                if book.image != nil {
                    AsyncImage(
                        url: book.image,
                        content: { image in
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(maxWidth: 300, maxHeight: 300)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                }
                Text(book.title)
                    .font(.title)
                VStack(alignment: .leading){
                    HStack {
                        Text(book.description ?? "No description")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
            }
        }
    }
}


struct BookDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            Text("Details")
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: .constant(true)) {
            BookDetailsScreen(
                    book: Book(
                        title: "Title",
                        description: "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?",
                        link: URL(string: "https://google.com"),
                        allLinks: [
                            URL(string: "https://google.com")!,
                            URL(string: "https://google.com")!,
                        ]
                    )
                )
            .preferredColorScheme(.dark)
            }
        .preferredColorScheme(.dark)
    }
}
