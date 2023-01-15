//
//  BookDetailsScreen.swift
//  opdsreader
//
//  Created by Николай Попов on 07.01.2023.
//

import SwiftUI
import CachedAsyncImage

struct BookDetailsScreen: View {
    @Environment(\.dismiss) var dismiss

    var book: Book
    
    func onClose() {
        dismiss()
    }
    
    func onDownload() {
        if let _link = book.link {
            UIApplication.shared.open(_link)
        }
    }
    
    func onLinkPress(link: URL) {
        UIApplication.shared.open(link)
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
            ScrollView{
                if book.image != nil {
                    CachedAsyncImage(
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
                Button(action: onDownload) {
                    Text("Download")
                }
                .buttonStyle(.borderedProminent)
                .disabled(book.link == nil)
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
                VStack{
                    ForEach(book.allLinks ?? [], id: \.absoluteString) { _link in
                        Button(action: {
                            onLinkPress(link: _link)
                        }) {
                            Text(_link.absoluteString)
                                .hAlign(.leading)
                        }
                    }
                }.padding()
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
                        description: "<div>But I must explain to you how all this mistaken idea of denouncing pleasure</br> and <h1>praising pain was born and I</h1> will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?</div>",
                        link: URL(string: "https://google.com"),
                        allLinks: [
                            URL(string: "https://google.com")!,
                            URL(string: "https://google22222222.com")!,
                        ]
                    )
                )
            .preferredColorScheme(.dark)
            }
        .preferredColorScheme(.dark)
    }
}
