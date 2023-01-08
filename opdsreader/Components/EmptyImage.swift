//
//  EmptyImage.swift
//  opdsreader
//
//  Created by Николай Попов on 08.01.2023.
//

import SwiftUI

struct EmptyImage: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.secondary.opacity(0.2))
            Image(systemName: "photo")
                .foregroundColor(.secondary.opacity(0.6))
                .zIndex(2)
        }
        .cornerRadius(4)
    }
}

struct EmptyImage_Previews: PreviewProvider {
    static var previews: some View {
        EmptyImage()
            .frame(width: 40, height: 40)
            .preferredColorScheme(.dark)
    }
}
